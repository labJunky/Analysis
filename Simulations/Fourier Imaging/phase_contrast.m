% Phase Contrast Image Example

%Read in a test image and convert to a phase function,
%focas with a first lens, and manipulate the centre of the 
%fourier plane with a phase shift.
%Image that with a second lens. 
%The lens configuration is a standard 4f arrangement.

image = imread('USAF1951B250','png'); % read in a test image

[M,N]=size(image);
image=flipud(image); % flip the rows of the image
Ig = single(image); %integer - float type cast
Ig=Ig/max(max(Ig)); %normalise
theta = sqrt(Ig)*pi/100; %Convert intensity to a phase

ug = exp(j*theta); % phase image of target

lambda = 0.5*10^-6;
phase_shift = 3*pi/2;

L = 0.6e-3; %A very small area, set by the sampling of the test image
du=L/M; %That's du=1.2e-6 (m), a very fine grid
u=-L/2:du:L/2-du;
v=u;

Gg=fft2(fftshift(ug))*du*du;
Gg(1,1)=Gg(1,1)*exp(j*phase_shift); %phase shift central pixel of image
ui=ifftshift(ifft2(Gg))*(1/du)*(1/du);
Ii=(abs(ui)).^2;

figure(1)
imagesc(u,v,abs(ug).^2);
colormap('gray');
xlabel('u (m)'); ylabel('v (m)');
axis square;
axis xy;

% figure(2)
% surf(fu,fv,ifftshift(H).*0.99);
% camlight left; lighting phong;
% shading interp;
% xlabel('fv (cyc/m)');
% ylabel('fu (cyc/m)');

figure(2)
imagesc(nthroot(Ii,2));
colormap('gray');
xlabel('u (m)'); ylabel('v (m)');axis square;
axis xy;


figure(4)
vvalue = 1.2;%-2*0.8e-4;
vindex=75;%round(vvalue/du+(M/2+1));
plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
xlabel('u (m)');ylabel('Irradiance');