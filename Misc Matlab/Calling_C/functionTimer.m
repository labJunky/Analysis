% time how long it takes to call and run a c function fact.c to take the
% factorial of a number, and compare this to matlabs own method.

for j=1:100
    tic
    for i = 1:100
        y = fact(100);
    end
    timeC(j) = toc;

    tic
    for i=1:100
        y = factorial(100);
    end
    timeM(j) = toc;
end

mean(timeC)
mean(timeM)