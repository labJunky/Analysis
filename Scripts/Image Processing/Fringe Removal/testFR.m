% Run the fvringe removal analysis over a directory.
% In this case for one atom image.

dataDir = 'U:\Data\AtomChip Data\2012\1205\120504';
%dataDir = getDirectory();
%dateStr = '2012/1205/120514';
dateStr = '';
directory = [dataDir, dateStr];
%Included timestamps between: (first 50 reference images)
startTS = '120514_1719_32';
stopTS = '120514_1724_28';
t = cputime;
[time, sd] = removeFringesOverDirectory(directory, startTS, stopTS);
totalTimeTaken = cputime -t
mean(time(:))
mean(sd(:))

%how long does it take to load the images? 
%It takes 11 seconds to load 50 image sets (*2 because its ref + bg images each
%time).
%With 50 reference images it takes around 2.6 seconds to load and process
%the atom images. Giving back atomNumber etc.