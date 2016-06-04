function [R, basisVectors,k, bgmask] = loadNewestRefStack(numberOfImages)

[dataDir, todaysDir] = getDirectory();
directory = todaysDir;

%dateStr = '2012/1205/120514/';
%directory = [dataDir, dateStr];

sep = filesep;
imageDir = [directory, 'Images', sep];
directoryOI= [imageDir,'ObjectImages', sep];
directoryRI= [imageDir,'RefImages', sep];
directoryBG= [imageDir,'BGImages', sep];
saveDir = [imageDir, 'MatlabProcessed', sep];

%Get all image file names
refFiles=dir([directoryRI,'*Ref.tif']);
files = {refFiles.name};
%assuming more than n reference images in the directory, 
%take last n images.
includedFiles = files(length(files)-(numberOfImages-1):end);
%Create two lists with valid reference and bg images inside. 
[refList, bgList] = getValidRefBGImages(includedFiles, directoryBG);
length(refList);
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
