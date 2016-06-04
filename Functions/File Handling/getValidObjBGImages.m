function [objList, bgList] = getValidObjBGImages(objFiles, directoryBG)
%Create a list of valid object and bg images

files = objFiles;
j=1;
bgList={};
objList = {};
for i=1:length(objFiles)
    timestamp = files{i}(1:14);
    bgFile = dir([directoryBG, timestamp, '*.tif']);
    %Check if the BG image exists
    if length(bgFile)==1 %its a single shutter mode image
        objList{j} = files{i};
        bgList{j} = bgFile.name;
        j=j+1;    
    elseif length(bgFile)==2 %its a double shutter mode image, take BG2.tif file.
        objList{j} = files{i};
        bgList{j} = bgFile(1).name;
        j=j+1;
    end 
end