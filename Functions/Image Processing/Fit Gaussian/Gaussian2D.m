function F = Gaussian2D(A,x,y)
Offset=A(1);
Amp=A(2);
CentreX=A(3);
CentreY=A(4);
CXX=A(5); 
CXY=A(6); 
CYY=A(7);
xMx=0.5*(CXX*(x-CentreX).^2+2*CXY*(x-CentreX).*(y-CentreY)+CYY*(y-CentreY).^2);
F=Offset+Amp*exp(-xMx);
end