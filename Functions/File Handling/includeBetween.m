clear function [includedFiles] = includeBetween(startTS, stopTS, files)

% This function returns a cell array of file names that are between two
% timestamps.

% INPUTS
%   startTS = start timestamp, in the format '120309_1143_41'.
%   stopTS = stop timestamp in the same format.
%   files = a list of file names in a cell array.

%Convert date and time into date vector
startDN = datenum(startTS, 'yymmdd_HHMM_SS');
stopDN = datenum(stopTS, 'yymmdd_HHMM_SS');

includedFiles = {};
nrOfFiles=length(files);
j=1;
for i=1:nrOfFiles
    timeStamp = files{i}(1:14);
    tsDN = datenum(timeStamp, 'yymmdd_HHMM_SS');
    if (startDN<=tsDN)&(tsDN<=stopDN)
        includedFiles{j} = [timeStamp files{i}(15:end)];
        j=j+1;
    end
end