function [ u2 ] = propIR( u1, L, lambda, z )
%PROPIR Propagation with impulse responce approach
%   Assumes same x and y sie lengths and uniform sampling
%   u1 is the source plane field
%   L source and observation plane side length
%   lambda wavelength
%   z propagation distance
%   u2 observation plane field

[M,N] = size(u1); %get input field array size
dx = L/M;   %sample interval
dy = dx;
k = 2*pi/lambda; %wavenumber

x = -L/2 : dx : L/2-dx; %fx Frequency space
y=x;
[X, Y] = meshgrid(x,y);

h = 1/(j*lambda*z)*exp(j*k/(2*z)*(X.^2+Y.^2)); %impulse
H = fft2(fftshift(h))*dx*dy; %shifted transfer function
U1 = fft2(fftshift(u1))*dx*dy;
U2 = H.*U1; %multiply fourier transforms
u2 = ifftshift(ifft2(U2))*(1/dx)*(1/dy); %inv fft, and centre on observation field

end

