% Set Directory and Load images
date='20160603';
sep=filesep;
%dataPath='Y:\Data\University stuff\NTU\Data';
dataPath='/Users/paul/Data/University stuff/NTU/Data';
aP = [dataPath,sep,date,sep,date];
lP = aP;
mtfolder = [dataPath,sep,date,sep,'matlab'];
mkdir(mtfolder);
iP = [mtfolder,sep,date];
resultsPath = [dataPath,sep,date,sep,'temperature_Cell_MOTCoils.txt'];

%crop = [200,1100,10,1000];
crop = [1,1392,1,1024];
%ROI = [10,900,10,900];
%ROI = [1,1392,1,1023];

%ROI = [10,1392,10,1014]; %MOT side
ROI=[10,1382,10,1014];

j=1;
%677 - 1907
i=15:2:121;
k=1;
for x=75:2:75; 
    if j==1||j==2||j==3;
        tof=8;
    elseif j==4||j==5||j==6;
        tof=9;
    else tof=10;
    end
    tof=k;
    imageNumber = x;
    [prefix, prefix2] = getImagePrefix(imageNumber);
    
    atomsP = [aP, prefix,int2str(imageNumber),'.tif'];
    laserP = [lP, prefix2,int2str(imageNumber+1),'.tif'];  
    imagePath = [iP, prefix,int2str(imageNumber),'.tif'];

    atoms = double(imread(atomsP));
    laser = double(imread(laserP));

    [atomNumberX, atomNumberY, sizeX, sizeY, centreX, centreY, opticalDensity, xSize] = Absorption_2( atoms, laser, crop, ROI,1,imagePath);
    a=dir(atomsP);
    time = a.date;
    pause(0.1)
    
    %writeAnalysisResultsToFile(resultsPath, time, int2str(imageNumber), [tof, k, atomNumberX, atomNumberY, sizeX, sizeY, xSize, centreX, centreY])
    j=j+1;
    if j==4;
        j=1;  
        k=k+1;
    end
end
