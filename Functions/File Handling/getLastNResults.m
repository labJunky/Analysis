function [lastTimeStamps, lastData] = getLastNResults(numberOfLines)
%Read the last n lines of the analysis results file.

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
lastTimeStamps = data{1}(end-(numberOfLines-1):end,:);
lastData = data{2}(end-(numberOfLines-1):end,:);



