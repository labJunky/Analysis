i=1;
while i==1;
    [t,d]=getLastNResults(20);
    atomNumber=d(:,1)';
    figure(1)
    subplot(2,1,1)
    plot(atomNumber)
    odMax=d(:,2)';
    figure(1)
    subplot(2,1,2)
    plot(odMax)
    pause(0.5)
end
