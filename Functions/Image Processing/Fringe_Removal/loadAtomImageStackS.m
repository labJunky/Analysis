function [A, imageDiv, objImages] = loadAtomImageStackS(atomFileNames, ROIx, ROIy)
%Loads images for the fringe removal.
%analysis
% Inputs
%   atomFileNames: should be a cell array of atom image filename strings, which will be
%              loaded into RAM memory. Use the full file name with path.
%   bgFileNames: should be a cell array of background image filename strings, which will be
%              loaded into RAM memory. Use the full file name with path.
%   ROI: Region of the image which will be loaded, the fringe removal
%        analysis take a long time and a lot of memory if you load the whole
%        image. Example:  ROIx = 150:750; ROIy = 300:900;
%
% Outputs
%   A = Vectorised Atom Images, with the backgrounds subtracted


nimgs = length(atomFileNames);
xdim = length(ROIx);
ydim = length(ROIy);
objImages = zeros(nimgs,length(ROIx),length(ROIy));
j=1;
%Load atoms images and subtract the background
for i=1:nimgs
    image = double(imread(atomFileNames{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    %imageBG = double(imread(bgFileNames{i},'PixelRegion',{[ROIx(1) max(ROIx)], [ROIy(1) max(ROIy)]}));
    imageDiv = image;% - imageBG;
    objImages(j,:,:) = image;% - imageBG;
    j=j+1;
end

A = (reshape(cat(3,objImages(:)),nimgs,xdim*ydim))';