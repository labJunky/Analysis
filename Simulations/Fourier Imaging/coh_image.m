% Coherent Image Example

image = imread('USAF1951B250','png'); % read in a test image
[M,N]=size(image);
image=flipud(image); % flip the rows of the image
Ig = single(image); %integer - float type cast
Ig=Ig/max(max(Ig)); %normalise
j=1i; %For efficient complex number calculations
ug = sqrt(Ig).*exp(1i*2*pi*rand(M)*0); % ideal image field * random phase factor (speckel)

lambda = 0.5*10^-6; %Wavelength of light
wxp = 6.25e-3; %radius of the exit pupil
zxp = 125e-3; %distance from exit pupil to image plane
fnumber = zxp/(2*wxp);
fo = wxp/(lambda*zxp); %cut-off spacial frequency


L = 0.6e-3; %A very small area, set by the sampling of the test image
du=L/M; %That's du=1.2e-6 (m), a very fine grid
u=-L/2:du:L/2-du;
v=u;

fu=-1/(2*du):1/L:1/(2*du)-(1/L); %Spacial frequency grid
fv=fu;
[Fu,Fv] = meshgrid(fu,fv);

H = circ(sqrt(Fu.^2+Fv.^2)/fo); %Coherent Transfer function

H=fftshift(H);
Gg=fft2(fftshift(ug))*du*du;
Gi=Gg.*H; %Convolution of field and lens aperture
ui=ifftshift(ifft2(Gi))*(1/du)*(1/du);
Ii=(abs(ui)).^2;

figure(1)
imagesc(u,v,Ig);
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
imagesc(u,v,nthroot(Ii,2));
colormap('gray');
xlabel('u (m)'); ylabel('v (m)');axis square;
axis xy;


figure(4)
vvalue = -2*0.8e-4;
vindex=round(vvalue/du+(M/2+1));
plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
xlabel('u (m)');ylabel('Irradiance');
