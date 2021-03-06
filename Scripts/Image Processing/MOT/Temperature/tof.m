
% This script estimates atom number and cloud size
% on live images. 
% Images are provided by labview as a 2D array of doubles,
% called 'imageArray'.
% Output are three doubles, 'atomNumber', 'sizeX' and 'sizeY'.

% Set Directory and Load image
%directory='C:\Users\Administrator\Desktop\Crete\Matlab\Image Processing\Fluorescence';
directoryO='S:\AtomChip Data\2014\1401\140130\Images\ObjectImages\';
directoryRef='S:\AtomChip Data\2014\1401\140130\Images\RefImages\';
directoryBg='S:\AtomChip Data\2014\1401\140130\Images\BGImages\';
directoryS='S:\AtomChip Data\2014\1401\140130\Scripts\';
directoryProcessed='S:\AtomChip Data\2014\1401\140130\';
%Get image file names
objfiles=dir([directoryO,'*.tif']);
reffiles=dir([directoryRef,'*.tif']);
bgfiles=dir([directoryBg,'*.tif']);
filesO = {objfiles.name};
filesRef={reffiles.name};
filesBg={bgfiles.name};

startTS = '140130_1905_20';
stopTS = '140130_1934_44';

includedFiles = includeBetween(startTS, stopTS, filesO);

imageN = length(includedFiles);
atomNumber=[];
loadingTime=[];
sizeX=[];
sizeY=[];
for i=1:imageN;
    timestamp = includedFiles{i}(1:14);

    objImg=strcat([directoryO,'\',timestamp,'  Obj.tif']);
    refImg=strcat([directoryRef,'\',timestamp,'  Ref.tif']);
    bgImg=strcat([directoryBg,'\',timestamp,'  BG.tif']);

    ROIy = [136:397]; % This is labeled signalx in the settings file
    ROIx = [580:841]; % This is labeled signaly in the settings file

    % Read in image pixel values into matries
    objImg = double(imread(objImg));
    refImg = double(imread(refImg));
    bgImg= double(imread(bgImg));
    figure(1);
    imagesc(objImg(ROIx,ROIy)-refImg(ROIx,ROIy));
    image = objImg(ROIx,ROIy)-refImg(ROIx,ROIy);

    % Calibration is calculated from relating the Absorption imaging atom number
    % to the fluorescence measured photon count (taking out contributions from
    % exposure time and scattering rate.
    % For now I took it as 1 over the 
    % transmition of the optics = 0.99 which is a guess.
    % counts per photon - quantum efficiency of pixefly in normal mode = 0.1.
    % Collection efficiency of the imaging optics = 0.0017 or 
    % aperture Diameter sqaured / 16*(distance sqaured)
    % This turn out to be:
    calibration = 525.164;

    %ExposureTime currently used. This is a variable though, and some how need
    %to be inputed to this script.
    exposureTime = 300*1e-6;

    % ScatteringRate
    lambda = 780*1e-9;
    gamma = 2*pi*6.065*1e6; % Hz
    detuning=-12*1e6;
    s = 16; %s is the Saturation parameter I/Isat, Isat = 1.67 mW/cm^2

    scatteringRate = (gamma/2)*(s/(1+4*(detuning/gamma)^2+s));

    % IntegratedCounts is the difficult part of the processing.
    % The background needs to be estimated.
    % The atom cloud found and integrated over.

    % Estimate background 
    %bg = mean(mean(objImg(10,:)));
    %plot(objImg(1000,:)-refImg(1000,:);

    %image = objImg-bg;

    integratedCounts = sum(sum(image));
    %absimagecount=integratedCounts*scatteringRate/(6.45e-6)^2;
    %Calculate Atom number
    atomNumber(i) = ( calibration/(exposureTime*scatteringRate) )*integratedCounts;
    %subplot(3,2,1), imagesc(image(200:800,400:1000)), 
    %subplot(3,2,2), plot(image(:,691));
    %subplot(3,2,3), plot(image(507,:));
    %axes('position',[0,0,1,1],'visible','off');
    %text(.5,.25,['Atom Number = ',num2str(atomNumber/10^9),' x 10^9']);

% 
% 
    % gaussian distribution in x direction
    xdata1=sum(image,1);

    X1=1:length(xdata1);
    Y1=xdata1(X1);

    [maxValue1,maxIndex1] = max(xdata1);
    initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,60];

    options = optimset('Largescale','off');

    x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);

    Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);

    % gaussian distribution in y direction
    xdata2=sum(image,2);
    xdata2=xdata2';

    X2=1:length(xdata2);
    Y2=xdata2(X2);

    [maxValue2,maxIndex2] = max(xdata2);
    initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,60];

    options = optimset('Largescale','off');

    x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);

    Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);

    %plot fits
    figure(2), plot(X2,Y2,'+r',X2,Y2_new,'b');
    figure(3), plot(X1,Y1,'+r',X1,Y1_new,'b');


    % Find cloud size in mm
    pixelSize = 13*1e-6;
    demagnification = 140/200;
    sizeX(i) = x1(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;
    sizeY(i) = x2(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;

    scriptFile=strcat([directoryS, timestamp, ' MOT U-wire_Dp.xml']);
    %Load the script.
    scriptDoc = loadScript(scriptFile);
    %Name the parameter you want to change and its new value
    parameterName = 'Expansion_Time';
    expansionTime(i) = readScriptParameter(scriptDoc, parameterName); % in mseconds

     resultsArray = [expansionTime(i), atomNumber(i), sizeX(i), sizeY(i)];
end
%savepath=[directoryProcessed, 'MOT U-wire.jpg'];
[initialCloudSize, temperature, psd, residual]=FitTemperature(expansionTime*1e-3, sizeX, 'MOT U-wire', savepath, atomNumber, sizeY)
     %writeAnalysisResultsToFile('MOT Gradient.txt', timestamp, resultsArray, directoryR);
% end