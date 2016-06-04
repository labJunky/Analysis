times = [0.5, 1:10]*10^-3;
[timeStamps, data] = getLastNResults(length(times));
    sizeX = data(:,3)';
    sizeY = data(:,4)';
    name = [char(timeStamps(1,1)) ' ' 'dipole script'];
    
    [d,todaysDir,as,remoteDir] = getDirectory();
    sep = filesep;
    dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
    savePath = [remoteDir dateString 'Images' sep 'MatlabProcessed' sep name '.fig'];
    
    [initialCloudSize, temperature, residual] = FitTemperature(times*10^3, sizeY, name, savePath);