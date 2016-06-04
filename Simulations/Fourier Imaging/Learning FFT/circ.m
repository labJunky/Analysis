function [ output ] = circ( r )
%Circle2D Circle Function
%   A single point transition odd 
%   number of samples, circle function

% if magnetude is <= 0.5, output=1, else output=0
output = abs(r)<=1/2;

end

