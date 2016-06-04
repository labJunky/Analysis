%Learn how to use the matlab FFT for running Fourier Optics Simulations

%Discrete Fourier transform of a 2d rectangle or ellipse function.

%Rectangle/ellipse Widths;
wx = 0.015; wy = 0.015; %HWHM's in (m)

%Sampling parameters
L = 0.2;      %Side length x&y (m)
M = 200;    %Samples/side length
dx = L/M;   %x Sample interval (m)
dy = dx;    %y Sample interval (m)  

x = -L/2 : dx : L/2-dx; %Real Space x coordinates
y = x;                  %Real Space y coordinates
[X,Y] = meshgrid(x,y);  %Grid coordinates

fx = -1/(2*dx): 1/L : 1/(2*dx)-(1/L); %fx Frequency space
fy = fx; %fy Frequency space

%g = rect(X/(2*wx)).*rect(Y/(2*wy)); %2D rectangle function
g = circle2D(X/(2*wx), Y/(2*wy)); %2D circle function

figure(1)
subplot(2,1,1)
imagesc(x,y,g)
axis square;
axis xy;
xlabel('x (m)'); ylabel('y (m)');

%2D FFT
fo = fft2(fftshift(g))*dx*dy; %2D FFT (fft2) and scale
subplot(2,1,2)
surf(fx,fy,abs(ifftshift(fo)));
colormap('jet');
camlight left;
lighting phong;
shading interp;
xlabel('fx cyc/m)'); ylabel('fy (cyc/m)');

%IFFT back to original
figure(2)
imagesc(x,y,ifftshift(ifft2(fo))*(1/dx)*(1/dy));
axis square;
axis xy;
