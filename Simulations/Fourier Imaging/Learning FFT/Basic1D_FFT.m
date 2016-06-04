%Learn how to use the matlab FFT for running Fourier Optics Simulations

%Start with a 1D example
%Using a rectangle function and take the discrete fourier transform.
%Compare with the anaylitcal result and transform back to the original
%function. Then a convolution is shown between two Gaussian functions.

%Vector side length
L = 2;
%Number of samples
M = 200;
%Sample space interval (m/sample)
dx = L/M;
%Sample space (m)
x = -L/2:dx:L/2-dx;
%Frequency space sampling
fx = -1/(2*dx) : 1/L : 1/(2*dx)-(1/L);

% HWHM width w of rectangle (m)
w = 0.055;
y = rect( x/(2*w) );

figure(1);
subplot(3,1,1)
plot(x,y,'-o');
title('Original Function');
axis([-0.2 0.2 0 1.5]);
xlabel('Real Space x (m)');

yShift = fftshift(y); % Shift y ready for FFT
yiShift = ifftshift(yShift); % Shift back to get original

% figure(2)
% plot(yiShift,'-o');
% axis([80 120 0 1.5]);
% xlabel('index');

% Compute Fourier Transfom
fo = fft(yShift)*dx; %FFT and scale
yoriginal=ifftshift(ifft(fo))*(1/dx); %inverse FFT and scale

subplot(3,1,2)
fo_an=2*w*sinc(2*w*fx); %analytical result
plot(fx,abs(ifftshift(fo)),fx,abs(fo_an),':'); % plot magnitude centered
axis([-50 50 0 0.15])
title('FFT magnitude');
xlabel('Frequency space (cyc/m)');

subplot(3,1,3)
plot(x,ifftshift(ifft(fo))*(1/dx),'-o')
axis([-0.2 0.2 0 1.5])
title('IFFT[FFT] Original');
xlabel('Real Space x (m)');



% convolution of two Gaussians
wa = 0.3;
wb = 0.2;
ya = exp(-pi*(x.^2)/wa^2);
yb = exp(-pi*(x.^2)/wb^2);

figure(2)
subplot(2,1,1)
plot(x,ya,x,yb,'--');

fa=fft(fftshift(ya))*dx;
fb=fft(fftshift(yb))*dx;
dfx = 1/L;
con = ifft(fa.*fb)*(1/dx);
subplot(2,1,2)
plot(x,ifftshift(con));
