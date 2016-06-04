function [refList, bgList] = getValidRefBGImages(refFiles, directoryBG)
%Create a list of valid reference and bg images

files = refFiles; %{refFiles.name};
j=1;
bgList={};
refList = {};
for i=1:length(refFiles)
    timestamp = files{i}(1:14);
    bgFile = dir([directoryBG, timestamp, '*.tif']);
    %Check if the BG image exists
    if length(bgFile)==1 %its a single shutter mode image
        refList{j} = files{i};
        bgList{j} = bgFile.name;
        j=j+1;    
    elseif length(bgFile)==2 %its a double shutter mode image, take BG2.tif file.
        refList{j} = files{i};
        bgList{j} = bgFile(2).name;
        j=j+1;
    end 
end