function [ w ] = seidel_5( u0, v0, X, Y, wd, w040, w131, w222, w220, w311 )
%SEIDEL_5 Computes the wavefront OPD for first 5 Seidel wavefront
% aberration coefficients and defocus.
%   
% u0, v0 - normalised image plane coordinate
% X, Y - normalised pupil coordinate arrays (e.g. meshgrid() )
% wd - defocus;
% w040 - spherical aberration
% w131 - coma
% w222 - astigmatism
% w220 - field curvature
% w311 - distortion

beta = atan2(v0, u0); % image rotation angle
u0r = sqrt(u0^2 + v0^2); %image height

% rotate grid
Xr = X*cos(beta)+Y*sin(beta);
Yr = -X*sin(beta) + Y*cos(beta);

% Seidel polynomials
rho2 = Xr.^2+Yr.^2;
w = wd*rho2 +...
    w040*rho2.^2 +...
    w131*u0r*rho2.*Xr +...
    w222*u0r^2*Xr.^2 +...
    w220*u0r^2*rho2 +...
    w311*u0r^3*Xr;
    
end

