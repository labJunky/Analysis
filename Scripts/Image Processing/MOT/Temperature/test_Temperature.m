
%Here is some data to test the FitTemperature routine
times = [1*10^-6, 1*10^-3 , 2*10^-3, 3*10^-3, 4*10^-3, 5*10^-3, 6*10^-3, 7*10^-3, 8*10^-3];
sizeX = [0.568, 0.603, 0.641, 0.726, 0.799, 0.87, 0.917, 0.986, 1.05]*10^(-3);
name = 'test';

%Run the routine on the data.
[x,temp, resnorm] = FitTemperature(times(1:6), sizeX(1:6), name);
resnorm