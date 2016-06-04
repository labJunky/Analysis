function [newestFile, newNameCount] = getNewImageFile(directory, varargin)
% getNewImageFile directory
%
% Look into a directory and repetatively check if new files appear.
%
% It checks if the number of '.tif' files in the directory changes. Then picks out
% the newest file by its file creation date.
%
% INPUTS
%   directory = is string of the directory path
%
% Example:
%   newestFile = getNewImageFile('D:\AtomChip Data\2012\1205\120509\Images\BGImages');
%   
%   newestFile will be the file name of the newest '.tif' image written
%   into the directory.
%   If no image are written, this function will continue to loop
%   indefinitely.

%get directory file count.
dir_info = dir([directory, '*BG2.tif']);
oldNameCount = length({dir_info.name}); 

% set defaults for optional inputs
optargs = {oldNameCount};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[oldNameCount] = optargs{:};

x=1;
while x==1
    dir_info = dir([directory, '*BG2.tif']);
    newNameCount = length({dir_info.name});
    if newNameCount > oldNameCount
        x=0;
        [dx,dx] = sort([dir_info.datenum]);
        newestFile = dir_info(dx(end)).name;
    else oldNameCount = newNameCount;
    end
end

  