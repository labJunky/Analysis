function diff = fit_MOT_lifetime(x,X,Y)

A = x(1);
B = x(2);
C = 1/x(3);


diff = A+B*exp(-C*X) - Y;

