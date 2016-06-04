function [ y, scriptFile ] = testlv( x, varargin )
%TESTLV Summary of this function goes here
%   Detailed explanation goes here

y=x+1;
% set defaults for optional inputs
c=1;
optargs = {c};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
length(varargin)
optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[c] = optargs{:};
% %Open a handle to the labview vi server.
% viServer = actxserver('LabVIEW.Application');
% scriptFile = ['C:\Users\Administrator\Desktop\Crete\Data\'...
%                 'Scripts\ScriptRunFolder\MOT U-wire.xml'];
% 
% %run the script
% [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
% 
% viServer.delete();
end

