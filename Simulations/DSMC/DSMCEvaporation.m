function gamma = DSMCEvaporation(beta,N)

time = N;

%Initial parameters:

mass         = 1.443160648e-25; %Mass of Rubidium 87 particle
kB           = 1.38e-23;        %Boltzmann constant
initialTemp  = 0.000060;        %Initial Temperature
A            = 10;              %Magnetic field gradient
omegax       = 16.2*2*pi;       %Trap parameters
omegay       = 17.6*2*pi;
omegaz       = 9.8*2*pi;
initialN     = 20000;           %Initial number of simulated particles
numberReal   = 2*10^8;          %Number of real particles
a            = 5.3e-9;          
crossSection = 8*pi*a^2;        %Scattering cross section
mu           = 9.27e-24;        %Bohr magneton

%Time step
dt = 10^-4;

% %Random number seed used by MATLAB to ensure each simulation uses the same
% %random numbers
% s = RandStream('mt19937ar');
% 
% %Specify the standard deviations of the initial distributions
% V = sqrt(kB*initialTemp /  mass);
% X = sqrt(kB*initialTemp / (mass*omegax^2));
% Y = sqrt(kB*initialTemp / (mass*omegay^2));
% Z = sqrt(kB*initialTemp / (mass*omegaz^2));
% % Z = 0.5*sqrt(kB*initialTemp / (mass*omegaz^2));
% 
% A = mass * omegax^(2) * X / mu;
% 
% %Set up the initial distributuions
% vo(:,1:3) = V*randn(s,initialN,3);
% xo(:,1)   = X*randn(s,initialN,1);
% xo(:,2)   = Y*randn(s,initialN,1);
% xo(:,3)   = Z*randn(s,initialN,1);

load thermalisedHarmonic.mat

xo = x;
v0 = v;

N = time;

% Set a simulation time of 60 seconds
%N = 60 / dt;

tic
%Complie c file
mex -Dtrap=2 C:\Users\Administrator\Desktop\Crete\Data\Analysis\DSMC\DSMCSimulationMexEvaporationV04.cpp

%Perform simulation
[x,v] = DSMCSimulationMexEvaporationV04(N,dt,xo,vo,beta,omegax,omegay,omegaz);
toc
%Load the data from the text file produced by the simualtion
load output.txt

%Plot the log log plot
figure

plot(log(output(:,2)), log(output(:,6)))
xlabel('log (N)')
ylabel('log (T)')

%Calculate the slope of the linear fit
pTemp = polyfit(log(output(:,2)),log(output(:,6)),1);
pEnergy = polyfit(log(output(:,2)),log(output(:,7) + output(:,8)),1);

gamma = pTemp(1);

%Save the final distribution
save output.mat