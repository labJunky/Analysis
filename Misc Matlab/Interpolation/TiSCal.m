% interpolate calibration data for TiS AOM

input = [0.1:0.05:1]; %Input to DDS (0-1) = (0-1.2) Vpp
lp = [1.75 2.79 4.03 5.35 6.87 8.67 10.33 11.95...
        13.75 15.62 17.2 20.03 22.4 24.06 25.2 26.04 26.8 27.0 27.02];
    
plot(input, lp, '-o');
xlabel('DDS Input (0-1) = (0-1.2) Vpp');
ylabel('Laser Power mW After AOM');
title('Calibration of TiS AOM');

% % Compare linear interpolation with a spline. 
% % The differences are very small.
% inputi = [0.5:0.005:0.7];
% i = find(input>=0.5 & input <= 0.7);
% lpi = interp1(input, lp, inputi, 'spline');
% figure(2)
% plot(input(i), lp(i), '--o', inputi, lpi);
% xlabel('DDS Input (0-1) = (0-1.2) Vpp');
% ylabel('Laser Power mW After AOM');
% title('Calibration of TiS AOM');
