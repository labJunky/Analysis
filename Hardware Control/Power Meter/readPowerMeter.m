% read power meter

loadlibrary('PM100D_labview','PM100D_labview');

calllib('PM100D_labview', 'InitPM100D');

for i=1:1000
    a(i) = calllib('PM100D_labview', 'MeasurePowerPM100D');
    figure(1)
    plot(a)
end

calllib('PM100D_labview', 'ClosePM100D');
unloadlibrary('PM100D_labview');
