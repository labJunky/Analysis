% Load reference images into a stack ready for the fringe removal analysis.

dataDir = '/Users/paul/Data/University stuff/NTU/Data/20160506/';

%Get image file names
refFiles=dir([dataDir,'*Ref.tif']);
files = {refFiles.name};

 %includedFiles = includeBetween(startTS, stopTS, files);
 includedFiles= {};
 refList = {};
 j=1;
 for(i=46:length(files))
    includedFiles{j} = files{i};
    refList{j} = [dataDir includedFiles{j}];
    j=j+1;
 end

%Define a ROI, which we will crop the image with, and a signalMask
ROIy = 450:1200; 
ROIx = 50:800;
signalMask = [550,950,250,550]; %in coordinates of orginal image
crop = [1,700,1,900];
ROI = [10,700,10,900];
[U,V] = meshgrid(1:length(ROIy),1:length(ROIx));
disk = abs(circ(sqrt((U-length(ROIy)/2).^2+(V-length(ROIx)/2).^2)/(2*350)));

[R, basisVectors, k] = loadReferenceStackS(refList, ROIx, ROIy, signalMask);

atomFiles=dir([dataDir,'*Obj.tif']);
files2 = {atomFiles.name};
%includedFiles2 = includeBetween(startTS, stopTS, files2);

includedFiles2= {};
atomList = {};
j=1;
for(i=35:length(files2))
    includedFiles2{j} = files2{i};
    atomList{j} = [dataDir includedFiles2{j}];
    j=j+1;
end
%[atomList, atomBGList] = getValidObjBGImages(includedFiles2, directoryBG);
%Create two lists with valid reference and bg images inside. 
%[atomList, atomBGList] = getValidObjBGImages(files, directoryBG);
for n=1:length(atomList)
    atomListn{n} = [atomList{n}];
    %atomBGListn{n} = [directoryBG atomBGList{n}];
end

A = loadAtomImageStackS(atomListn, ROIx, ROIy);
xdim = length(ROIx);
ydim = length(ROIy);
%Calcalate the best weighted sum of reference images for each atom image.
optrefimages = optimiseReferenceImage(A, R, basisVectors, k, xdim, ydim, length(atomListn));

maskx = signalMask(1:2)-ROIy(1);
masky = signalMask(3:4)-ROIx(1);
bgmask = ones(length(ROIx),length(ROIy));
bgmask(maskx(1):maskx(2),masky(1):masky(2))=0;

for i=3:3%length(atomListn);
    atomImage =  double(imread(atomListn{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    %imageBG = double(imread(atomBGListn{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    refImage =  double(imread(refList{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    %imageBG2 = double(imread(bgList{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
%    figure(1)
    %subplot(2,1,1)
    %imagesc((atomImage-imageBG)./reshape(optrefimages(i,:,:),xdim,ydim,1),[0,1.5]);
    optRef = reshape(optrefimages(i,:,:),xdim,ydim,1);
    figure(1)
    imagesc(((atomImage)./optRef),[0,1.5]);
    %subplot(2,1,2)
    %imagesc((atomImage-imageBG)./(refImage-imageBG2),[0,1.5]);
%     figure(3)
%     imagesc((atomImage./refImage));
%     plot(atomImage(:,365))
    
%     figure(3)
%     imagesc(atomImage./refImage,[0,1.5]);
    [M,N] = size(atomImage);
    f = fft2(fftshift((atomImage./optRef)));
    fourier = ifftshift(f);
    figure(4)
    imagesc(abs(fourier));
    disk = abs(circ(sqrt((U-length(ROIy)/2-1).^2+(V-length(ROIx)/2-1).^2)/(2*1))-1);
    disk3 = abs(circ(sqrt((U-length(ROIy)/2+5).^2+(V-length(ROIx)/2+35).^2)/(2*0.1))-1);
    disk4 = abs(circ(sqrt((U-length(ROIy)/2-5).^2+(V-length(ROIx)/2-37).^2)/(2*5))-1);
    disk5 = abs(circ(sqrt((U-length(ROIy)/2+5).^2+(V-length(ROIx)/2+37).^2)/(2*5))-1);
    disk2 = abs(circ(sqrt((U-length(ROIy)/2).^2+(V-length(ROIx)/2).^2)/(2*300)));
    filtered = fourier.*disk2.*disk4.*disk5;
    imagesc(nthroot(abs(filtered).^2,6));
    nimage = abs(ifftshift(ifft2(fftshift(filtered))));
    figure(1)
    imagesc(nimage,[0,1.5]);
    
    
    
    
    %[atomNumberX, atomNumberY, sizeX, sizeY, centreX, centreY, opticalDensity, xSize] = Absorption_2( atomImage, optRef,crop, ROI,1);
    
    %divImage = (atomImage-imageBG)./reshape(optrefimages(i,:,:),xdim,ydim,1);
    divImage = (atomImage)./reshape(optrefimages(i,:,:),xdim,ydim,1);
    %divOrig = (atomImage-imageBG)./(refImage-imageBG2);
    divOrig = (atomImage)./(refImage);
    
    figure(1)
    plot(divImage(:,350))
    figure(2)
    plot(divOrig(:,350))
    
%     d1 = divImage(400:500,200:300);
% %     d2 = divOrig(400:500,200:300);
%     d1 = divImage(500:700,250:450);
%     d2 = divOrig(500:700,250:450);
%     figure(2)
%     subplot(2,1,1)
%     hist(d1(:),0.5:0.01:2);
%     set(gca, 'XLim', [0.5,2]);
%     subplot(2,1,2)
%     hist(d2(:),0.5:0.01:2);
%     set(gca, 'XLim', [0.5,2]);
%     pause(1)
%     
%     d1 = divImage(150:250,250:450);
%     d2 = divOrig(150:250,250:450);
%     figure(6)
%     subplot(2,1,1)
%     hist(d1(:),0.5:0.01:2);
%     set(gca, 'XLim', [0.5,2]);
%     subplot(2,1,2)
%     hist(d2(:),0.5:0.01:2);
%     set(gca, 'XLim', [0.5,2]);
    pause(1)
end


