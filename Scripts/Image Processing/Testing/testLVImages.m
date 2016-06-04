%Test Imaging System
%Labbook entry on 02/04/2012. 
%Imaging system on table, with various configurations as below.

%Directories
%Nothing in imaging plane. Laser Locked
%directory='E:\AtomChip Data\2012\1203\120330\Images\everything except cell';
%laser locked, out of focus
%directory='E:\AtomChip Data\2012\1204\120402\Images\FullRes_Fringes';
%laser locked, out of focus, limited resolution
%directory='E:\AtomChip Data\2012\1204\120402\Images\limitedRes_Fringes';
%laser locked, in focus
%directory='E:\AtomChip Data\2012\1204\120402\Images\InFocus_Full_Fringes';
%laser locked, in focus, limited resolution
%directory='E:\AtomChip Data\2012\1204\120402\Images\InFocus_limited_Fringes';
%Laser scanning about 2 GHz at 10 Hz, out of focus, full resolution
%directory='E:\AtomChip Data\2012\1204\120402\Images\Scanning';
%laser locked, out of focus, full resolution
%directory='E:\AtomChip Data\2012\1204\120402\Images\locked';


directory='E:\AtomChip Data\2012\1204\120418\Images\ObjectImages';
%timeStamp='120403_1516_15 Image ';
%timeStamp = '120403_1520_34 Image ';
timeStamp='120418_1824_03 Image ';

%timeStamp = '120330_1741_07 Image ';
%timeStamp = '120402_1143_04 Image ';
%timeStamp = '120402_1221_30 Image ';
%timeStamp = '120402_1236_01 Image ';
%timeStamp = '120402_1242_04 Image ';
%timeStamp = '120402_1344_52 Image ';
%timeStamp = '120402_1351_06 Image ';
%timeStamp = '120402_1614_58 Image ';

stDev = [];

for k=0:48
    
    file0 = strcat([directory,'\' timeStamp int2str(k) '.tif']);
    file1 = strcat([directory,'\' timeStamp int2str(k+1) '.tif']);
    image0 = double(imread(file0));
    image1 = double(imread(file1));
    divImage = image0./image1;
    stDev(k+1) = std2(divImage(:));

    
    figure(1)
    imagesc(divImage)
    xlabel(file0);
   
end
figure(2)
plot(stDev)
xlabel(num2str(mean(stDev)));


