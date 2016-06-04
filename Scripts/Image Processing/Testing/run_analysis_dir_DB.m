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
nrOfFiles=length(objfiles);

%Region of Interest
ROI = [100,1300,10,1024];

atomNumbers = [];
odMax = [];
sizeX = [];
sizeY = [];
plots = 2;

for k=170:nrOfFiles
    %find images with the same timestamp in reference and background
    %directories
    refNameD = dir([directoryRI, '*', objfiles(k).name(1:14),'  Ref.tif']);
    bg1NameD = dir([directoryBI, '*', objfiles(k).name(1:14),'  BG1.tif']);
    bg2NameD = dir([directoryBI, '*', objfiles(k).name(1:14),'  BG2.tif']);
    nameRef = [refNameD.name];
    nameBG1 = [bg1NameD.name];
    nameBG2 = [bg2NameD.name];
    refExists = exist([directoryRI,nameRef], 'file')==2;
    bg1Exists = exist([directoryBI,nameBG1], 'file')==2
    bg2Exists = exist([directoryBI,nameBG2], 'file')==2;
    allExist = refExists & bg1Exists & bg2Exists;
    
    %check if all 4 images exist with the same timestamp
    if allExist
        %Analyse images
        %refName = refNameD.name;
        objName = objfiles(k).name;
        atoms = imread([directoryOI,objName]);
        laser = imread([directoryRI,nameRef]); 
        bg1 = imread([directoryBI, nameBG1]);
        bg2 = imread([directoryBI, nameBG2]); 
        [atomNumbers(k), imageArray, odMax(k), sizeX(k), sizeY(k)] = Absorption_normalising( atoms, laser, bg1, bg2, ROI );
       
        %Plot results
        
        figure(1)
        subplot(plots,1,1)
        plot(atomNumbers)
        xlabel( ['Atom Number = ', num2str( atomNumbers(k) )] );
        subplot(plots,1,2)
        imagesc(imageArray)
       % subplot(4,1,3)
         % plot(odMax)
        %xlabel( ['OD Max = ', num2str( odMax(k) )] );
        subplot(plots,1,3)
        plot(sizeX)
        xlabel( ['Size X mm = ', num2str( sizeX(k) )] );
          
    
    end
   
end
% times = [0.5:0.5:5];
%     sizes = sizeX;
%     name = 'test';
% [x,temp, resnorm] = FitTemperature(times, sizeX(170:179), name, 'test_temp.fig');
