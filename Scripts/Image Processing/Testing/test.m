%dateString = [datestr(now,'yyyy'),'\',datestr(now,'yymm'),'\',datestr(now,'yymmdd')];
dataString = '2012\1203\120309';

imagingPc_data_dir = 'E:\AtomChip Data\';
laptop_data_dir = 'C:\Users\Administrator\Desktop\Crete\Data\';

%directory = [imagingPC_data_dir ,dateString,'\Images\'];
directory = [laptop_data_dir, dataString , '\Images\'];

%set directories
directoryOI= [directory,'ObjectImages\'];
directoryRI=[directory,'RefImages\'];
directoryBI=[directory,'BGImages\'];

%Get image file names
objfiles=dir([directoryOI,'*Obj.tif']);
nrOfFiles=length(objfiles);

%Region of Interest
ROI = [160,1024,690,1030];

atomNumbers = [];

for k=1:nrOfFiles %Loop the analysis over the directory
    
    %find images with the same timestamp in reference and background
    %directories
    refNameD = dir([directoryRI, '*', objfiles(k).name(1:14),'  Ref.tif']);
    bg1NameD = dir([directoryBI, '*', objfiles(k).name(1:14),'  BG1.tif']);
    bg2NameD = dir([directoryBI, '*', objfiles(k).name(1:14),'  BG2.tif']);
    nameRef = [refNameD.name];
    nameBG1 = [bg1NameD.name];
    nameBG2 = [bg2NameD.name];
    refExists = exist([directoryRI,nameRef], 'file')==2;
    bg1Exists = exist([directoryBI,nameBG1], 'file')==2;
    bg2Exists = exist([directoryBI,nameBG2], 'file')==2;
    allExist = refExists & bg1Exists & bg2Exists;
    
    %check if all 4 images exist with the same timestamp
    if allExist
        
        %Read in images
        objName = objfiles(k).name;
        atoms = imread([directoryOI,objName]);
        laser = imread([directoryRI,nameRef]); 
        bg1 = imread([directoryBI, nameBG1]); 
        bg2 = imread([directoryBI, nameBG2]); 
        
        %Analysis
        [atomNumbers(k), imageArray] = Absorption_normalising( atoms, laser, bg1, bg2, ROI );
        if atomNumbers(k) > 200000
           objName % Print the file names if they statify the above test
        end
        
        %Plot Results
        figure(1)
        subplot(2,1,1)
        plot(atomNumbers)
        xlabel( ['Atom Number = ', num2str( atomNumbers(k) )] );
        subplot(2,1,2)
        imagesc(imageArray)
    end % end of if statment checking the existance of all 4 images
end % end of for loop which loops the analysis over the directory
