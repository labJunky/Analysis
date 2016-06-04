function sigma = rotate(theta,x,data)
y=sum(imrotate(data,theta,'nearest','crop'));
Atheta=Fit1D(x,y);
sigma=Atheta(4);