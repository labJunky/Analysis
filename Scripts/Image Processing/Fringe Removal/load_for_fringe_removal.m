% Load reference images into a stack ready for the fringe removal analysis.

dataDir = 'U:\Data\AtomChip Data\2012\1205\120504';
directory = [dataDir, '\Images\'];

directoryOI= [directory,'ObjectImages\'];
directoryRI= [directory,'RefImages\'];
directoryBG= [directory,'BGImages\'];
%Get image file names
refFiles=dir([directoryRI,'*Ref.tif']);
files = {refFiles.name};

%Exclude Certain timestamps.
 startTS = '120504_1719_32';
 stopTS = '120504_1730_52';
 
 includedFiles = includeBetween(startTS, stopTS, files);
 
% excluded = {'120309_1147_58', '120309_1147_02'};
% includedFiles = excludefiles(excluded, includedFiles);
% startTS = '120309_1143_41';f
% stopTS = '120309_1147_58';
% includedFiles = excludeBetween(startTS, stopTS, files);

%Create two lists with valid reference and bg images inside. 
[refList, bgList] = getValidRefBGImages(includedFiles, directoryBG);
for i=1:length(refList)
    refList{i} = [directoryRI refList{i}];
    bgList{i} = [directoryBG bgList{i}];
end

%Define a ROI, which we will crop the image with, and a signalMask
ROIx = 150:650; 
ROIy = 250:950;
signalMask = [250,400,301,901]; %in coordinates of orginal image

[R, basisVectors, k] = loadReferenceStack(refList, bgList, ROIx, ROIy, signalMask);

atomFiles=dir([directoryOI,'*Obj.tif']);
files2 = {atomFiles.name};
includedFiles2 = includeBetween(startTS, stopTS, files2);
[atomList, atomBGList] = getValidObjBGImages(includedFiles2, directoryBG);
%Create two lists with valid reference and bg images inside. 
%[atomList, atomBGList] = getValidObjBGImages(files, directoryBG);
for n=1:1%length(atomList)
    atomListn{n} = [directoryOI atomList{n}];
    atomBGListn{n} = [directoryBG atomBGList{n}];
end

A = loadAtomImageStack(atomListn, atomBGListn, ROIx, ROIy);
xdim = length(ROIx);
ydim = length(ROIy);
%Calcalate the best weighted sum of reference images for each atom image.
optrefimages = optimiseReferenceImage(A, R, basisVectors, k, xdim, ydim, length(atomListn));

maskx = signalMask(1:2)-ROIx(1);
masky = signalMask(3:4)-ROIy(1);
bgmask = ones(length(ROIx),length(ROIy));
bgmask(maskx(1):maskx(2),masky(1):masky(2))=0;

for i=1:length(atomListn);
    atomImage =  double(imread(atomListn{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    imageBG = double(imread(atomBGListn{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    refImage =  double(imread(refList{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    imageBG2 = double(imread(bgList{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    figure(1)
    subplot(2,1,1)
    imagesc((atomImage-imageBG)./reshape(optrefimages(i,:,:),xdim,ydim,1),[0,1.5]);
    subplot(2,1,2)
    imagesc((atomImage-imageBG)./(refImage-imageBG2),[0,1.5]);
    
    divImage = (atomImage-imageBG)./reshape(optrefimages(i,:,:),xdim,ydim,1);
    divOrig = (atomImage-imageBG)./(refImage-imageBG2);
    d1 = divImage(1:100,1:100);
    d2 = divOrig(1:100,1:100);
    figure(2)
    subplot(2,1,1)
    hist(d1(:),0.5:0.01:1.5);
    set(gca, 'XLim', [0.5,1.5]);
    subplot(2,1,2)
    hist(d2(:),0.5:0.01:1.5);
    set(gca, 'XLim', [0.5,1.5]);
    pause(1)
end


