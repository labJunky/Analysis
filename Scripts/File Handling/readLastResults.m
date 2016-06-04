%Read the last lines of the analysis results file.

%Get the directory and filename.
% [dataDir, todaysDir] = getDirectory();
% datastr = '2012/1206/120618/';
% todaysDir = [dataDir, datastr];
% directory = [todaysDir, 'Images', filesep, 'MatlabProcessed', filesep];
% resultsFile = [directory, 'testWriteResults.txt'];
% 
% fid = fopen(resultsFile,'r');     %# Open the file
% data = textscan(fid, '%s %f %f %f %f','delimiter',',','HeaderLines', 1,'CollectOutput',2);
% fclose(fid);  %# Close the file
% data{2}

%Get the directory and filename.
numberOfLines=10;
[dataDir, todaysDir, d, remoteDir] = getDirectory();
sep = filesep;
dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
directory = [remoteDir, dateString, 'Images', filesep, 'MatlabProcessed', filesep];
resultsFile = [directory, 'Results.txt'];

%Open the text file, and read all the results into the data variable.
fid = fopen(resultsFile,'r');     %# Open the file
data = textscan(fid, '%s %s %s %s %s','delimiter',',','HeaderLines', 1,'CollectOutput',2);
fclose(fid);  %# Close the file

%Take the last n lines of the data.
%lastTimeStamps = data{1}(end-(numberOfLines-1):end,:);
%lastData = data{2}(end-(numberOfLines-1):end,:);
strings=(data{1}(:,2:end));
lastData = data{1}(end-(numberOfLines-1):end,:);

atomNumber=[];
odMax=[];
sizeX=[];
sizeY=[];
for i=1:length(lastData)
    atomNumber(i)=str2num(lastData{i,2});
    odMax(i)=str2num(lastData{i,3});
    sizeX(i)=str2num(lastData{i,4});
    sizeY(i)=str2num(lastData{i,5}); 
end

results=[atomNumber;odMax;sizeX;sizeY];
