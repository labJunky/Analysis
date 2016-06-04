% square/circlular beam profile propagation example
% An infinite uniform and homogenious light field illuminates
% an aperture, the light field is calucated at the observation plane

L1 = 0.25; %side length (m)
M = 250;%8*512; %samples
dx1 = L1/M;
x1 = -L1/2 : dx1 : L1/2 - dx1; %sample space
y1 = x1;

lambda = 0.5e-6; %wavelength
k=2*pi/lambda;

w=12.5e-3; %apperture HWHM (m)
z=0.25; %propagation distance (m)

[X1, Y1] = meshgrid(x1,y1);

% Source field is a uniform intensity plane wave i.e. u1=1
% illuminating an aperture
%u1=rect(X1/(2*w)).*rect(Y1/(2*w)); %source field at square aperture

% opaque circular aperture (expect to see Poisson spot)
%u1=abs(circle2D(X1/(2*w),Y1/(2*w))-1); %source field at cirlcular aperture
u1=circle2D((X1)/(2*w),(Y1)/(2*w));
I1 = abs(u1.^2); %apperture plane intensity

% figure(1)
% imagesc(I1);
% axis square;
% axis xy;
% xlabel('x (m)');
% ylabel('y (m)');
% title('Apperture plane, z=0');

% deg = pi/180;
% alpha=2e-5; %rad
% theta = 45*deg;
% [u1] = tilt(u1, L1, lambda,alpha,theta);
%[u1] = focus(u1,L1,lambda, 0.5);
ufocas = lens(u1, L1, lambda, 0.25);
%uap = abs(circle2D(X1/(2*w),Y1/(2*w))-1); aperture Fourier plane
%u2=ufocas.*uap;
u2=ufocas;
%[u2] = lens(ufocas, L1, lambda, 0.25);
%u2 = propTF(u1,L1,lambda,0.25); %propagate using Transfer function method
%u2 = propIR(u1,L1,lambda,z); %propagate using Impulse responce method

x2=x1; %obervation plane sample space
y2=y1;

I2=abs(u2.^2); %observation plane intensity z=2000 m

figure(2)
colormap('jet')
imagesc(x2,y2,nthroot(I2,4));
%set(gca, 'XLim', [-6e-5, 6e-5], 'YLim', [-6e-5, 6e-5])
axis square;
axis xy; 
xlabel('x (mm)');
ylabel('y (mm)');
title(['Observation plane, z=',num2str(z),' (m)']);

figure(3)
plot(x2,I2(M/2+1,:))
%axis([-6e-5,6e-5,0,16e6])



