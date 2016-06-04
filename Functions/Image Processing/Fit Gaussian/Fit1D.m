function A = Fit1D(x,y)
global iterations1D
if size(x)==size(y)
    %Smooth the data a little:
    FilterSize=5;
    yfiltered=filter(ones(1,FilterSize)/FilterSize,1,y);
    [ymax,index]=max(yfiltered);
    xmax=x(index);
    [ymin,index]=min(yfiltered);
    xmin=x(index);
    [~,index]=min(abs(yfiltered-0.5*ymax));
    sigma0=abs(x(index)-xmax)/sqrt(2*log(2));
    Ainit=[ymin,ymax-ymin,xmax,sigma0];
    lowerbounds=[ymin,0,min(x),0];
    upperbounds=[ymax,ymax-ymin,max(x),10*(max(x)-min(x))];
    options=optimset('TolX',1e-8,'TolFun',1e-8,'Algorithm', 'trust-region-reflective','Display', 'off');
    %fit the smoothed data:
    [AtmpX,~,~,~,tmpoutput1x] =...
        lsqcurvefit(@Gaussian1D,Ainit,x,yfiltered,lowerbounds,upperbounds,options);
    %Use the results from the smoothed fit to fit the real data:
    [A,~,~,~,output1D] =...
        lsqcurvefit(@Gaussian1D,AtmpX,x,y,lowerbounds,upperbounds,options);
    iterations1D=[iterations1D,output1D.iterations+tmpoutput1x.iterations];
else
    A=0;
    disp('Dimension error in fit')
end