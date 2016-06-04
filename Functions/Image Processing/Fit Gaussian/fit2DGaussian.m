function realsigmas = fit2DGaussian(data, ROI)


ROIx=ROI(3):ROI(4);
ROIy=ROI(1):ROI(2);
FilterSize=5;
[X,Y]=meshgrid(ROIx,ROIy);

% %make fake data to fit
% Offset=0;
% Amp=1;
% CentreX=300;
% CentreY=400;
% CXX=1/4; 
% CXY=1/32; 
% CYY=1/64;
% %These numbers should be recovered by the fit:
% Ainitial=[Offset, Amp, CentreX, CentreY, CXX, CXY, CYY];
% data=Gaussian2D(Ainitial,X,Y);

% initial 1D fit int the x-direction to obtain accurate starting points for the 2D fit.
y=double(sum(data,1));
x=ROIx;

%Smooth the data a little:
yfiltered=filter(ones(1,FilterSize)/FilterSize,1,y);

%Calculated initial fit parameters for x axis
[ymax,index]=max(yfiltered);
xmax=x(index);
[ymin,index]=min(yfiltered);
xmin=x(index);
[HWHM,index]=min(abs(yfiltered-0.5*ymax));
sigma0=abs(x(index)-xmax)/sqrt(2*log(2));
Ainit=[ymin,ymax-ymin,xmax,sigma0];
lowerbounds=[ymin,0,min(x),0];
upperbounds=[ymax,ymax-ymin,max(x),10*(max(x)-min(x))];

options=optimset('Algorithm', 'trust-region-reflective','Display', 'off');
%fit the smoothed data:
[AtmpX,~,~,~,tmpoutput1x] =...
    lsqcurvefit(@Gaussian1D,Ainit,x,yfiltered,lowerbounds,upperbounds,options);

%Use the results from the smoothed fit to fit the real data: 
[Ax,~,~,~,tmpoutput2x] =...
    lsqcurvefit(@Gaussian1D,AtmpX,x,y,lowerbounds,upperbounds,options);
datax=y;

%Fit the y-direction 1D
%Calculate inital parameters for the fit
y=double(sum(data,2))';
x=ROIy;
yfiltered=filter(ones(1,FilterSize)/FilterSize,1,y);
[ymax,index]=max(yfiltered);
xmax=x(index);
[ymin,index]=min(yfiltered);
xmin=x(index);
[HWHM,index]=min(abs(yfiltered-0.5*ymax));
sigma0=abs(x(index)-xmax)/sqrt(2*log(2));
Ainit=[ymin,ymax-ymin,xmax,sigma0];
lowerbounds=[ymin,0,min(x),0];
upperbounds=[ymax,ymax-ymin,max(x),10*(max(x)-min(x))];

%Fit the y-direction 1D
options=optimset('Algorithm', 'trust-region-reflective','Display', 'off');
[AtmpY,~,~,~,tmpoutput1y] =...
    lsqcurvefit(@Gaussian1D,Ainit,x,yfiltered,lowerbounds,upperbounds,options);
[Ay,~,~,~,tmpoutput2y] =...
    lsqcurvefit(@Gaussian1D,AtmpY,x,y,lowerbounds,upperbounds,options);
datay=y;

%Plot stuff from the 1D fits:
figure(1)
subplot(2,1,1)
plot(ROIx,datax,'b.',ROIx,Gaussian1D(Ax,ROIx),'r')
subplot(2,1,2)
plot(ROIy,datay,'b.',ROIy,Gaussian1D(Ay,ROIy),'r')

%%%
%Fit 2D function using input from the 1D fits as starting points.
%%%
options = optimset('TolX',1e-7,'TolFun',1e-7,'GradObj','off','Algorithm', 'interior-point','MaxFunEvals',10000);
myfun=@(A)FitGaussian2D(A,X,Y,data);
Offset=min(min(data));
Amp=max(max(data))-min(min(data));
CentreX=Ax(3); CentreY=Ay(3);
CXX=1./Ax(4).^2; CXY=1./(Ax(4)*Ay(4)); CYY=1./Ay(4).^2;
InitWeights=[Offset,Amp,CentreX,CentreY,CXX,CXY,CYY];
%LowerBounds=0.1*InitWeights;
%UpperBounds=9*InitWeights;
%[NewWeights,fval] = fmincon(myfun,InitWeights,[],[],[],[],LowerBounds,UpperBounds,[],options);
%[NewWeights,fval] = fminunc(myfun,InitWeights,options);
[NewWeights,fval] = fminsearch(myfun,InitWeights,options);
disp(num2str(NewWeights))
Offsetfinal=NewWeights(1);
Ampfinal=NewWeights(2);
CentreXfinal=NewWeights(3);
CentreYfinal=NewWeights(4);
CXXfinal=NewWeights(5);
CXYfinal=NewWeights(6);
CYYfinal=NewWeights(7);
Cmat=[CXXfinal, CXYfinal; CXYfinal, CYYfinal];
realsigmas=eigs(Cmat)
disp(['Var1: ',num2str(1/sqrt(realsigmas(1)))])
disp(['Var2: ',num2str(1/sqrt(realsigmas(2)))])

%Plot the results from the 2D fit.
plotregion=80:120;
figure(2)
subplot(3,1,1)
imagesc(data(plotregion,plotregion))
colorbar
title('The data')
subplot(3,1,2)
imagesc(Gaussian2D(NewWeights,X(plotregion,plotregion),Y(plotregion,plotregion)))
colorbar
title('The fit')
subplot(3,1,3)
imagesc(log10(abs(data(plotregion,plotregion)-...
    Gaussian2D(NewWeights,X(plotregion,plotregion),Y(plotregion,plotregion)))))
colorbar
title('logarithmic plot of the difference')
drawnow

