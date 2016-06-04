dateString = [datestr(now,'yyyy'),'\',datestr(now,'yymm'),'\',datestr(now,'yymmdd')];
%dateString = '2012\1203\120309';

imagingPC_data_dir = 'E:\AtomChip Data\';
laptop_data_dir = 'C:\Users\Administrator\Desktop\Crete\Data\';

directory = [imagingPC_data_dir ,dateString,'\Images\'];
%directory = [laptop_data_dir, dateString , '\Images\'];

%set directories
directoryOI= [directory,'ObjectImages\'];
directoryRI=[directory,'RefImages\'];
directoryBI=[directory,'BGImages\'];

%Get image file names
objfiles=dir([directoryOI,'*Obj.tif']);
nrOfFiles=length(objfiles)