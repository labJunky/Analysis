% This script estimates atom number and cloud size
% on live images. 
% Images are provided by labview as a 2D array of doubles,
% called 'imageArray'.
% Output are three doubles, 'atomNumber', 'sizeX' and 'sizeY'.
clear all
% Set Directory and Load image
%directory='C:\Users\Administrator\Desktop\Crete\Matlab\Image Processing\Fluorescence';
%direct='Y:\Data\University stuff\CQT\Data\AIN Chip Data\140210 ChipMOT Temperature\';
direct ='S:\AtomChip Data\2014\1403\140304\';
start = '1904_16';
stop = '1912_12';

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
atomNumber=[];
loadingTime=[];
sizeX=[];
sizeY=[];
centreX=[];
centreY=[];
for i=1:imageN;
    timestamp = includedFiles{i}(1:14);

    objImg=strcat([directoryO,'\',timestamp,'  Obj.tif']);
    refImg=strcat([directoryRef,'\',timestamp,'  Ref.tif']);
    %bgImg=strcat([directoryBg,'\',timestamp,'  BG.tif']);
    
    ROIy = [1:512]; % This is labeled signalx in the settings file
    ROIx = [580:1040]; % This is labeled signaly in the settings file
    ROI = [10,512,580,1040];
    % Read in image pixel values into matries
    objImg = double(imread(objImg));
    refImg = double(imread(refImg));
    figure(1)
    image = objImg(ROIx, ROIy) - refImg(ROIx,ROIy);
    imagesc(image)
    %bgImg= double(imread(bgImg));
    [atomNumber(i), sizeX(i), sizeY(i), centreX(i), centreY(i)] = fluorescence(objImg, refImg, ROI);
    
    scriptFile=strcat([directoryS, includedScripts{i}]);
    %Load the script.
    scriptDoc = loadScript(scriptFile);
    %Name the parameter you want to change and its new value
    parameterName = 'Expansion_Time';
    expansionTime(i) = readScriptParameter(scriptDoc, parameterName); % in mseconds

     resultsArray = [expansionTime(i), atomNumber(i), sizeX(i), sizeY(i)];
     
     %pause()
     writeAnalysisResultsToFile('MOT Temperature.txt', timestamp, resultsArray, directoryProcessed);
end
includedScripts{1}(1:15)=[];
includedScripts{1}(end-6:end)=[];
scriptName = includedScripts{1};
savepath=[directoryProcessed, startTS,'-', stopTS(8:end) ' Temperture ', scriptName,'.pdf'];
[initialCloudSize, temperature, psd, residual]=FitTemperature(expansionTime(1:6)*1e-3, sizeX(1:6), scriptName, savepath, atomNumber(1:6), sizeY(1:6))
%      %writeAnalysisResultsToFile('MOT Gradient.txt', timestamp, resultsArray, directoryR);
handle=figure(2)    
newImage = image;
newImage(1:end,1:end)=0;
for i=1:length(centreX(1:6))
    %matlab indexs other way
    newImage(round(centreY(i)),round(centreX(i)))=1*(i+1);
end
imagesc(newImage)
set(handle,'name',[startTS,'-', stopTS(8:end) ' Trajectory ', scriptName,'.pdf']);
title(['Trajectory of MOT during expansion (blue to red)'])
savepath=[directoryProcessed, startTS,'-', stopTS(8:end) ' Trajectory ', scriptName,'.pdf'];
saveas(handle,savepath);