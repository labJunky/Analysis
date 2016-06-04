function [nameObj, nameRef, nameBG1, newFileBG, mode, fileCount] = getNewImages(directory, count)
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
nameObj={};
nameRef={};
nameBG1={};
newFileBG={};
mode={};

while i==1
    
    [newFileBG, fileCount] = getNewImageFiles(directory.BgImages, count);
    
    
    for i=1:length(newFileBG)
        %Determine if the image was taken in single or double shutter mode.
        %Single Shutter mode = 1, double shutter mode = 0.
        isSingleMode = isempty(strfind(newFileBG{i}, 'BG2'));

        %load all images.
        %find images with the same timestamp as the new background image
        if isSingleMode
            objNameD = dir([directory.ObjImages, '*', newFileBG{i}(1:14),'  Obj.tif']);
            refNameD = dir([directory.RefImages, '*', newFileBG{i}(1:14),'  Ref.tif']);
            nameObj{i} = [objNameD.name];
            nameRef{i} = [refNameD.name];
            mode{i} = 1;
            objExists = exist([directory.ObjImages,nameObj{i}], 'file')==2;
            refExists = exist([directory.ObjImages,nameRef{i}], 'file')==2;
            allExist = refExists & objExists;
            if allExist == 0
                %if they don't exist, remove them from the array
                nameObj(i)=[];
                nameRef(i)=[];
                newFileBG(i)=[];
            end
        else
            objNameD = dir([directory.ObjImages, '*', newFileBG{i}(1:14),'  Obj.tif']);
            refNameD = dir([directory.RefImages, '*', newFileBG{i}(1:14),'  Ref.tif']);
            bg1NameD = dir([directory.BgImages, '*', newFileBG{i}(1:14),'  BG1.tif']);
            nameObj{i} = [objNameD.name];
            nameRef{i} = [refNameD.name];
            nameBG1{i} = [bg1NameD.name];
            mode{i} = 2;
            objExists = exist([directory.ObjImages,nameObj{i}], 'file')==2;
            refExists = exist([directory.RefImages,nameRef{i}], 'file')==2;
            bg1Exists = exist([directory.BgImages,nameBG1{i}], 'file')==2;
            allExist = objExists & refExists & bg1Exists;
            if allExist == 0
                %if they don't exist, remove them from the array
                nameObj(i)=[];
                nameRef(i)=[];
                nameBG1(i)=[];
                newFileBG(i)=[];
            end
        end
    end
    if isempty(nameObj)==0
        %if nameObj is not empty
        return
    end
end

