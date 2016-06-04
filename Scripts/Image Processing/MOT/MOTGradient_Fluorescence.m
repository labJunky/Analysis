% 
% % This script estimates atom number and cloud size
% % on live images. 
% % Images are provided by labview as a 2D array of doubles,
% % called 'imageArray'.
% % Output are three doubles, 'atomNumber', 'sizeX' and 'sizeY'.
% 
% % Set Directory and Load image
% %directory='C:\Users\Administrator\Desktop\Crete\Matlab\Image Processing\Fluorescence';
% directory='Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Gradient\Images\ObjectImages';
% directoryS='Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Gradient\Scripts';
% directoryR='Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Gradient\';
% 
% directoryOI= [directory,'\'];
% %Get image file names
% objfiles=dir([directoryOI,'*.tif']);
% files = {objfiles.name};
% 
% startTS = '140122_2130_26';
% stopTS = '140122_2300_24';
% 
% includedFiles = includeBetween(startTS, stopTS, files);
% 
% imageN = length(includedFiles);
% atomNumber=[];
% loadingTime=[];
% sizeX=[];
% sizeY=[];
% for i=imageN-1:imageN;
%     timestamp = includedFiles{i}(1:14);
% 
%     objImg=strcat([directory,'\',timestamp,' Image 0.tif']);
% 
%     ROIy = [314:650]; % This is labeled signalx in the settings file
%     ROIx = [370:647]; % This is labeled signaly in the settings file
% 
%     % Read in image pixel values into matries
%     objImg = double(imread(objImg));
%     figure(1);
%     imagesc(objImg(ROIx,ROIy));
%     objImg = objImg(ROIx,ROIy);
% 
% 
%     % Calibration is calculated from relating the Absorption imaging atom number
%     % to the fluorescence measured photon count (taking out contributions from
%     % exposure time and scattering rate.
%     % For now I took it as 1 over the 
%     % transmition of the optics = 0.99 which is a guess.
%     % counts per photon - quantum efficiency of pixefly in normal mode = 0.1.
%     % Collection efficiency of the imaging optics = 0.0017 or 
%     % aperture Diameter sqaured / 16*(distance sqaured)
%     % This turn out to be:
%     calibration = 525.164;
% 
%     %ExposureTime currently used. This is a variable though, and some how need
%     %to be inputed to this script.
%     exposureTime = 3000*1e-6;
% 
%     % ScatteringRate
%     lambda = 780*1e-9;
%     gamma = 2*pi*6.065*1e6; % Hz
%     detuning=-12*1e6;
%     s = 16; %s is the Saturation parameter I/Isat, Isat = 1.67 mW/cm^2
% 
%     scatteringRate = (gamma/2)*(s/(1+4*(detuning/gamma)^2+s));
% 
%     % IntegratedCounts is the difficult part of the processing.
%     % The background needs to be estimated.
%     % The atom cloud found and integrated over.
% 
%     % Estimate background 
%     bg = mean(mean(objImg(10,:)));
%     %plot(objImg(10,:))
% 
%     image = objImg-bg;
% 
%     integratedCounts = sum(sum(image));
%     %absimagecount=integratedCounts*scatteringRate/(6.45e-6)^2;
%     %Calculate Atom number
%     atomNumber(i) = ( calibration/(exposureTime*scatteringRate) )*integratedCounts;
%     %subplot(3,2,1), imagesc(image(200:800,400:1000)), 
%     %subplot(3,2,2), plot(image(:,691));
%     %subplot(3,2,3), plot(image(507,:));
%     %axes('position',[0,0,1,1],'visible','off');
%     %text(.5,.25,['Atom Number = ',num2str(atomNumber/10^9),' x 10^9']);
% 
% 
%     % gaussian distribution in x direction
%     xdata1=sum(image,1);
% 
%     X1=1:length(xdata1);
%     Y1=xdata1(X1);
% 
%     [maxValue1,maxIndex1] = max(xdata1);
%     initialCoeff1 = [0,max(xdata1)-min(xdata1),maxIndex1,60];
% 
%     options = optimset('Largescale','off');
% 
%     x1=lsqnonlin(@fit_simp,initialCoeff1,[],[],options,X1,Y1);
% 
%     Y1_new = x1(1) + x1(2)*exp(-0.5*((X1-x1(3))/x1(4)).^2);
% 
%     % gaussian distribution in y direction
%     xdata2=sum(image,2);
%     xdata2=xdata2';
% 
%     X2=1:length(xdata2);
%     Y2=xdata2(X2);
% 
%     [maxValue2,maxIndex2] = max(xdata2);
%     initialCoeff2 = [0,max(xdata2)-min(xdata2),maxIndex2,60];
% 
%     options = optimset('Largescale','off');
% 
%     x2=lsqnonlin(@fit_simp,initialCoeff2,[],[],options,X2,Y2);
% 
%     Y2_new = x2(1) + x2(2)*exp(-0.5*((X2-x2(3))/x2(4)).^2);
% 
%     %plot fits
%     figure(2), plot(X2,Y2,'+r',X2,Y2_new,'b');
%     figure(3), plot(X1,Y1,'+r',X1,Y1_new,'b');
% 
% 
%     % Find cloud size in mm
%     pixelSize = 13*1e-6;
%     demagnification = 140/200;
%     sizeX(i) = x1(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;
%     sizeY(i) = x2(4)*(2*sqrt(log(2)))*pixelSize*demagnification*1000;
% 
%     scriptFile=strcat([directoryS,'\', timestamp, ' MOT U-wire_Dp.xml']);
%     %Load the script.
%     scriptDoc = loadScript(scriptFile);
%     %Name the parameter you want to change and its new value
%     parameterName = 'MOT_Loading_Time';
%     loadingTime(i) = readScriptParameter(scriptDoc, parameterName)*1e-6; % in seconds
% 
%     resultsArray = [loadingTime(i), atomNumber(i), sizeX(i), sizeY(i)];
%     writeAnalysisResultsToFile('MOT Gradient.txt', timestamp, resultsArray, directoryR);
% end
% 
% figure(1)
% plot(atomNumber, 'o');
% figure(2)
% plot(abs(sizeX), 'o');
% figure(3)
% plot(abs(sizeY), 'o');

resultsFile = 'Z:\Users\paul\Data\University stuff\CQT\Data\140122 ChipMOT Gradient\MOT Gradient.txt';
%Open the text file, and read all the results into the data variable.
fid = fopen(resultsFile,'r');     %# Open the file
data = textscan(fid, '%s %s %s %s %s %s %s %s','delimiter',',','HeaderLines', 1,'CollectOutput',2);
fclose(fid);  %# Close the file

lastData = data{1}(1:end,:);
timestamps={};
atomNumber=[];
sizeX=[];
sizeY=[];
gradientX = [];
gradientY=[];
gradientZ=[];
for i=1:length(lastData)
   % timestamps(i)=lastData{i,1};
    timestamps{i}=strrep(lastData{i,1},'_','\_');
    atomNumber(i)=str2num(lastData{i,3});
    sizeX(i)=str2num(lastData{i,4});
    sizeY(i)=str2num(lastData{i,5}); 
    gradientX(i)=str2num(lastData{i,6});
    gradientY(i)=str2num(lastData{i,7});
    gradientZ(i)=str2num(lastData{i,8});
end


density=atomNumber./(sizeX.*sizeY);
figure(1), plot(abs(gradientX),density,'o');
axis([10 22 0 12*1e6])
[labelX, indexs] = unique(abs(gradientX));
labelY = 12*1e6*ones(1,length(labelX));
labelY(1:2:end) = labelY(1:2:end)*0.8;
timeLabel=cell(1,length(indexs));
hold on;
for i=1:length(indexs);
    timeLabel{i}= timestamps{indexs(i)};
    plot([labelX(i) labelX(i)],[5*1e6 labelY(i)-2*1e6],'g--');
end

text(labelX,labelY ,timeLabel,'VerticalAlignment','middle', 'HorizontalAlignment','right','rotation',90 );
title('MOT density vs Gradient');



