function [nameObj, nameRef, nameBG1, newFileBG, mode] = getNewImage(directory, varargin)
% getNewImage()
%
% Returns new background image file names, and mode = 1 single shutter, 2 double
% shutter.
%
% INPUTS: directory is a directory object (i.e. obj = directory() );
% 
% Example:
% [nameObj, nameRef, nameBG1, nameBG, mode] = getNewImage(directory);
%
%
% Waits for a new '.tif' file to arrive in the background image directory
% and then check to see if all the other image files with the same
% timestamp have also been written.
% If all the files exist, then the function returns their file name, and
% whether the camera was in single or double shutter mode (pixelfly camera)
% If the camera was in single shutter mode, the nameBG1 file will be empty.
% The nameBG file will give the file name of the relavent background image.

% [d, directory] = getDirectory();

%dateStr = '2012/1205/120514/';
%directory = [d, dateStr];
% 
% sep = filesep;
% imageDir = [directory, 'Images', sep];
% directoryOI= [imageDir,'ObjectImages', sep];
% directoryRI= [imageDir,'RefImages', sep];
% directoryBI= [imageDir,'BGImages', sep];

i=1;
while i==1
    newFileBG = getNewImageFile(directory.BgImages);

    %Determine if the image was taken in single or double shutter mode.
    %Single Shutter mode = 1, double shutter mode = 0.
    isSingleMode = isempty(strfind(newFileBG, 'BG2'));

    %load all images.
    %find images with the same timestamp as the new background image
    if isSingleMode
        objNameD = dir([directory.ObjImages, '*', newFileBG(1:14),'  Obj.tif']);
        refNameD = dir([directory.RefImages, '*', newFileBG(1:14),'  Ref.tif']);
        nameObj = [objNameD.name];
        nameRef = [refNameD.name];
        objExists = exist([directory.ObjImages,nameObj], 'file')==2;
        refExists = exist([directory.ObjImages,nameRef], 'file')==2;
        allExist = refExists & objExists;
    else
        objNameD = dir([directory.ObjImages, '*', newFileBG(1:14),'  Obj.tif']);
        refNameD = dir([directory.RefImages, '*', newFileBG(1:14),'  Ref.tif']);
        bg1NameD = dir([directory.BgImages, '*', newFileBG(1:14),'  BG1.tif']);
        nameObj = [objNameD.name];
        nameRef = [refNameD.name];
        nameBG1 = [bg1NameD.name];
        objExists = exist([directory.ObjImages,nameObj], 'file')==2;
        refExists = exist([directory.RefImages,nameRef], 'file')==2;
        bg1Exists = exist([directory.BgImages,nameBG1], 'file')==2;
        allExist = objExists & refExists & bg1Exists;
    end
    
    %Check if all images exist, and then analyse them.
    if allExist
        if isSingleMode
            %Analysis in single shutter mode
            mode = 1;
            return
        else
            %Analysis in double shutter mode
            mode = 2;
            return
        end
    end
end

