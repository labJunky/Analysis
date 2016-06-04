sep = filesep;
%dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
dateString = '2012\1206\120628\';
dataDir = ['U:\Data\AtomChip Data\' dateString 'Images\MatlabProcessed\'];

resultsFile = [dataDir, 'Results.txt'];

numberOfLines = 2;

%Open the text file, and read all the results into the data variable.
fid = fopen(resultsFile,'r');     %# Open the file
data = textscan(fid, '%s %f %f %f %f','delimiter',',','HeaderLines', 1,'CollectOutput',2);
fclose(fid);  %# Close the file

%Take the last n lines of the data.
lastTimeStamps = data{1}(end-(numberOfLines-1):end,:);
lastData = data{2}(end-(numberOfLines-1):end,:);


%Take the last n lines of the data.
lastTimeStamps = data{1}(1:end,:);
lastData = data{2}(1:end,:);

timeFrom = '120628_1242_30';
timeUntil = '120628_1243_20';

startDN = datenum(timeFrom, 'yymmdd_HHMM_SS');
stopDN = datenum(timeUntil, 'yymmdd_HHMM_SS');

includedTimes= {};
includedData = [];
nrOfFiles=length(lastTimeStamps);
j=1;
for i=1:nrOfFiles
    timeStamp = lastTimeStamps{i}(1:14);
    tsDN = datenum(timeStamp, 'yymmdd_HHMM_SS');
    if (startDN<=tsDN)&(tsDN<=stopDN)
        includedTimes{j} = [timeStamp lastTimeStamps{i}(15:end)];
        includedData(j,:) = lastData(i,:);
        j=j+1;
    end
end



