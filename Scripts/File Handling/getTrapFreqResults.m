resultsFile = 'C:\Documents and Settings\chipper\Desktop\Ritayan\TrapData.txt';

%Open the text file, and read all the results into the data variable.
fid = fopen(resultsFile,'r');     %# Open the file
data = textscan(fid, '%s %f %f %f %f','delimiter',',','HeaderLines', 1,'CollectOutput',2);
fclose(fid);  %# Close the file

%Take the last n lines of the data.
lastTimeStamps = data{1};
lastData = data{2};
atomNumber = data{2}(:,1)';
atomNumberStd=[];
atomNumberMean=[];
j=1;
freq = [100:5:500];
for i=0:10:(length(atomNumber)-10)
    atomNumberMean(j)=mean(atomNumber(i+1:i+10));
    atomNumberStd(j)=std(atomNumber(i+1:i+10));
    j=j+1;
end

figure(3)
plot(freq,atomNumberMean)
figure(4)
plot(freq,atomNumberStd)
figure(5)
errorbar(freq,atomNumberMean,atomNumberStd)
    

