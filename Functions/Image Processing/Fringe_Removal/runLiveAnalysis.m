 function runLiveAnalysis()
% runLiveAnalysis()
%
% Live image analysis. This function waits for new data to arrive in the data folder of today,
% and then runs the images through the fringe removal process and calculates the
% atom number, etc. These results are written into a text file, and the
% optical density is written into a .tif image.


%Darth bitwise directory, and the remote data directory of the imaging computer
bitwise = directory();
imaging = directory('darth.imaging');
                    
%Turn the directory exists warning off
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%Make Folders
mkdir(imaging.Processed);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

%Set the number of reference images to load into the stack
numberOfImages = 30;
disp('loading reference images')
try
    [R, basisVectors,k, bgmask] = loadNewestRefStack(numberOfImages);
    numberOfRefImages = numberOfImages;
catch ME1
    %How many reference images are stored?
    refFiles=dir([bitwise.RefImages '*Ref.tif']);
    numberOfRefImages = length({refFiles.name});
    disp('Not Enough reference images have been stored.');
    disp([num2str(numberOfRefImages) ' haved been stored so far.']);
    disp('Normal image processing will be used until enough images are stored');
end

[ROIx, ROIy, signalMask] = getROIFromFile();

%Initialise loop variables, and start waiting for new data.
%The while loop only stops when it is terminated.
i=1;
loopCount = 1;

%Run normal image processing until enough images are stored.
while numberOfRefImages <= numberOfImages
    %Wait for new image files to arrive on the imaging computer 
    %and returns the new names.
    %This returns when all images are present. Checking the BG files first
    disp('Waiting for new images')
    [nameObj, nameRef, nameBG1, newFileBG, mode] = getNewImage(imaging);
    
    %copy images from imaging computer to bitwise
    copyfile([imaging.ObjImages, nameObj],[bitwise.ObjImages, nameObj]);
    copyfile([imaging.RefImages, nameRef],[bitwise.RefImages, nameRef]);
    copyfile([imaging.BgImages, nameBG1],[bitwise.BgImages, nameBG1]);
    if mode == 2
        copyfile([imaging.BgImages, newFileBG],[bitwise.BgImages, newFileBG]);
    end
    
    %load and analyse images that are now on bitwise
    if mode == 1 %Single Shutter mode
        %load images
        atoms = double(imread([bitwise.ObjImages, nameObj],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        laser = double(imread([bitwise.RefImages, nameRef],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        bg1 = double(imread([bitwise.BgImages, nameBG1],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
      
        %Set the path for the analysed imaged to be saved to
        [p, name, ext] = fileparts(nameObj);
        timestamp = name(1:14);
        imagePath = [bitwise.Processed, timestamp, ' MLAbsorption.tif'];
        remotePath = [imaging.Processed, timestamp, ' MLAbsorption.tif'];
        
        %Analyse image
        [atomNumber, opticalDensityMax, sizeX, sizeY] = Absorption_normalisingLV( atoms, laser, bg1, signalMask, imagePath);
        resultsArray = [atomNumber, opticalDensityMax, sizeX, sizeY];
        copyfile(imagePath, remotePath);
        disp(num2str(atomNumber));
    else %double shutter mode
        %load images
        atoms = double(imread([bitwise.ObjImages, nameObj],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        laser = double(imread([bitwise.RefImages, nameRef],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        bg1 = double(imread([bitwise.BgImages, nameBG1],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        pause(2)
        bg2 = double(imread([bitwise.BgImages, newFileBG],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
      
        %Set the path for the analysed imaged to be saved to
        [p, name, ext] = fileparts(nameObj);
        timestamp = name(1:14);
        imagePath = [bitwise.Processed, timestamp, ' MLAbsorption.tif'];
        remotePath= [imaging.Processed, timestamp, ' MLAbsorption.tif'];
        
        %Analyse image
        [atomNumber, opticalDensityMax, sizeX, sizeY] = Absorption_normalising_DSLV(atoms, laser, bg1, bg2, signalMask, imagePath);
        resultsArray = [atomNumber, opticalDensityMax, sizeX, sizeY]; 
        copyfile(imagePath, remotePath);
        disp(num2str(atomNumber));
    end
        %Write results into the result file.
        writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray);
        %Write results into the result file on remote imaging drive
        writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray, imaging.Processed);
        
        %Recount number of images stored
        refFiles=dir([bitwise.RefImages,'*Ref.tif']);
        numberOfRefImages = length({refFiles.name}); 
end

%Now we have enough reference images
disp('Switching to Fringe Removal processing');
disp('loading reference images');
[R, basisVectors,k, bgmask] = loadNewestRefStack(numberOfImages);

while i==1
    %Load new ref images every 10 shots
    if loopCount == 10 
        loopCount =1;
        disp('loading new reference images')
        %Load New images
        [R, basisVectors,k, bgmask] = loadNewestRefStack(numberOfImages);
    end
    
    %Wait for new image files to arrive and returns the new names.
    %This returns when all images are present. Checking the BG files first
    disp('Waiting for new images')
    [nameObj, nameRef, nameBG1, newFileBG, mode] = getNewImage(imaging);
    
    %copy images from imaging computer to bitwise
    copyfile([imaging.ObjImages, nameObj],[bitwise.ObjImages, nameObj]);
    copyfile([imaging.RefImages, nameRef],[bitwise.RefImages, nameRef]);
    copyfile([imaging.BgImages, nameBG1],[bitwise.BgImages, nameBG1]);
    if mode == 2
        copyfile([imaging.BgImages, newFileBG],[bitwise.BgImages, newFileBG]);
    end
    
    %Get the background picture file name
    if strcmp(nameBG1, '') 
        bgFile = newFileBG;
    else bgFile = nameBG1;
    end

    atomFile = {[bitwise.ObjImages nameObj]};
    atomBGFile ={[bitwise.BgImages bgFile]};
    
    disp('Loading new atom image')
    %Load the new atom and background image.
    A = loadAtomImageStack(atomFile, atomBGFile, ROIx, ROIy);

    xdim = length(ROIx);
    ydim = length(ROIy);

    disp('Optimising reference image')
    %Calcalate the best weighted sum of reference images for the atom image.
    optrefimages = optimiseReferenceImage(A, R, basisVectors, k, xdim, ydim, 1);
    
    %Reformat each image into single image matrix
    atomImage = reshape(A(:,:),xdim,ydim);
    optRef = reshape(optrefimages(1,:,:),xdim,ydim,1);
    refImage = reshape(R(:,i),xdim,ydim,1);
   
    %Set the path for the analysed imaged to be saved to
    [p, name, ext] = fileparts(atomFile{1});
    timestamp = name(1:14);
    imagePath = [bitwise.Processed, timestamp, ' FR_1.tif'];
    remotePath = [imaging.Processed, timestamp, ' FR_1.tif'];

    disp('Calculating Atom number')
    %Analyse for atom number and save the divided image (atom/.optRef)
    [atomNumber, opticalDensityMax, sizeX, sizeY, opticalDensity] =  Absorption_DSLV(atomImage, optRef, signalMask, imagePath);
    %realsigmas = fit2DGaussian(opticalDensity, signalMask);
    resultsArray = [atomNumber, opticalDensityMax, sizeX, sizeY];
    copyfile(imagePath, remotePath);
    
    %Write results into the result file.
    writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray);
    %Write results into the result file on remote imaging drive
    writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray, imaging.Processed);
    
    %Ready to process more images.
    loopCount = loopCount + 1;
    disp(loopCount)
    disp(num2str(atomNumber));
end