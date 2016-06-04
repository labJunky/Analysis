%Read DSMC results file.

filepath = 'C:\Users\Administrator\Desktop\DSMC\out.txt';

fileID = fopen(filepath);
c = textscan(fileID, '%f %f %f %f %f %f %f',...
    'delimiter', ',');
fclose(fileID);

time = c{1}(2:end);
kineticEn = c{2}(2:end);
potentialEn = c{3}(2:end);
temp = c{4}(2:end);
cloudRadius = c{5}(2:end);
collisionNum = c{6}(2:end);
atomNum = c{7}(2:end);

%# moving average smoothing
window = 1;
h = ones(window,1)/window;
y = filter(h, 1, temp);
plot(y)