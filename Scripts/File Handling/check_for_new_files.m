laptop_dir = 'C:\Users\Administrator\Desktop\Crete\Data\Matlab_Test\Images\';
directoryOI= [directory,'ObjectImages\'];
directoryRI=[directory,'RefImages\'];
directoryBI=[directory,'BGImages\'];

%Look into a directory and repetatively check if new files appear.
newFileBG = getNewImageFile(directoryBI);

%Determine if the image was taken in single or double shutter mode.
%Single Shutter mode = 1, double shutter mode = 0.
isSingleMode = isempty(strfind(newFileBG, 'BG2'));

%load all images.
%find images with the same timestamp as the new background image
if isSingleMode
    objNameD = dir([directoryOI, '*', newFileBG(1:14),'  Obj.tif']);
    refNameD = dir([directoryRI, '*', newFileBG(1:14),'  Ref.tif']);
    nameObj = [objNameD.name];
    nameRef = [refNameD.name];
    objExists = exist([directoryOI,nameObj], 'file')==2;
    refExists = exist([directoryRI,nameRef], 'file')==2;
    allExist = refExists & objExists;
else
    objNameD = dir([directoryOI, '*', newFileBG(1:14),'  Obj.tif']);
    refNameD = dir([directoryRI, '*', newFileBG(1:14),'  Ref.tif']);
    bg1NameD = dir([directoryBI, '*', newFileBG(1:14),'  BG1.tif']);
    nameObj = [objNameD.name];
    nameRef = [refNameD.name];
    nameBG1 = [bg1NameD.name];
    objExists = exist([directoryOI,nameRef], 'file')==2;
    refExists = exist([directoryRI,nameRef], 'file')==2;
    bg1Exists = exist([directoryBI,nameBG1], 'file')==2;
    allExist = refExists & bg1Exists & bg2Exists;
end

%Check if all images exist, and then analyse them.
if allExist
    if isSingleMode
        %Analysis in single shutter mode
        
    else
        %Analysis in double shutter mode
    end
end


