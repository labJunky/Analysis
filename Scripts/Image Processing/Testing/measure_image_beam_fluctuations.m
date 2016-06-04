%dateString = [datestr(now,'yyyy'),'\',datestr(now,'yymm'),'\',datestr(now,'yymmdd')];
dateString = '2012\1204\120416';

imagingPC_data_dir = 'E:\AtomChip Data\';
%laptop_data_dir = 'C:\Users\Administrator\Desktop\Crete\Data\';

directory = [imagingPC_data_dir ,dateString,'\Images\'];
%directory = [laptop_data_dir, dateString , '\Images\'];

%set directories
directoryOI= [directory,'ObjectImages\'];

%Get image file names
objfiles=dir([directoryOI,'*Image 0.tif']);
nrOfFiles=length(objfiles);
means = [];

for k=1:nrOfFiles

        %Analyse images
        %refName = refNameD.name;
        objName = objfiles(k).name;
        atoms = imread([directoryOI,objName]);
        totalI(k) = sum(sum(atoms));
      
end

 plot(means)
 standardDeviation = std(totalI);
 shotNoise = sum(sqrt(totalI));
 xlabel( ['Noise = ', num2str( standardDeviation/shotNoise )] );
