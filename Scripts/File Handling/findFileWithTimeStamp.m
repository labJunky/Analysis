%Find Image with the same timestamp in a directory

[dataDir, todaysDataDir] = getDirectory();
dateString = '2012\1204\120425';
directory = [dataDir, dateString, '\Images\'];

directoryRI= [directory,'RefImages\'];
directoryBG= [directory,'BGImages\'];
%Get image file names
reffiles=dir([directoryRI,'*Ref.tif']);
files = {reffiles.name};

timestamp = files{2}(1:14);
bgFile = dir([directoryBG, timestamp, '*.tif']);

