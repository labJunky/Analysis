function [R, basisVectors, k, bgmask] = loadReferenceStack(refFileNames, bgFileNames, ROIx, ROIy, signalMask)
%Loads images, and creates the basis vectors for the fringe removal
%analysis
% Inputs
%   refFileNames: should be a cell array of reference image filename strings, which will be
%              loaded into RAM memory. Use the full file name with path.
%   bgFileNames: should be a cell array of background image filename strings, which will be
%              loaded into RAM memory. Use the full file name with path.
%   ROI: Region of the image which will be loaded, the fringe removal
%        analysis take a long time and a lot of memory if you load the whole
%        image. Example:  ROIx = 150:750; ROIy = 300:900;
%   signalMask: Signal Region, e.g. [190, 415, 65, 475]; in orignal image
%               size coordinates
%
% Outputs
%   R = Vectorised Reference Images, with the backgrounds subtracted
%   basisVectors = R'*R (missing the signal area)
%   k = Index k specifying background region (the region where the fringes
%       will be removed)

nimgsR = length(refFileNames)
xdim = length(ROIx);
ydim = length(ROIy);

refimages = zeros(nimgsR,length(ROIx),length(ROIy));
j=1;
% Load each ref image with its bg image and subtract them. Save them into a
% a matrix - refimages.
for i=1:nimgsR
    image = double(imread(refFileNames{j},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    imageBG = double(imread(bgFileNames{j},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    refimages(j,:,:) = image - imageBG;
    j = j+1; 
end

% Vectorise the refimages.
R = (reshape(cat(3,refimages(:)),nimgsR,xdim*ydim))';

%turn signalMask coordinates into cropped image cooridinates
maskx = signalMask(1:2);%-ROIx(1);
masky = signalMask(3:4);%-ROIy(1);
bgmask = ones(length(ROIx),length(ROIy));
bgmask(masky(1):masky(2),maskx(1):maskx(2))=0;
k = find(bgmask(:)==1); % Index k specifying background region

% Invert B = R*'� with the chosen method if svd
%Binv = pinv(R(k,:)'*R(k,:)); % SVD through PINV else
%Binv = inv(R(k,:)'*R(k,:));
%[L,U,p] = lu(R(k,:)'*R(k,:),'vector'); % LU decomposition end
%We can also use c=basisVectors\b to solve the problem where b=R(k,:)'*A(k,j)
basisVectors = R(k,:)'*R(k,:);