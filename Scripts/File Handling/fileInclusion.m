%dateString = [datestr(now,'yyyy'),'\',datestr(now,'yymm'),'\',datestr(now,'yymmdd')];
dateString = '2012\1203\120309';
imagingPC_data_dir = 'E:\AtomChip Data\';
laptop_data_dir = 'C:\Users\Administrator\Desktop\Crete\Data\';
%directory = [imagingPC_data_dir ,dateString,'\Images\'];
directory = [laptop_data_dir, dateString , '\Images\'];
%set directories
directoryOI= [directory,'ObjectImages\'];
%Get image file names
objfiles=dir([directoryOI,'*Obj.tif']);
files = {objfiles.name};

startTS = '120309_1143_41';
stopTS = '120309_1147_58';

includedFiles = includeBetween(startTS, stopTS, files);

excluded = {'120309_1147_58', '120309_1147_02'};

includedFiles = excludefiles(excluded, includedFiles);

startTS = '120309_1143_41';
stopTS = '120309_1147_58';

includedFiles = excludeBetween(startTS, stopTS, files);







    
 
