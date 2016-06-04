function F = FitGaussian(A,x)
Offset=A(1);
Amp=A(2);
Centre=A(3);
Sigma=A(4);
F=Offset+Amp*exp(-0.5*(x-Centre).^2./Sigma.^2);
end