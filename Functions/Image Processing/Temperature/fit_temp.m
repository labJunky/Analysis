function diff = fit_temp(x,X,Y)

A = x(1);
T = x(2);
c = (1.38*10^(-23))/(87*1.6*10^(-27)); %kb/m

diff = A^2 + c*T*X.^2 - Y.^2;
