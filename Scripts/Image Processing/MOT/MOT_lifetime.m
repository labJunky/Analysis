
clear all
% Set Directory and Load image
direct ='R:\AtomChip Data\Lab Data\MOT Measurements\140307 NoTAMOT lifetime\';
%Get image file names
objfiles=dir([direct,'*.tif']);
imageN = 500;
objImg=strcat([direct,objfiles.name]);

ROI = [250,340,155,190];
% Read in image pixel values into matries

for index=1:imageN;
    image = double(imread(objImg, index));
    [atomNumber(index), sizeX(index), sizeY(index), centreX(index), centreY(index)] = FluorescenceSingleImage(image, ROI,1);
    %resultsArray = [atomNumber(index), sizeX(index), sizeY(index)];
end
time=[0:imageN-1]*290*1e-3;
figure(4)
plot(time(34:500),atomNumber(34:500))

initialCoeff1 = [2.7*1e4,4.6*1e4,20];
options = optimset('Algorithm','levenberg-marquardt','Largescale','off');
x1=lsqnonlin(@fit_MOT_lifetime,initialCoeff1,[],[],options,time(34:500),atomNumber(34:500));
lifetime = x1(3);
amplitude = x1(1)+x1(2)*exp(-1/x1(3)*time(34:500));
plot(time(34:500),atomNumber(34:500),'+r',time(34:500),amplitude,'b')
title('MOT Lifetime Switching off Dispensor, No TA')
xlabel('time (s)')
ylabel('AtomNumber (a.u.)')
text(50,4.2*10^4,['lifetime = ', num2str(lifetime), ' (s)', ', Pressure 7x10^-^1^0 mbar']);
