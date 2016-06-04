u0=1;
v0=1;
wd = 0; %defocus
w040=1; %spherical aberration
w131=1; %Coma
w222=1; %astigmatism
w220=0; %Field curvature
w311=0; %Distortion

L1 = 2; %side length (m)
M = 1000;%8*512; %samples
dx1 = L1/M;
x = -L1/2 : dx1 : L1/2 - dx1; %sample space
y = x;
[X,Y]=meshgrid(x,y);

w = seidel_5(u0,v0,X,Y,wd,w040,w131,w222,w220,w311);
P=circ(sqrt(X.^2+Y.^2));
mask=(P==0); %(mask=1 if P=0, else 0)
w(mask) = NaN; %remove zeros

figure(1)
surfc(x,y,w);
colormap('jet')
camlight left;
lighting phong;
xlabel('x');ylabel('y');

shading interp
set(gcf,'Renderer','zbuffer')
set(findobj(gca,'type','surface'),...
    'FaceLighting','phong',...
    'AmbientStrength',.3,'DiffuseStrength',.8,...
    'SpecularStrength',.9,'SpecularExponent',25,...
    'BackFaceLighting','unlit');