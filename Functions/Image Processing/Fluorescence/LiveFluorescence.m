% This script estimates atom number and cloud size
% on live images. 
% Images are provided by labview as a 2D array of doubles,
% called 'imageArray'.
% Output are three doubles, 'atomNumber', 'sizeX' and 'sizeY'.

% Set Directory and Load image
directory='C:\Users\Administrator\Desktop\Crete\Matlab\Image Processing\Fluorescence';
directory='Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Loading\140122\Images\ObjectImages';
objImg=strcat([directory,'\140122_1144_01 Image 0.tif']);

ROIy = [314:650]; % This is labeled signalx in the settings file
ROIx = [419:647]; % This is labeled signaly in the settings file

% Read in image pixel values into matries
objImg = double(imread(objImg));
figure(1);
imagesc(objImg(ROIx,ROIy));
objImg = objImg(ROIx,ROIy);


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
exposureTime = 3000*1e-6;

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
bg = mean(mean(objImg(10,:)));
%plot(objImg(10,:))

image = objImg-bg;

integratedCounts = sum(sum(image));
%absimagecount=integratedCounts*scatteringRate/(6.45e-6)^2;
%Calculate Atom number
atomNumber = ( calibration/(exposureTime*scatteringRate) )*integratedCounts
%subplot(3,2,1), imagesc(image(200:800,400:1000)), 
%subplot(3,2,2), plot(image(:,691));
%subplot(3,2,3), plot(image(507,:));
%axes('position',[0,0,1,1],'visible','off');
%text(.5,.25,['Atom Number = ',num2str(atomNumber/10^9),' x 10^9']);


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
figure, plot(X2,Y2,'+r',X2,Y2_new,'b');
figure, plot(X1,Y1,'+r',X1,Y1_new,'b');


% Find cloud size in mm
pixelSize = 13*1e-6;
sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*1000;
sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*1000;

directory='Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Loading\140122\Scripts';
scriptFile=strcat([directory,'\140122_1144_01 MOT U-wire_DP.xml']);
%Load the script.
scriptDoc = loadScript(scriptFile);
%Name the parameter you want to change and its new value
parameterName = 'MOT_Loading_Time';
loadingTime = readScriptParameter(scriptDoc, parameterName);

