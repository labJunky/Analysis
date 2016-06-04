%Create Image Mask, to mask out the atoms in an absorption image.

directoryO = 'C:\Users\Administrator\Desktop\Data\Images\ObjectImages\';
directoryR = 'C:\Users\Administrator\Desktop\Data\Images\RefImages\';
objfiles=dir([directoryO,'*Obj.tif']);
reffiles=dir([directoryR,'*Ref.tif']);

ROIx = 50:750;
ROIy = 300:900;

bgmask = ones(length(ROIx),length(ROIy));
bgmask(190:415,65:475)=0;

for i=1:20;
    objimage = double(imread([directoryO,objfiles(i).name],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    mask = objimage;
    refimage = double(imread([directoryR,reffiles(i).name],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    divimage = 1-objimage./refimage;
    
    [value, location] = max(divimage(:)); 
    [row, column] = ind2sub(size(divimage), location);

    h = fspecial('average', [50 50]);
    smoothimage = imfilter(divimage, h);

    mask(smoothimage>=0.1*value)=0;
    mask(mask~=0)=1;
    tmpmask(i,:,:)= mask;
    figure(1)
    subplot(2,1,1)
    imagesc(bgmask.*divimage);
    subplot(2,1,2)
    imagesc(divimage)
    pause(0.5)
end
% 
% bgmask = ones(1024,1392);
% bgmask(150:550,350:800)=0;
% figure(1)
% subplot(2,1,1)
% %imagesc(reshape(bgmask,1024,1392,1));
% imagesc(bgmask.*divimage);


