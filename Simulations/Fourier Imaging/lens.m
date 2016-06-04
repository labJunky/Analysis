function [ u2 ] = lens( u1, L1,lambda, fo )
%LENS Fraunhofer pattern of a lens
%   u1 - source plane field
%   L1 - source plane side length
%   fo - focal length
%   u2 - observation plane field
%   L2 - observation plane side length

[M,N] = size(u1);
dx = L1/M;
dy=dx;
k=2*pi/lambda;

x = -L1/2 : dx : L1/2 - dx;
y=x;
[X, Y]=meshgrid(x,y);

c=1/(j*lambda*fo)*exp( j*k/(2*fo)*(X.^2 + Y.^2) );
u2 = c.*ifftshift(fft2(fftshift(u1)))*dx*dy;

end

