function [ output ] = circle2D( x, y )
%Circle2D Circle Function
%   A single point transition odd 
%   number of samples, circle function

% if magnetude is <= 0.5, output=1, else output=0
output = sqrt(x.^2+y.^2)<=1/2;

end

