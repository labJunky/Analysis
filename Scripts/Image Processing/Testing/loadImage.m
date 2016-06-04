%Load an image

myDir = directory();
myDir = myDir.getDirectoryOnDate('bitwise', '120709');

timeStamp = '120709_1751_28 FR_2';

imageFile = dir([myDir.Processed timeStamp '*.tif']);
imageFile = [myDir.Processed imageFile.name];

image = double(imread(imageFile))./(2^12-1);
od = image(1:1000,1:1300);
clf(gcf)
figure(1);


surf(flipud(od),...
   'FaceColor','texturemap',...
   'EdgeColor','none',...
   'CDataMapping','scaled')
axis([1 1300 1 1000 0 8]);
colormap(hsv)
view(-35,30)
shadowplot x
shadowplot y
hold on;
planeimg = flipud(od);
minplaneimg = min(min(planeimg)); % find the minimum
scaledimg = (floor(((planeimg - minplaneimg) ./ ...
    (max(max(planeimg)) - minplaneimg)) * 255)); % perform scaling
 
% convert the image to a true color image with the jet colormap.
colorimg = ind2rgb(scaledimg,gray(256));
surf([1 1300], [1 1000], repmat(8, [2,2]),colorimg, 'FaceColor','texturemap')






% figure(1)
% imagesc(image(150:500,500:1000));
% opticalDensity = image(150:500,500:1000);
% %Camera and Imaging
% pixelSize = 6.45e-6;
% magnification = 80/140;
% 
% % Rb87 D2 Line constants
% lambda = 780*1e-9;
% gamma =6.065*1e6; %Rb87 D2 Natural Line Width (FWHM) in MHz (omitting the 2pi)
% detuning=0; 
% sigma = ((3*lambda^2)/(2*pi))*(1/(1+((2*detuning)/gamma)^2));
% % gaussian distribution in x direction
% xdata1=sum(opticalDensity,1);
% X1=1:length(xdata1);
% Y1=xdata1(X1);
% [maxValue1,maxIndex1] = max(xdata1);
% initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,60];
% options = optimset('Largescale','off');
% x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);
% 
% Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);
% 
% % gaussian distribution in y direction
% xdata2=sum(opticalDensity,2);
% xdata2=xdata2';
% X2=1:length(xdata2);
% Y2=xdata2(X2);
% [maxValue2,maxIndex2] = max(xdata2);
% initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,60];
% options = optimset('Largescale','off');
% x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);
% 
% Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);
% 
% % plot fits
% %figure, plot(X2,Y2,'+r',X2,Y2_new,'b');
% %figure, plot(X1,Y1,'+r',X1,Y1_new,'b');
% 
% % Find cloud size in mm
% sizeX = x1(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification;
% sizeY = x2(4)*(2*sqrt(log(2)))*pixelSize*1000*magnification;