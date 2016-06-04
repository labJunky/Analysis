%fit lifetime measurement

times = [50:50:1000]*10^-3;
[t,d] = getLastNResults(length(times));
data=d(:,1)';

%Fit the data
initialCoeff = [max(data),1.5];

%[x1, resnorm, residual] = lsqcurvefit(@fit_lifeTime,initialCoeff,times,data);
x1=[max(data),1.5];

atomNumber = x1(1)*exp(-x1(2)*times);
name = char(t(1,1));
scriptName = name;
%Plot the data over the fitted curve
handle = figure;
set(handle,'Name',['Lifetime Measurement : ' scriptName],'NumberTitle','off')
plot(times,data,'o',times,atomNumber)
xlabel('Hold Time s');
ylabel('Number of Atoms');
plotLabel = ['Lifetime = ' num2str(1/x1(2)) ' s'];
nameLabel= ['Script Name = ' scriptName];
%text(1,max(sizeX+0.02),nameLabel);
text(median(times),max(data)*0.9,plotLabel);
title('Lifetime Measurement');
%saveas(handle,savePath);