% This script estimates atom number and cloud size
% on live images. 
% Images are provided by labview as a 2D array of doubles,
% called 'imageArray'.
% Output are three doubles, 'atomNumber', 'sizeX' and 'sizeY'.
clear all
% Set Directory and Load image
%directory='C:\Users\Administrator\Desktop\Crete\Matlab\Image Processing\Fluorescence';
%direct='Y:\Data\University stuff\CQT\Data\AIN Chip Data\140210 ChipMOT Temperature\';
direct ='S:\AtomChip Data\2014\1402\140214\';
start = '1218_39';
stop = start

dateString= fliplr(direct(end-1:-1:end-6));
startTS = [dateString,'_', start];
stopTS = [dateString,'_',stop];

directoryO=[direct 'Images\ObjectImages\'];
directoryRef=[direct 'Images\RefImages\'];
directoryBg=[direct '\Images\BGImages\'];
directoryS=[direct 'Scripts\'];
directoryProcessed=direct;
%Get image file names
objfiles=dir([directoryO,'*.tif']);
reffiles=dir([directoryRef,'*.tif']);
bgfiles=dir([directoryBg,'*.tif']);
scripts=dir([directoryS,'*.xml']);
filesO = {objfiles.name};
filesRef={reffiles.name};
filesBg={bgfiles.name};
filesScript={scripts.name};

includedFiles = includeBetween(startTS, stopTS, filesO);
includedScripts = includeBetween(startTS, stopTS, filesScript);

imageN = length(includedFiles);
timestamp = includedFiles{1}(1:14);

objImg=strcat([directoryO,'\',timestamp,'  Obj.tif']);
refImg=strcat([directoryRef,'\',timestamp,'  Ref.tif']);
%bgImg=strcat([directoryBg,'\',timestamp,'  BG.tif']);

ROIy = [1:512]; % This is labeled signalx in the settings file
ROIx = [580:1040]; % This is labeled signaly in the settings file
ROI = [10,512,580,1040];
% Read in image pixel values into matries
objImg = double(imread(objImg));
refImg = double(imread(refImg));

%bgImg= double(imread(bgImg));
[atomNumber, sizeX, sizeY, centreX, centreY] = fluorescence(objImg, refImg, ROI);

 resultsArray = [atomNumber, sizeX, sizeY];
      