% image input
%pics=[80:90,100:120];
%pics=[1:83];
ROIx=160:1024;
ROIy=690:1030;
%ROIx=100:924;
%ROIy=100:1292;
RimSize=50;

%set directories
directoryOI='E:\AtomChip Data\2012\1203\120309\Images\ObjectImages\';
directoryRI='E:\AtomChip Data\2012\1203\120309\Images\RefImages\';
directoryBI='E:\AtomChip Data\2012\1203\120309\Images\BGImages\';

fdim=2;
filtersize=ones(fdim,fdim)/(fdim*fdim);

%Get image file names
objfiles=dir([directoryOI,'*Obj.tif']);

numberOfImages = 20;
objfiles = objfiles(length(objfiles)-14:length(objfiles));
timeStamps = objfiles(1:14);
timeStamps = timeStamps.name;
names = ['*', timeStamps, 'Ref.tif'];

Reffiles=dir([directoryRI,'*Ref.tif']);
BG1files=dir([directoryBI,'*BG1.tif']);
BG2files=dir([directoryBI,'*BG2.tif']);


Reffiles = Reffiles(length(Reffiles)-14:length(Rfiles));
BG1files = BG1files(length(BG1files)-14:length(BG1files));
BG2files = BG2files(length(BG2files)-14:length(BG2files));

pics = [1:length(objfiles)];

TotAtomNr=[];
IMGNormalizationTOT=[];
REFNormalizationTOT=[];
newpics=[];

for k=pics
% Read objImg and select ROI
objImgFull=strcat([directoryOI,objfiles(k).name]);
objImgFull =imread(objImgFull);
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
refImgFull=([directoryRI,Reffiles(k).name]);
refImgFull =imread(refImgFull);
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


bg1ImgFull=([directoryBI,BG1files(k).name]);
bg1ImgFull =imread(bg1ImgFull);
%bgImgFull =imfilter(bgImgFull,filtersize);
bg1Img=bg1ImgFull(ROIx,ROIy);
%imagesc(bgImg);
bg2ImgFull=([directoryBI,BG2files(k).name]);
bg2ImgFull =imread(bg2ImgFull);
%bgImgFull =imfilter(bgImgFull,filtersize);
bg2Img=bg2ImgFull(ROIx,ROIy);
%imagesc(bgImg);



motImageFinal = objImg - bg1Img;
backgroundImageFinal = refImg - bg2Img;
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
opticalDensity = -log(dividedImageFinal);
summedOpticalDensity = sum(sum(opticalDensity));


%Camera and Imaging 
pixelSize = 6.45e-6;
magnification = 80/140;

% Rb87 D2 Line constants
lambda = 780*1e-9;
gamma =6.065*1e6; %Rb87 D2 Natural Line Width (FWHM) in MHz (omitting the 2pi)
detuning=0; 
sigma = ((3*lambda^2)/(2*pi))*(1/(1+((2*detuning)/gamma)^2));

atomNumber = summedOpticalDensity*magnification^2*pixelSize^2/sigma;
TotAtomNr=[TotAtomNr,atomNumber];
figure(1)
imagesc(opticalDensity)
xlabel(['Atom number: ',num2str(atomNumber)])
pause(0.1)
if any(BadIndex)
    disp(['Bad  atom image: ', num2str(k)])
    imagesc(motImageFinal)
pause(0.1)
end
if any(BadIndex2)
    disp(['Bad  ref image: ', num2str(k)])
    imagesc(backgroundImageFinal)

pause (0.1)
end
end


figure(2)
subplot(2,1,1)
plot(TotAtomNr,'r')
subplot(2,1,2)
plot(pics,IMGNormalizationTOT/max(IMGNormalizationTOT),'b',...
    pics,REFNormalizationTOT/max(REFNormalizationTOT),'c')
disp(['Mean atom number: ',num2str(mean(TotAtomNr))])
disp(['Standard deviation in atom number: ',num2str(std(TotAtomNr))])

