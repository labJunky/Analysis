% Set Directory and Load images
directory='U:\Data\AtomChip Data\2012\1205\120530\Images';
atomsD=strcat([directory,'\ObjectImages\120530_2019_32  Obj.tif']);
laserD=strcat([directory,'\RefImages\120530_2019_32  Ref.tif']);
bg1D=strcat([directory,'\BGImages\120530_2019_32  BG1.tif']);
bg2D=strcat([directory,'\BGImages\120530_2019_32  BG2.tif']);
imagePath=strcat([directory,'\ProcessedAbsorptionImages\120530_2019_32  TestP.tif']);

atoms = double(imread(atomsD));
laser = double(imread(laserD));
bg1 = double(imread(bg1D));
bg2 = double(imread(bg2D));

divImage = -log((atomsT./laser));
scaleFactor = (2^16-1)/max(max(divImage));

convertedImage = uint16(divImage*scaleFactor);
convertedImage(convertedImage<0)=0;

%figure(1)
%imagesc(divImage);

%imwrite(convertedImage,imagePath)

max(max(divImage))
min(min(divImage))

ROI = [550:1050,250:450];
[atomNumber, opticalDensityFull, sizeX, sizeY] = Absorption_normalising_DSLV( atoms, laser, bg1, bg2, ROI, imagePath);