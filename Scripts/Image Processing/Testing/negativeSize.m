% Why do we get negative atom cloud sizes from the fitting routine?

%Load an image

myDir = directory();
myDir = myDir.getDirectoryOnDate('bitwise', '120712');

timeStamp = '120712_1955_20';

imageFile = dir([myDir.Processed timeStamp '*.tif']);
imageFile = [myDir.Processed imageFile.name];
[ROIx, ROIy, signalMask] = getROIFromFile();
ROIx=signalMask(3):signalMask(4);
ROIy=signalMask(1):signalMask(2);

% Images are scaled by (2^12-1), which we must divide out:
odFull = double(imread(imageFile))/(2^12-1);
od = odFull(ROIx, ROIy);

summedOd = sum(sum(od));

figure(1)
imagesc(od);
%Camera and Imaging 
[pixelSize, magnification] = getOpticalSettingsFromFile();

% Rb87 D2 Line constants
lambda = 780*1e-9;
gamma =6.065*1e6; %Rb87 D2 Natural Line Width (FWHM) in Hz (omitting the 2pi)
detuning=0; 
sigma = ((3*lambda^2)/(2*pi))*(1/(1+((2*detuning)/gamma)^2));

atomNumber = summedOd*magnification^2*pixelSize^2/sigma
atomNImage = od*magnification^2*pixelSize^2/sigma;

% gaussian distribution in x direction
xdata1=sum(od,1);
X1=1:length(xdata1);
Y1=xdata1(X1);
[maxValue1,maxIndex1] = max(xdata1);
initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,10];
options = optimset('Display', 'off');
x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);

Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);

% gaussian distribution in y direction
xdata2=sum(od,2);
xdata2=xdata2';
X2=1:length(xdata2);
Y2=xdata2(X2);
[maxValue2,maxIndex2] = max(xdata2);
initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,200];
options = optimset('Display', 'off');
x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);

Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);

% plot fits
figure(2)
plot(X2,Y2,'+r',X2,Y2_new,'b');
figure(3)
plot(X1,Y1,'+r',X1,Y1_new,'b');

% Find cloud size in mm
sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification
sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification