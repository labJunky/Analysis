% Call Absorption Imaging Analysis Script 
% Inputs are the three image arrays, and a path.
% 'atom', 'laser', and 'bg', 'imagePath'
% 'imagePath will be use to save the optical density
% as an image TIFF.
% Read in image pixel values into matries.
% Output are three doubles
% 'atomNumber', 'sizeX', and 'sizeY'

% Add Matlab directory to search path
path(path,'D:/Code Projects/Matlab');

% Read in Arrays
objImg =atoms;
refImg =laser;
bgImg =bg;

% params to calculate cross section
lambda = 780*1e-9;
gamma = 3.7*1e7;
delta=0;
sigma = ((3*lambda^2)/(2*pi))*(1/(1+((2*delta)/gamma)^2));

% Subtract background from atoms, and from laser images
motImageFinal = objImg - bgImg;
backgroundImageFinal = refImg - bgImg;

% Find Pixels in the new background which equal 0, and set
% The corresponding pixel of the Atoms to 1. 
% This removes the infinities from the optical density.
% avoid 1/0, 0/0 errors (log(1) = 0)
motImageFinal(backgroundImageFinal==0)=1;
backgroundImageFinal(backgroundImageFinal==0)=1;
backgroundImageFinal(motImageFinal==0)=1;
motImageFinal(motImageFinal==0)=1;


% Weightage. Assume corners of mot and background images same; weigh rest
% of image accordingly

% At each edge of the Atoms image find the mean, and average them.
% Then divide the atoms image by that average.
edge=10;
weight0 = mean(mean(motImageFinal(1:edge,1:edge)))+...
    mean(mean(motImageFinal(1:edge,end-edge:end)))+...
    mean(mean(motImageFinal(end-edge:end,1:edge)))+...
    mean(mean(motImageFinal(end-edge:end,end-edge:end)));
motImageFinal=motImageFinal/weight0;

weight1 = mean(mean(backgroundImageFinal(1:edge,1:edge)))+...
        mean(mean(backgroundImageFinal(1:edge,end-edge:end)))+...
        mean(mean(backgroundImageFinal(end-edge:end,1:edge)))+...
        mean(mean(backgroundImageFinal(end-edge:end,end-edge:end)));
backgroundImageFinal=backgroundImageFinal/weight1;


% Find the optical density
% And integrate over it
dividedImageFinal = motImageFinal./backgroundImageFinal;
opticalDensity = -log(dividedImageFinal);
summedOpticalDensity = sum(sum(opticalDensity));
pixelSize = 6.45e-6;

%figure,imshow(opticalDensity);
% Write opticalDensity into a TIFF Image
% and save to the data file system
imwrite(opticalDensity,imagePath,'TIFF');

% Find the atoms number
atomNumber = summedOpticalDensity*pixelSize^2/sigma;

% gaussian distribution in x direction
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

% Find cloud size in mm
sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*1000;
sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*1000;