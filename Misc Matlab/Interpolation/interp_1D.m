% A Script to test out data interpolation in Matlab.

% Some data. In this case, the frequency responce of the human hear.
freq = [20:10:100 200:100:1000 1500 2000:1000:10000]; %frequencies in Hz
spl = [76 66 59 54 49 46 43 40 38 22 ...
        14 9 6 3.5 2.5 1.4 0.7 0 -1 -3 ...
            -8 -7 -2 2 7 9 11 12]; %minimum audible sound pressure level in db, 
                                   %referenced to 1000 Hz

% Plot the data        
semilogx(freq, spl, '-o');
xlabel('Frequency in Hz');
ylabel('Relative Sound Pressure Level in dB');
title('Threshold of Human Hearing');
grid on;

% compare the spline interpolation with the linear one at the minima
freqi = 2e3:100:5e3;
spli = interp1(freq, spl, freqi, 'spline');
i = find(freq>=2e3 & freq <= 5e3); % find the indices in the range 2e3<=freq<=5e3

% Plot the comparison
figure(2)
semilogx(freq(i), spl(i), '--o', freqi, spli)
grid on