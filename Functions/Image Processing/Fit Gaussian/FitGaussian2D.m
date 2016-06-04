function F = FitGaussian(A,x,y,Zdata)
Fit=Gaussian2D(A,x,y);
F=sum(sum((Fit-Zdata).^2));
end