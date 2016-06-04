function [time, standard] = removeFringesOverDirectory(directory, startTS, stopTS)
% Given the path to a directory say '...\2012\1204\120425'
% analyse the atom images and remove the fringes given
% the set of reference images in the 'Image\RefImage' subdirectory.
% startTS is the timestamp of the first image you would like to include in
% the reference stack.
% stopTS is the timestamp of the last image to included in the reference
% stack.

%TODO: Save the analysed results into the results text file.
%TODO: Moving Stack of reference images.
%TODO: Use optional inputs that set a range of timestamps in the directory
%      to analyse. 

sep = filesep;
imageDir = [directory, sep, 'Images', sep];
directoryOI= [imageDir,'ObjectImages', sep];
directoryRI= [imageDir,'RefImages', sep];
directoryBG= [imageDir,'BGImages', sep];
saveDir = [imageDir, 'MatlabProcessed', sep];

%Get all image file names
refFiles=dir([directoryRI,'*Ref.tif']);
files = {refFiles.name};
includedFiles = includeBetween(startTS, stopTS, files);

%Create two lists with valid reference and bg images inside. 
[refList, bgList] = getValidRefBGImages(includedFiles, directoryBG);
for i=1:length(refList)
    refList{i} = [directoryRI refList{i}];
    bgList{i} = [directoryBG bgList{i}];
end

%Define a ROI, which we will crop the image with, and a signalMask
[ROIx, ROIy, signalMask] = getROIFromFile();

%load the reference basis images.
%Note that we are taking all of the images in the directory!
%This may be very memory intensive. 
%For larger directories, I should use a stack of first 50 images
%and then for every 10 atom images analysed, move this window of 50,
%over 5. ie. Drop the first 5 images and an addition 5 images into the
%stack.
t = cputime;
[R, basisVectors,k, bgmask] = loadReferenceStack(refList, bgList, ROIx, ROIy, signalMask);
refload = cputime - t;

atomFiles=dir([directoryOI,'*Obj.tif']);
files2 = {atomFiles.name};
includedFiles2 = includeBetween(startTS, stopTS, files2);
[atomList, atomBGList] = getValidObjBGImages(includedFiles2, directoryBG);
atomList;
for n=1:length(atomList)
    atomListn{n} = [directoryOI atomList{n}];
    atomBGListn{n} = [directoryBG atomBGList{n}];
end
%There could be many atom images in a directory, this would be extremely 
%memory intensive if we were to store all the images into a vector and 
%process them.
%So lets break it down into a set of 2 images at a time, and loop over the
%whole directory. 

atomNumber = zeros(length(atomListn));
opticalDensityMax = zeros(length(atomListn));
sizeX = zeros(length(atomListn));
sizeY = zeros(length(atomListn));
time = [];
standard = [];
stop = length(atomListn);
for i=1:stop
    t1 = cputime;
    A = loadAtomImageStack(atomListn(i), atomBGListn(i), ROIx, ROIy);
    xdim = length(ROIx);
    ydim = length(ROIy);
    %Calcalate the best weighted sum of reference images for each atom image.
    optrefimages = optimiseReferenceImage(A, R, basisVectors, k, xdim, ydim, 1);
   
    atomImage = reshape(A(:,:),xdim,ydim);
    optRef = reshape(optrefimages(1,:,:),xdim,ydim,1);
    refImage = reshape(R(:,i),xdim,ydim,1);
    
    [p, name, ext] = fileparts(atomListn{i});
    imagePath = [saveDir, name(1:14), ' FR_46.tif'];
    
    [atomNumber(i), opticalDensityMax(i), sizeX(i), sizeY(i)] =  Absorption_DSLV(atomImage, optRef, signalMask, imagePath);

    time(i) = cputime -t1;
    
%     figure(1)
%     subplot(2,1,1)
%     imagesc(atomImage./optRef,[0,1.5]);
%     subplot(2,1,2)
%     imagesc(atomImage./refImage,[0,1.5]);
%  
    divImage = (atomImage)./optRef;
    %divOrig = (atomImage)./(refImage);
    d1 = divImage(1:200,1:200);
   % d2 = divOrig(1:100,1:100);
    standard(i) = std2(d1(:));
%     figure(2)
%     subplot(2,1,1)
%     hist(d1(:),0.5:0.01:1.5);
%     set(gca, 'XLim', [0.5,1.5]);
%     subplot(2,1,2)
%     hist(d2(:),0.5:0.01:1.5);
%     set(gca, 'XLim', [0.5,1.5]);
%     
%     figure(3)
%     subplot(4,1,1)
%     plot(atomNumber)
%     subplot(4,1,2)
%     plot(opticalDensityMax)
%     subplot(4,1,3)
%     plot(sizeX);
%     subplot(4,1,4)
%     plot(sizeY)

end



