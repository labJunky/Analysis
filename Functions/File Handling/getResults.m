function [includedTimes, includedData] = getResults(timeFrom, timeUntil)
%Read the Data from the analysis results file between a range of times
%Inputs
%   timeFrom timestamp from which you want the results after. In the form
%               'yymmdd_HHMM_SS' i.e. '120622_1708_20'
%   timeUntil timestamp from which you want the results before. In the form
%   'yymmdd_HHMM_SS' i.e. '120622_1752_59'

%Get the directory and filename.
[dataDir, todaysDir, d, remoteDir] = getDirectory();
sep = filesep;
dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
directory = [remoteDir, dateString, 'Images', filesep, 'MatlabProcessed', filesep];
resultsFile = [directory, 'Results.txt'];

%Open the text file, and read all the results into the data variable.
fid = fopen(resultsFile,'r');     %# Open the file
data = textscan(fid, '%s %f %f %f %f','delimiter',',','HeaderLines', 1,'CollectOutput',2);
fclose(fid);  %# Close the file

%Take the last n lines of the data.
lastTimeStamps = data{1}(1:end,:);
lastData = data{2}(1:end,:);

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

