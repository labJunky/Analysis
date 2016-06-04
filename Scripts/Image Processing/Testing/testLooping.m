file1=cell(20,88);
directory = 'C:\Users\Administrator\Desktop\Data\FringeImages\ObjectImages';
%directory='E:\AtomChip Data\2012\1204\120417\Images\ObjectImages';

timeStamp='120417_1730_44 Image ';

for i=1:20
    file1{i} = strcat([directory,'\' timeStamp int2str(i) '.tif']);
end 

%file1{1}= strcat([directory,'\' timeStamp int2str(1) '.tif']);