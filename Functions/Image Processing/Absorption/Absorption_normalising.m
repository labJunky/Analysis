function [atomNumber, opticalDensityMax, sizeX, sizeY] = Absorption_normalising( atoms, laser, bg1, ROI)


%Set ROI
ROIx=ROI(3):ROI(4);
ROIy=ROI(1):ROI(2);

RimSize=50;

fdim=2;
filtersize=ones(fdim,fdim)/(fdim*fdim);

IMGNormalizationTOT=[];
REFNormalizationTOT=[];

objImgFull = atoms;
%objImgFull= imfilter(objImgFull,filtersize);
objImg=objImgFull(ROIx,ROIy);
%imagesc(objImg);


%Object Image Normalization
LeftSide=sum(sum(objImgFull(:,1:RimSize)));
RightSide=sum(sum(objImgFull(:,end-RimSize:end)));
TopSide=sum(sum(objImgFull(1:RimSize,:)));
BottomSide=sum(sum(objImgFull(end-RimSize:end,:)));
%IMGNormalization=LeftSide+RightSide+TopSide+BottomSide;
tmp=objImgFull;
tmp(ROIx,ROIy)=0;
IMGNormalization=sum(sum(tmp));
IMGNormalizationTOT=[IMGNormalizationTOT,IMGNormalization];



% Read refImg and select ROI
refImgFull =laser;
%refImgFull=imfilter(refImgFull,filtersize);
refImg=refImgFull(ROIx,ROIy);
%imagesc(refImg);


%Reference Image Normalization
LeftSide=sum(sum(refImgFull(:,1:RimSize)));
RightSide=sum(sum(refImgFull(:,end-RimSize:end)));
TopSide=sum(sum(refImgFull(1:RimSize,:)));
BottomSide=sum(sum(refImgFull(end-RimSize:end,:)));
%REFNormalization=LeftSide+RightSide+TopSide+BottomSide;
tmp=refImgFull;
tmp(ROIx,ROIy)=0;
REFNormalization=sum(sum(tmp));
REFNormalizationTOT=[REFNormalizationTOT,REFNormalization];


bg1ImgFull = bg1;
%bgImgFull =imfilter(bgImgFull,filtersize);
bg1Img=bg1ImgFull(ROIx,ROIy);
%imagesc(bgImg);



motImageFinal = objImg - bg1Img;
backgroundImageFinal = refImg - bg1Img;
motFull = objImgFull - bg1ImgFull;
backgroundImageFinalFull = refImgFull - bg1ImgFull;

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

dividedImageFinal = motImageFinal./backgroundImageFinal;
dividedImageFinalFull = motFull./backgroundImageFinalFull;
opticalDensity = -log(dividedImageFinal);
opticalDensityFull = -log(dividedImageFinalFull);
summedOpticalDensity = sum(sum(opticalDensity))
%imwrite( (2^8*opticalDensityFull)/2^12 ,imagePath,'TIFF'); %scaled for 8 bit image
opticalDensityMax = max(max(opticalDensity));

%Camera and Imaging 
pixelSize = 6.45e-6;
magnification = 80/140;

% Rb87 D2 Line constants
lambda = 780*1e-9;
gamma =6.065*1e6; %Rb87 D2 Natural Line Width (FWHM) in MHz (omitting the 2pi)
detuning=0; 
sigma = ((3*lambda^2)/(2*pi))*(1/(1+((2*detuning)/gamma)^2));

atomNumber = summedOpticalDensity*magnification^2*pixelSize^2/sigma;
if any(BadIndex)
    atomNumber = 0;
end
if any(BadIndex2)
    atomNumber = 0;
end
if atomNumber <= 0
    atomNumber = 0;
end
%figure(1)
%imagesc(opticalDensity)
%xlabel(['Atom number: ',num2str(atomNumber)])

% gaussian distribution in x direction
xdata1=sum(opticalDensity,1);
X1=1:length(xdata1);
Y1=xdata1(X1);
[maxValue1,maxIndex1] = max(xdata1);
initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,100];
options = optimset('Largescale','off','Display', 'off');
x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);

Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);

% gaussian distribution in y direction
xdata2=sum(opticalDensity,2);
xdata2=xdata2';
X2=1:length(xdata2);
Y2=xdata2(X2);
[maxValue2,maxIndex2] = max(xdata2);
initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,100];
options = optimset('Largescale','off', 'Display', 'off');
x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);

Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);

% plot fits
%figure, plot(X2,Y2,'+r',X2,Y2_new,'b');
%figure, plot(X1,Y1,'+r',X1,Y1_new,'b');

% Find cloud size in mm
sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification;
sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification;