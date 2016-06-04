dataDir = getDirectory();
dateStr = '2012/1205/120504';
directory = [dataDir, dateStr];
%Included timestamps between:
startTS = '120504_1719_32';
stopTS = '120504_1754_47';

sep = filesep;
imageDir = [directory, sep, 'Images', sep];
directoryOI= [imageDir,'ObjectImages', sep];
directoryRI= [imageDir,'RefImages', sep];
directoryBG= [imageDir,'BGImages', sep];
saveDir = [imageDir, 'MatlabProcessed', sep];

atomFiles=dir([directoryOI,'*Obj.tif']);
files2 = {atomFiles.name};
includedFiles2 = includeBetween(startTS, stopTS, files2);
[atomList, atomBGList] = getValidObjBGImages(includedFiles2, directoryBG);
atomList;
for n=1:5%length(atomList)
    atomListn{n} = [directoryOI atomList{n}];
    atomBGListn{n} = [directoryBG atomBGList{n}];
end

[p, name, ext] = fileparts(atomListn{1});
imagePath = [saveDir, name(1:14), ' FR_1.tif'];