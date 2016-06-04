function [includedFiles] = excludefiles(excludedTS, files)

% This function returns a cell array of file names that are not excluded.

% INPUTS
%   excludedTS = cell array of timestamps, in the format '120309_1143_41',
%                to be excluded.
%   files = a list of file names that I will access with the syntax
%           files(i).name

exDN = datenum(excludedTS, 'yymmdd_HHMM_SS');

nrOfFiles=length(files);
tsDN = [];
for i=1:nrOfFiles
    timeStamp = files{i}(1:14);
    tsDN(i) = datenum(timeStamp, 'yymmdd_HHMM_SS');
end

%exclude files
[intsc, ia]=intersect(tsDN,exDN);
tsDN(ia)=[];
files(ia)=[];

includedFiles={};
for i=1:length(tsDN)
    includedFiles{i} = [datestr(tsDN(i), 'yymmdd_HHMM_SS') files{i}(15:end)];
end