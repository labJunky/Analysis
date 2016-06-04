function [ atomNumber, sizeX, sizeY, centreX, centreY] = FluorescenceSingleImage( atomImage, ROI, varargin )
%FLUORESCENCE Analyse a fluorescene Image
%   AtomImage is the image of the laser with atoms,
%   the laserImage is subtracted to elimiate background scatter light.
%   Atom number is then calculated with the size.
%   Note 'x' coordinate is in the vertical direction

% set defaults for optional inputs
imagePath='';
plots=0;
optargs = {plots, imagePath};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
if strcmp(imagePath,'');
    save=0;
else save=1;
end
optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[plots,imagePath] = optargs{:};

%Set ROI, a list given from labview.
%Note matlab indexs vectors differently than labview
ROIx=ROI(3):ROI(4);
ROIy=ROI(1):ROI(2);

% Subract background
image = atomImage(ROIx, ROIy);

% Parameters of the imaging system and camera.
% In this case a Princeston instruments ProEm 512.
aperture = 2*25.4*1e-3; %aperture of lens
distance = 0.14; %lens distance to mot
collectedFraction = aperture^2/(16*distance^2);
quantumEfficiency = 0.74; %ProEm CCD
ADUfactor = 3.35; %electons per count at 5MHz and gain 3
gain = 1; %Em Gain is set in the settings of camera and can change!
countsPerPhoton = quantumEfficiency*gain/ADUfactor;
transmission = 0.98; % optics transmission at 780nm
calibration = 1/(collectedFraction*countsPerPhoton*transmission);

%ExposureTime currently used. This is a variable though, and some how need
%to be inputed to this script.
exposureTime = 3000*1e-6;

% ScatteringRate
lambda = 780*1e-9;
gamma = 2*pi*6.065*1e6; % Hz
detuning=-12*1e6;
s = 16; %s is the Saturation parameter I/Isat, Isat = 1.67 mW/cm^2

scatteringRate = (gamma/2)*(s/(1+4*(detuning/gamma)^2+s)); 

% gaussian distribution in x direction
xdata1=sum(image,1);

X1=1:length(xdata1);
Y1=xdata1(X1);

[maxValue1,maxIndex1] = max(xdata1);
initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,60];

options = optimset('Algorithm','levenberg-marquardt','Largescale','off');

x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);

Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);

% gaussian distribution in y direction
xdata2=sum(image,2);
xdata2=xdata2';

X2=1:length(xdata2);
Y2=xdata2(X2);

[maxValue2,maxIndex2] = max(xdata2);
initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,60];

options = optimset('Algorithm','levenberg-marquardt','Largescale','off');

x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);

Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);

%plot fits
if plots==1;
    figure(1), imagesc(image);
    figure(2), plot(X2,Y2,'+r',X2,Y2_new,'b');
    figure(3), plot(X1,Y1,'+r',X1,Y1_new,'b');
end

integratedCounts = sum(sum(image));

%Calculate Atom number
atomNumber = ( calibration/(exposureTime*scatteringRate) )*integratedCounts;

% Find cloud size in mm
% pixel size: pixis 13, ProEm 16, pixelfly 6.45 um
pixelSize = 16*1e-6;
demagnification = 140/200;
sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;
sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;

centreX=x1(3);%*pixelSize*demagnification*1000;
centreY=x2(3);%*pixelSize*demagnification*1000;

%is the centre of the cloud within the ROI?
%If not maybe there is no cloud?
% if or((centreX+min(ROIx))>max(ROIx),(centreX+min(ROIx))<min(ROIx)) && or((centreY+min(ROIy))>max(ROIy),(centreY+min(ROIy))<min(ROIy));
%     [atomNumber, sizeX, sizeY, centreX, centreY] = deal(0);
% end

if save==1;
    imwrite(uint16(image),imagePath);
end
end

