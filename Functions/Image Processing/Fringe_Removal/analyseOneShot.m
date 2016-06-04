function [opticalDensity] = analyseOneShot()
% liveAnalysis()
%
% Live image analysis. This function waits for new data to arrive in the data folder of today,
% and then runs the images through the fringe removal process and calculates the
% atom number, etc. These results are written into a text file, and the
% optical density is written into a .tif image.
% It analyses all new images, even if they arrive when matlab is busy processing the
% last image.


%Darth bitwise directory, and the remote data directory of the imaging computer
bitwise = directory();
imaging = directory('darth.imaging');
                    
%Turn the directory exists warning off
warning('off', 'MATLAB:MKDIR:DirectoryExists');
%Make Folders
mkdir(imaging.Processed);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

%Set the number of reference images to load into the stack
numberOfImages = 1000;
disp('loading reference images')
try
    [R, basisVectors,k, bgmask] = loadNewestRefStack(numberOfImages);
    numberOfRefImages = numberOfImages;
catch ME1
    %How many reference images are stored?
    refFiles=dir([bitwise.RefImages '*Ref.tif']);
    numberOfRefImages = length({refFiles.name});
    disp('Not Enough reference images have been stored.');
    disp([numberOfRefImages ' haved been stored so far.']);
    disp('Normal image processing will be used until enough images are stored');
end

[ROIx, ROIy, signalMask] = getROIFromFile();

%Initialise loop variables, and start waiting for new data.
%The while loop only stops when it is terminated.
i=1;
loopCount = 1;

%Initilise image file stacks
nameObj = {};
nameRef = {};
nameBG1 = {};
newFileBG = {};
mode = {};
k=0;

    %Wait for new image files to arrive on the imaging computer 
    %and returns the new names.
    %This returns when all images are present. Checking the BG files first
    if isempty(nameObj)
        disp('Waiting for new images')
        if k == 0
            [nameObj, nameRef, nameBG1, newFileBG, mode, fileCount] = getNewImages(imaging, -1);
        else
            [nameObj, nameRef, nameBG1, newFileBG, mode, fileCount] = getNewImages(imaging,fileCount);
        end
    end
    
    %copy images from imaging computer to bitwise
    copyfile([imaging.ObjImages, nameObj{1}],[bitwise.ObjImages, nameObj{1}]);
    copyfile([imaging.RefImages, nameRef{1}],[bitwise.RefImages, nameRef{1}]);
    copyfile([imaging.BgImages, nameBG1{1}],[bitwise.BgImages, nameBG1{1}]);
    if mode{1} == 2
        copyfile([imaging.BgImages, newFileBG{1}],[bitwise.BgImages, newFileBG{1}]);
    end
    
    %load and analyse images that are now on bitwise
    if mode{1} == 1 %Single Shutter mode
        %load images
        atoms = double(imread([bitwise.ObjImages, nameObj{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        laser = double(imread([bitwise.RefImages, nameRef{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        bg1 = double(imread([bitwise.BgImages, nameBG1{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
      
        %Set the path for the analysed imaged to be saved to
        [p, name, ext] = fileparts(nameObj{1});
        timestamp = name(1:14);
        imagePath = [bitwise.Processed, timestamp, ' MLAbsorption.tif'];
        remotePath = [imaging.Processed, timestamp, ' MLAbsorption.tif'];
        
        %Analyse image
        [atomNumber, opticalDensityMax, sizeX, sizeY] = Absorption_normalisingLV( atoms, laser, bg1, signalMask, imagePath);
        resultsArray = [atomNumber, opticalDensityMax, sizeX, sizeY];
        copyfile(imagePath, remotePath);
        disp([timestamp ' : ' num2str(atomNumber)]);
    else %double shutter mode
        %load images
        atoms = double(imread([bitwise.ObjImages, nameObj{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        laser = double(imread([bitwise.RefImages, nameRef{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        bg1 = double(imread([bitwise.BgImages, nameBG1{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
        pause(2)
        bg2 = double(imread([bitwise.BgImages, newFileBG{1}],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
      
        %Set the path for the analysed imaged to be saved to
        [p, name, ext] = fileparts(nameObj{1});
        timestamp = name(1:14);
        imagePath = [bitwise.Processed, timestamp, ' MLAbsorption.tif'];
        remotePath= [imaging.Processed, timestamp, ' MLAbsorption.tif'];
        
        %Analyse image
        [atomNumber, opticalDensityMax, sizeX, sizeY, opticalDensity] = Absorption_normalising_DSLV(atoms, laser, bg1, bg2, signalMask, imagePath);
        resultsArray = [atomNumber, opticalDensityMax, sizeX, sizeY]; 
        copyfile(imagePath, remotePath);
        disp([timestamp ' : ' num2str(atomNumber)]);
    end
        %Write results into the result file.
        writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray);
        %Write results into the result file on remote imaging drive
        writeAnalysisResultsToFile('Results.txt', timestamp, resultsArray, imaging.Processed);
        
        %Recount number of images stored
        refFiles=dir([bitwise.RefImages,'*Ref.tif']);
        numberOfRefImages = length({refFiles.name}); 
        
        %remove processed image from the stack
        nameObj(1) = [];
        nameRef(1) = [];
        nameBG1(1) = [];
        newFileBG(1) = [];
        mode(1) = [];
        k=k+1; 



end