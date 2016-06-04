function diff = fit_simp(x,X,Y)

A = x(1);
B = x(2);
C = x(3);
D = x(4);

diff = A+B*exp(-0.5*((X-C)/D).^2) - Y;