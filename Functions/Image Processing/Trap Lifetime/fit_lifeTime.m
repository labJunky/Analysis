function y = fit_lifeTime(x,T)

No = x(1);
Gamma = x(2);



y=No*exp(-Gamma*T);