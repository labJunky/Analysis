directoryO = 'C:\Users\Administrator\Desktop\Data\Images\ObjectImages\';
directoryR = 'C:\Users\Administrator\Desktop\Data\Images\RefImages\';
directoryBG = 'C:\Users\Administrator\Desktop\Data\Images\BGImages\';
%directory='E:\AtomChip Data\2012\1204\120417\Images\ObjectImages';
%timeStamp='120417_1451_43 Image ';

objfiles=dir([directoryO,'*Obj.tif']);
reffiles=dir([directoryR,'*Ref.tif']);
%other = dir([directoryR,'*Image 0.tif']);
% bgfiles1=dir([directoryBG,'*BG1.tif']);
% bgfiles2=dir([directoryBG,'*BG2.tif']);
% bgfiles = [bgfiles1;bgfiles2];

fileNumbersR = 1:30;%length(reffiles);
%fileNumbers = 50:55;%length(objfiles);
nimgsR = length(fileNumbersR);


ROIx = 150:750;
ROIy = 300:900;

svd = 1;

xdim = length(ROIx);
ydim = length(ROIy);

h = fspecial('average', [50 50]);

%file0 = strcat([directory,'\' timeStamp int2str(0) '.tif']);
refimages = zeros(nimgsR,length(ROIx),length(ROIy));
%mask = zeros(nimgs,length(ROIx),length(ROIy));
j=1;
for i=fileNumbersR
    %file1{j} = strcat([directory,'\' timeStamp int2str(i) '.tif']);
    file1{j} = [directoryR,reffiles(i).name];
    %file2{j} = [directoryBG,bgfiles(i).name];
    image = double(imread(file1{j},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    %image = image(ROIx, ROIy);
    %image = reshape(image(:),length(ROIx)*length(ROIy),1);
    %refs(j,:,:) = image;
    %refimages{j} = num2cell(image);
    refimages(j,:,:) = image;
    j = j+1; 
end

R = (reshape(cat(3,refimages(:)),nimgsR,xdim*ydim))';

%bgmask=ones(ydim,xdim);
%bgmask = reshape(prod(mask),xdim,ydim,1);
bgmask = ones(length(ROIx),length(ROIy));
bgmask(100:300,65:475)=0;
k = find(bgmask(:)==1); % Index k specifying background regionc

% Ensure there are no duplicate reference images
% R=unique(R','rows')'; % comment this line if you run out of memory
% Invert B = R*'’ with the chosen method if svd
%Binv = pinv(R(k,:)'*R(k,:)); % SVD through PINV else
%Binv = inv(R(k,:)'*R(k,:));
%[L,U,p] = lu(R(k,:)'*R(k,:),'vector'); % LU decomposition end
%We can also use c=sq\b to solve the problem where b=R(k,:)'*A(k,j)
sq = R(k,:)'*R(k,:);

j=1;
start = 1;
stop = 12;%floor(length(objfiles)/2);
objimages = zeros(2,length(ROIx),length(ROIy));
for n=1:stop
    fileNumbers = start:(start+1);
    nimgs = length(fileNumbers);
    j=1;
    for i=fileNumbers 
    % file1{j} = strcat([directory,'\' timeStamp int2str(i) '.tif']);
    %file0{j} = [directoryO,objfiles(i).name];
    image = double(imread([directoryO,objfiles(i).name],'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    %image = image(ROIx, ROIy);
    %image = reshape(image(:),length(ROIx)*length(ROIy),1);
    %objs(j,:,:) = image;
    %objimages{j} = num2cell(image);
    objimages(j,:,:) = image;
    %     divimage = 1-image./reshape(refimages(j,:,:),xdim,ydim,1);
    %     temp = image;
    %     smoothimage = imfilter(divimage, h);
    %     peak = max(divimage(:));
    %     temp(smoothimage>=0.1*peak)=0;
    %     temp(temp~=0)=1;
    %     mask(j,:,:) = temp;
    j = j+1; 
    end
    j=1;
    t = cputime;
 
    A = (reshape(cat(3,objimages(:)),nimgs,xdim*ydim))';
    
    optrefimages=[];%cell(nimgs,1); 
    for j=1:nimgs
    b=R(k,:)'*A(k,j);
    % Obtain coefficients c which minimise least-square residuals if svd
    if svd 
        c = sq\b;%Binv*b;%
    else
        lower.LT = true; upper.UT = true;
        c = linsolve(U,linsolve(L,b(p,:),lower),upper);
    end
    % Compute optimised reference image
    optrefimages(j,:,:)=reshape(R*c,[xdim ydim]);
    end
    e = cputime - t

    % [optrefimages] = fringeremoval(objimages,refimages);
    %
    for i=1:nimgs;
    % divImage = double(cell2mat(objimages{i}))./double(optrefimages{i});
    figure(1)
    subplot(2,1,1)
    imagesc(reshape(objimages(i,:,:),xdim,ydim,1)./reshape(optrefimages(i,:,:),xdim,ydim,1),[0,1.5]);
    subplot(2,1,2)
    imagesc(reshape(objimages(i,:,:),xdim,ydim,1)./reshape(refimages(i,:,:),xdim,ydim,1),[0,1.5]);
    pause(0.5)
    end

    divImages = objimages(:,1:100,1:100)./optrefimages(:,1:100,1:100);
    divOrig = objimages(:,1:100,1:100)./refimages(1:nimgs,1:100,1:100);
    figure(2)
    subplot(2,1,1)
    hist(divImages(:),0.5:0.01:1.5);
    set(gca, 'XLim', [0.5,1.5]);
    subplot(2,1,2)
    hist(divOrig(:),0.5:0.01:1.5);
    set(gca, 'XLim', [0.5,1.5]);
    
    size(objimages)
    
    start = start+2;
end

% 
% for i=1:nimgs;
%     %divImage = double(cell2mat(objimages{i}))./double(optrefimages{i});
%     figure(1)
%     subplot(2,1,1);
%     imagesc(reshape(mask(j,:,:),xdim,ydim,1));
%     subplot(2,1,2)
%     imagesc(reshape(objimages(i,:,:),xdim,ydim,1)./reshape(refimages(i,:,:),xdim,ydim,1));
%     pause(0.5)
% end


 
% meandv=mean(divImage(:))
% stdv = std2(divImage(:))
% 
% divO = double(cell2mat(objimages{2}))./double(cell2mat(refimages{2}));
% figure(2)
% imagesc(divO)
% mean(divO(:))
% std2(divO(:))
