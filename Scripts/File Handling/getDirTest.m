sep = filesep;
dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
dataDirectory = '/mnt/workspace/Data/AtomChip Data/';
todaysDataDir = [dataDirectory dateString];
matlabDir = [dataDirectory 'Analysis/'];
analysisSettingsDir = [matlabDir 'Analysis Settings/'];