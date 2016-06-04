%dateString = [datestr(now,'yyyy'),'\',datestr(now,'yymm'),'\',datestr(now,'yymmdd')];
dateString = '2012\1206\120622';
imagingPC_data_dir = 'U:\Data\AtomChip Data\';
laptop_data_dir = 'C:\Users\Administrator\Desktop\Crete\Data\';
directory = [imagingPC_data_dir ,dateString,'\Images\'];
%directory = [laptop_data_dir, dateString , '\Images\'];
%set directories
directoryOI= [directory,'Raw Data\'];
%Get image file names
objfiles=dir([directoryOI,'*Obj.tif']);
files = {objfiles.name};

startTS = '120622_1744_32';
stopTS = '120622_1851_55';

includedFiles = includeBetween(startTS, stopTS, files);

files = includedFiles;

image=[];
for i=1:15
    image(i,:,:) = double(imread([directoryOI files{i+50}]));
end
imageSd = var(image(:,:,[1:1392]));
imageMean = mean(image(:,:,[1:1392]));
figure(1)
imagesc(reshape(imageSd./imageMean,1024,1392))


