function [ uout ] = tilt( uin,L,lambda,alpha,theta )
%TILT tilts the phasefront of the wave
%   uin - input field
%   L - side length
%   lambda -wavelength
%   alpha - tilt angle
%   theta - rotation angle
%   uout - output wave

[M,N] = size(uin); %uniform sampling
dx = L/M;
k = 2*pi/lambda;

x = -L/2 : dx : L/2-dx;
y=x;
[X, Y] = meshgrid(x,y);

uout = uin.*exp( j*k*(X*cos(theta) + Y*sin(theta))*tan(alpha) );


end

