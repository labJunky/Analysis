function [ output ] = rect( x )
%RECT Rectangle Function
%   A single point transition odd 
%   number of samples, rectangle function

% if magnetude of x is <= 0.5, y=1, else y=0
output = abs(x)<=1/2;

end

