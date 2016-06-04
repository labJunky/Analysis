timeDif = 0.0001

switch 1 %search for the true case
    case 0.01 >= timeDif<=0.09
       timeDif = timeDif * 10^3;
       units = 'ms';
    case timeDif <= 0.0009
       timeDif = timeDif * 10^6;
       units = 'us';
    case timeDif > 0.09
        units = '';
end

units
