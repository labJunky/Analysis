clear all
ROIx=400:1:1000;
ROIy=200:1:450;
%FilterSize=1;
rotations=9;
angles=linspace(0,90,rotations+1);
[X,Y]=meshgrid(ROIx,ROIy);
% %make fake data to fit
Offset=0; Amp=1;
CentreX=275; CentreY=400;
CXX=1/10; CXY=1/100; CYY=1/150;
%These numbers should be recovered by the fit:
Ainitial=[Offset, Amp, CentreX, CentreY, CXX, CXY, CYY];
% data=Gaussian2D(Ainitial,X,Y)+0.0*rand(size(X));

 [dataDir, todaysDir] = getDirectory();
directory = todaysDir;

sep = filesep;
imageDir = [directory, 'Images', sep];
saveDir = [imageDir, 'MatlabProcessed', sep];

data = double(imread([saveDir '120522_0110_07  MLAbsorption.tif'],'PixelRegion',...
    {[ROIy(1) max(ROIy)], [ROIx(1) max(ROIx)]}));


%data storage
%widths=[]; positions=[];
global iterations1D; iterations1D=[];
global iterations2D; iterations2D=[]; 
% initial 1D fit int the x-direction to obtain accurate starting points for the 2D fit.
% Find starting value for CentreX:
y=double(sum(data,1));
x=ROIx;
Ax=Fit1D(x,y);
CentreX=Ax(3);
% Find starting value for CentreY:
y=double(sum(data,2))';
x=ROIy;
Ay=Fit1D(x,y);
CentreY=Ay(3);

%Here We need to centre the clouds image in the centre of the image
%so that the rotation will work. Else it will rotate around an offset.
data = double(imread([saveDir '120522_0110_07  MLAbsorption.tif'],'PixelRegion',...
    {[round(CentreY)-round(length(ROIy)/2) round(CentreY)+round(length(ROIy)/2)],...
    [round(CentreX)-round(length(ROIx)/2) round(CentreX)+round(length(ROIx)/2)]}));

%Find angle and value for minimum width
x=ROIx;
options = optimset('TolX',1e-5,'TolFun',1e-5,'GradObj','off','Algorithm', 'interior-point','MaxFunEvals',1000);
myfun=@(theta)rotate(theta,x,data);
InitWeights=[-5.0];
%Find the angle at which the width of the data is minimal
[minangle,minwidth,exitflag,output1D] = fminsearch(myfun,InitWeights,options);
disp(' ')
disp(['iterations for finding the minimum angle: ', num2str(output1D.iterations)])
maxangle=minangle+90;
CXXprime=1./minwidth.^2;
%calculate also the maximum width of the data
y=sum(imrotate(data,maxangle,'bilinear','crop'));
Ay=Fit1D(x,y);
CYYprime=1./Ay(4).^2;
disp(['minwidth: ',num2str(minwidth)])
disp(['maxwidth: ',num2str(Ay(4))])
%Plot stuff
figure(2)
subplot(3,1,1)
imagesc(data)
subplot(3,1,2)
imagesc(imrotate(data,minangle,'bilinear','crop'))
title(['rotated by ', num2str(minangle),' degrees'])
subplot(3,1,3)
imagesc(imrotate(data,maxangle,'bilinear','crop'))
title(['rotated by ', num2str(maxangle),' degrees'])
%CXXprime=1/minwidth.^2;
%CYYprime=1/maxwidth.^2;
theta=pi*minangle/180.0;
CXX=CXXprime*cos(theta).^2+CYYprime*sin(theta).^2;
CYY=CXXprime*sin(theta).^2+CYYprime*cos(theta).^2;
CXY=(CXXprime-CYYprime)*sin(theta)*cos(theta);
disp(['1/CXX= ',num2str(1/CXX)])
disp(['1/CXY= ',num2str(1/CXY)])
disp(['1/CYY= ',num2str(1/CYY)])
pause
%%%
%Fit 2D function using input from the 1D fits as starting points.
%%%
options2D = optimset('TolX',1e-7,'TolFun',1e-7,'GradObj','off','Algorithm', 'interior-point','MaxFunEvals',10000);
myfun=@(A)FitGaussian2D(A,X,Y,data);
Offset=min(min(data));
Amp=max(max(data))-min(min(data));
InitWeights=[Offset,Amp,CentreX,CentreY,CXX,CXY,CYY];
%LowerBounds=0.1*InitWeights;
%UpperBounds=9*InitWeights;
[NewWeights,fval,exitflag,output2D] = fminsearch(myfun,InitWeights,options2D);
%[NewWeights,fval,exitflag,output2D] = fmincon(myfun,InitWeights,[],[],[],[],LowerBounds,UpperBounds,[],options);

Offsetfinal=NewWeights(1);
Ampfinal=NewWeights(2);
CentreXfinal=NewWeights(3);
CentreYfinal=NewWeights(4);
CXXfinal=NewWeights(5);
CXYfinal=NewWeights(6);
CYYfinal=NewWeights(7);
Cmat=[CXXfinal, CXYfinal; CXYfinal, CYYfinal];
Cprimes=eigs(Cmat);
disp(['realwidths: ',num2str(sqrt(1/Cprimes(1))), ' and ', num2str(sqrt(1/Cprimes(2)))])
disp(['1/CXXfinal: ',num2str(1/CXXfinal)])
disp(['1/CXYfinal: ',num2str(1/CXYfinal)])
disp(['1/CYYfinal: ',num2str(1/CYYfinal)])
%Plot the results from the 2D fit.
figure(3)
subplot(3,1,1)
imagesc(data)
colorbar
title('The data')
subplot(3,1,2)
imagesc(Gaussian2D(NewWeights,X,Y))
colorbar
title('The fit')
subplot(3,1,3)
imagesc(log10(abs(data-Gaussian2D(NewWeights,X,Y))))
colorbar
title('logarithmic plot of the difference')
drawnow
disp(['iterations for the 1D search: ', num2str(sum(iterations1D))])
disp(['iterations for the 2D search: ', num2str(output2D.iterations)])
