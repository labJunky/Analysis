function [ uout ] = focus( uin,L,lambda,fo )
%TILT tilts the phasefront of the wave
%   uin - input field
%   L - side length
%   lambda -wavelength
%   fo - focal distance (+ converge, - diverge)
%   uout - output wave

[M,N] = size(uin); %uniform sampling
dx = L/M;
k = 2*pi/lambda;

x = -L/2 : dx : L/2-dx;
y=x;
[X, Y] = meshgrid(x,y);

uout = uin.*exp( -j*k/(2*fo)*(X.^2 + Y.^2) );


end

