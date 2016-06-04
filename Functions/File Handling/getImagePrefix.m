function [prefix,prefix2] = getImagePrefix(imageNumber)
%NTU images are called '_0001' to '_9999'
%This function returns ths prefix for a given number.
%for example imageNumber = 1 returns '_000'
%image number = 99 returns '_00'

     if imageNumber == 99;
        prefix = '_00';
        prefix2 = '_0';
    elseif imageNumber ==9;
        prefix = '_000';
        prefix2 = '_00';
    elseif imageNumber ==999;
        prefix = '_0';
        prefix2 = '_';
    elseif imageNumber < 10;
        prefix = '_000';
        prefix2 = prefix;
    elseif imageNumber < 100;
        prefix = '_00';
        prefix2 = prefix;
    elseif imageNumber >= 1000;
        prefix = '_';
        prefix2 = prefix;
    else prefix = '_0'; prefix2= prefix;
     end
end
