times=[0.5, 1:10];
scriptName = 'MLAbsorption';

[timeStamps, data] = getLastNResults(length(times));
timeStamps = timeStamps';
sizeX = data(:,3)';
sizeY = data(:,4)';
name = [char(timeStamps(1,1)) ' ' scriptName];
[d,todaysDir,as,remoteDir] = getDirectory();

sep = filesep;
dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
savePath = [remoteDir dateString 'Images' sep 'MatlabProcessed' sep name '.fig'];

[initialCloudSize, temperature, residual] = FitTemperature(times, sizeY, name, savePath);