function [initialCloudSize, temperature, psd, residual] = FitTemperature(times, sizeX, name, savePath, atomNumber, sizeY)
%This function analyses the atoms cloud to find its temperature. The
%function is given the expansion times and the fitted sizes of one of 
%the dimensions of the cloud. The other input is the names of the images.

%constants
kB = 1.38*10^(-23);
m = 87*1.6*10^(-27);
h = 6.626068*10^-34; 

%Fit the data
initialCoeff = [min(sizeX),100*10^(-6)];

[x1, resnorm, residual] = lsqnonlin(@fit_temp,initialCoeff,[],[],[],times,sizeX); 
temperature = x1(2);
initialCloudSize = x1(1);

ld = h/sqrt(2*pi*m*kB*temperature);
psd = (atomNumber*ld^3)/(sizeX.*sizeY);


%Prepare a curve to plot
t = min(times):0.1*10^(-3):max(times);
x1 =  sqrt(initialCloudSize^2 + (kB/m)*temperature*t.^2);

scriptName = name;
%Plot the data over the fitted curve
handle = figure;
set(handle,'Name',['Temperature Measurement : ' scriptName],'NumberTitle','off')
plot(times,sizeX,'o',t,x1)
xlabel('Expansion Time ms');
ylabel('Cloud Size mm');
plotLabel = ['Temperature = ' num2str(temperature*10^(6)) ' ' '\mu' 'K', ', PSD = ' num2str(psd)];
nameLabel= ['Script Name = ' scriptName];
%text(1,max(sizeX+0.02),nameLabel);
text(min(times),max(sizeX)+10^-3,plotLabel);
title('Temperature Measurement');
saveas(handle,savePath);





