function [atomNumberX, atomNumberY, sizeX, sizeY, centreX, centreY, opticalDensity, xSize] = Absorption_2(atoms, laser, crop, ROI, varargin);

%Call Absorption Imaging Analysis Script 
%Inputs are the two image arrays.
%The output is the optical density image save to the "imagePath"

% set defaults for optional inputs
imagePath='';
plots=1;
optargs = {plots, imagePath};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.

optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[plots,imagePath] = optargs{:};
if strcmp(imagePath,'');
    save=0;
else save=1;
end

%ROI
ROIx=ROI(3):ROI(4);
ROIy=ROI(1):ROI(2);
cropx = crop(3):crop(4);
cropy = crop(1):crop(2);
%Camera and Imaging
pixelSize = 6.45e-6;
%magnification = 150/100; %mot
magnification = 200/100; %cell
%magnification = 0.501101; %old


% Rb87 D2 Line constants
lambda = 780*1e-9;
gamma =6.065; %Rb87 D2 Natural Line Width (FWHM) in MHz (omitting the 2pi)
detuning=0; %Imaging laser detuning MHz
%s = 0.03; %Saturation parameter
i=0.077/(pi*2.54^2);
%i=0.150/(pi*2.54^2); %old
isat=1.67; %mW/cm^2
s=i/isat;

scat = (7/15)*((3*lambda^2)/(2*pi))*(1/(1+4*(detuning/gamma)^2+s));
%note (7/15) from Kai Dieckmann thesis
%From a summation of Clesch Gordon Coeffs for the levels on the D2 line we
%use for imaging. See
%'/Users/paul/Data/University stuff/BEC/Math/Rb properties/Optical ...
%Properties of Rb87 (Jook).nb'


% Read in image pixel values into matries
objImgFull = atoms(cropx,cropy);
refImgFull = laser(cropx,cropy);
objImg =objImgFull(ROIx,ROIy);
refImg =refImgFull(ROIx,ROIy);

fdim=2;

IMGNormalizationTOT=[];
REFNormalizationTOT=[];

%Object Image Normalization
tmp=objImgFull;
tmp(ROIx,ROIy)=0;
IMGNormalization=sum(sum(tmp));
IMGNormalizationTOT=[IMGNormalizationTOT,IMGNormalization];

%Reference Image Normalization
tmp=refImgFull;
tmp(ROIx,ROIy)=0;
REFNormalization=sum(sum(tmp));
REFNormalizationTOT=[REFNormalizationTOT,REFNormalization];


motImageFinal = objImg;
backgroundImageFinal = refImg;
motFull = objImgFull;
backgroundImageFinalFull = refImgFull;
%Remove bad data points:
%Find the points in backgroundImageFinal that are less than or equal to
%zero:
BadIndex=find(backgroundImageFinal<=0);
%Set the values of motImageFinal and backgroundImageFinal equal to one for 
%the coordinates where the background is bad. This avoids taking the
%logarithm of something divided by zero, or a negative value.
motImageFinal(ind2sub(size(motImageFinal),BadIndex))=1;
backgroundImageFinal(ind2sub(size(backgroundImageFinal),BadIndex))=1;
%repeat for the image with the atoms to prevent taking the logarithm of a
%negative value or zero.
BadIndex2=find(motImageFinal<=0);
motImageFinal(ind2sub(size(motImageFinal),BadIndex2))=1;
backgroundImageFinal(ind2sub(size(backgroundImageFinal),BadIndex2))=1;
%motImageFinal=objImg;
%backgroundImageFinal=refImg;

motImageFinal = double(motImageFinal)./IMGNormalization;
backgroundImageFinal = double(backgroundImageFinal)./REFNormalization;

dividedImageFinal = double(motImageFinal./backgroundImageFinal);
dividedImageFinalFull = motFull./backgroundImageFinalFull;
opticalDensity = -log(dividedImageFinal);
opticalDensityFull = -log(dividedImageFinalFull);
summedOpticalDensity = sum(sum(opticalDensity));
%imwrite( (opticalDensityFull) ,imagePath,'TIFF'); %scaled for 8 bit image
opticalDensityMax = max(max(dividedImageFinal));

atomNumber = (summedOpticalDensity*magnification^2*pixelSize^2)/scat;

if save==1;
    od1=opticalDensity;%-min(min(opticalDensity));
    od2 = (2^16-1)*od1;%/max(max(od1));
    imwrite(uint16(od2),imagePath);
end
  
xdata1=sum(opticalDensity,1);
X1=1:length(xdata1);
Y1=xdata1(X1);
[maxValue1,maxIndex1] = max(xdata1);
initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,60];
options = optimset('Largescale','off');
x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);

Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);

% gaussian distribution in y direction
xdata2=sum(opticalDensity,2);
xdata2=xdata2';
X2=1:length(xdata2);
Y2=xdata2(X2);
[maxValue2,maxIndex2] = max(xdata2);
initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,60];
options = optimset('Largescale','off');
x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);

Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);

% Find the atoms number
%atomNumberX = summedOpticalDensity*magnification^2*pixelSize^2/scat;
atomNumberX = sqrt(2*pi)*x1(2)*x1(4)*(magnification^2*pixelSize^2)/scat;
atomNumberY = sqrt(2*pi)*x2(2)*x2(4)*(magnification^2*pixelSize^2)/scat;

% Find cloud size in mm
%sizeX = x1(4)*9.8*1e-3;%(2*sqrt(log(2)))*pixelSize*1000*magnification;MOT
%sizeY = x2(4)*9.8*1e-3;%(2*sqrt(log(2)))*pixelSize*1000*magnification;MOT
sizeX=x1(4)*12.9*1e-3;%*pixelSize*1000*magnification; %cell
sizeY=x2(4)*12.9*1e-3;%*pixelSize*1000*magnification; %cell
centreX = x1(3);
centreY = x2(3);

%Look at a slice of data through the peak along the x-axis
%Find the size for comparision to the sum data. 
%This can help eliminate a tail from the size data.

% gaussian distribution in x direction
%Apply a smoothing guassian filter to the opticalDensity
%to reduce noise
im=imgaussfilt(opticalDensity,2);
[value, location] = max(im(:));
[row,column] = ind2sub(size(im),location);

xdata3=opticalDensity(row,1:end);
X3=1:length(xdata3);
Y3=xdata3(X3);
[maxValue3,maxIndex3] = max(xdata3);
initialCoeff3 = [0,max(xdata3)-min(xdata3),maxIndex3,60];
options = optimset('Largescale','off');
x3=lsqnonlin(@fit_simp,initialCoeff3,[],[],options,X3,Y3);

Y3_new = x3(1) + x3(2)*exp(-0.5*((X3-x3(3))/x3(4)).^2);
xSize = x3(4)*9.8*1e-3;

% plot fits
if plots==1;
    figure(6), 
    subplot(2,2,2);
    plot(X2,Y2,'+r',X2,Y2_new,'b');
   % axis([0 ROI(4)-ROI(3) 0 600])
    view(90,90)
    subplot(2,2,3)
    plot(X1,Y1,'+r',X1,Y1_new,'b');
  %  axis([0 ROI(4)-ROI(3) 0 600])
    subplot(2,2,1);
    imagesc(opticalDensity);
    subplot(2,2,4)
    plot(X3,Y3,'+r',X3,Y3_new,'b');
    %plot(opticalDensity(row,1:end))
    %figure(2)
    %plot(od2(1:end,column))
end