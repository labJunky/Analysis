%analysis dipole trap Lifetime

times = [50:50:1000]*10^-3;

[t,d]=getLastNResults(length(times));
data = d(:,1)';

plot(times,data)







