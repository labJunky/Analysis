% Dark Ground Image Example

%Read in a test image,
%focas with a first lens, and manipulate the centre of the 
%fourier plane with a opaque object.
%Image that with a second lens. 
%The lens configuration is a standard 4f arrangement.

image = imread('USAF1951B250','png'); % read in a test image

[M,N]=size(image);
image=flipud(image); % flip the rows of the image
Ig = single(image); %integer - float type cast
Ig=Ig/max(max(Ig)); %normalise
Ig=abs(Ig-1);

ug = sqrt(Ig); % image of target

lambda = 0.5*10^-6; %wavelength of light [m]
wxp = 12e-3; %radius of the exit pupil [m]
zxp = 125e-3; %distance from exit pupil to image plane [m]
fnumber = zxp/(2*wxp);
fo = wxp/(lambda*zxp); %cut-off spacial frequency

L = 0.6e-3; %A very small area, set by the sampling of the test image
du=L/M; %That's du=1.2e-6 [m], a very fine grid
u=-L/2:du:L/2-du; %Setup the grid
v=u;
[U,V]=meshgrid(u,v); %Grid

fu=-1/(2*du):1/L:1/(2*du)-(1/L); %Tranform to a Spacial frequency grid
fv=fu;
[Fu,Fv] = meshgrid(fu,fv);

H = circ(sqrt(Fu.^2+Fv.^2)/fo); %Coherent Transfer function of a lens aperture
% (in frequency space)

w=30e-6; %Disk radius
disk = abs(circ(sqrt(U.^2+V.^2)/(2*w))-1);

Gg=fft2(fftshift(ug))*du*du; %Light field through first lens
H=fftshift(H);
fourierField = ifftshift(Gg);
fourierField=fourierField.*disk; %At the focus of the first lens is the opaque disk
Gdf = fftshift(fourierField);
ui=ifftshift(ifft2(Gdf.*H))*(1/du)*(1/du); %convolve with len aperture
Ii=(abs(ui)).^2; %Light intensity

figure(1)
imagesc(u,v,nthroot(abs(fourierField).^2,4)); %4th root so we can see something
%imagesc(u,v,Ig);
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
imagesc(Ii);
colormap('gray');
xlabel('u (m)'); ylabel('v (m)');axis square;
axis xy;


figure(3)
vvalue = 1.2;%-2*0.8e-4;
vindex=75;%round(vvalue/du+(M/2+1));
plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
xlabel('u (m)');ylabel('Irradiance');