function [ u2 ] = propTF( u1, L, lambda, z );
%PROPTF Propagation - transfer function approach
%   Assumes same x and y side lengths and a
%   uniform sampling
%   u1 is the source plane field
%   L source and observation plane side length
%   lambda wavelength
%   z propagation distance
%   u2 observation plane field

[M,N] = size(u1); %get input field array size
dx = L/M;   %sample interval
dy = dx;
%k = 2*pi/lambda; %wavenumber

fx = -1/(2*dx): 1/L : 1/(2*dx)-(1/L); %fx Frequency space
fy = fx; %fy Frequency space
[FX, FY] = meshgrid(fx,fy);

H = exp(-j*pi*lambda*z*(FX.^2+FY.^2)); %Fresnal transfer function
H = fftshift(H); %shifted transfer function
U1 = fft2(fftshift(u1))*dx*dy;
U2 = H.*U1; %multiply fourier transforms
u2 = ifftshift(ifft2(U2))*(1/dx)*(1/dy); %inv fft, and centre on observation field

end

