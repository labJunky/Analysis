function [optrefimages] = optimiseReferenceImage(atomImages, refImages, basisVectors, k, xdim, ydim, nimgs)
%Calculated a weighted sum of reference images to minimise noise in the
%atom images

optrefimages=[];%cell(nimgs,1); 
for j=1:nimgs
    b=refImages(k,:)'*atomImages(k,j);
    % Obtain coefficients c which minimise least-square residuals
    c = basisVectors\b;
    % Compute optimised reference image
    optrefimages(j,:,:)=reshape(refImages*c,[xdim ydim]);
end