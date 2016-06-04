function [newestFile, newNameCount] = getNewImageFiles(directory, count)
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

if count == -1
    %get directory file count.
    dir_info = dir([directory, '*BG2.tif']);
    oldNameCount = length({dir_info.name});
else oldNameCount = count;
end

x=1;
while x==1
    dir_info = dir([directory, '*BG2.tif']);
    newNameCount = length({dir_info.name});
    if newNameCount > oldNameCount
        lastN = newNameCount-oldNameCount;
        x=0;
        [dx,dx] = sort([dir_info.datenum]);
        newestFile = {dir_info(dx(end-lastN+1:end)).name};
    else oldNameCount = newNameCount;
    end
end