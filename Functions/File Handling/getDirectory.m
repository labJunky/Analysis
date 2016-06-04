function [dataDirectory, todaysDataDir, analysisSettingsDir, remoteDrive] = getDirectory(varargin)
%getDirectory
% Using the ip address of the computer, this function returns the path
% string to the data directorys of the computer
%
% Inputs: varargin is an optional input if you want to get the directory of
% a different computer than the one the function is executed on.
%
%Example:
%[dataDir, todaysDataDir, analysisSettingsDir] = getDirectory();
%dataDir = 'D:\AtomChip Data\'
%todaysDataDir = 'D:\AtomChip Data\2012\1205\120509\'
%analysisSettingsDir = 'D:\AtomChip Data\Analysis\Analysis Settings\'
%
%dataDir = getDirectory('192.168.104.186');
%Returns the directory structure of the imaging computer

%Get computer ip address using java.
ip = char(java.net.InetAddress.getLocalHost.getHostAddress);
sep = filesep;
dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];

% set defaults for optional inputs
optargs = {ip};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[ip] = optargs{:};

switch ip
    case '192.168.104.171' %Paul's laptop
        dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
        matlabDir = [dataDirectory 'Analysis\'];
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        analysisSettingsDir = [matlabDir 'Analysis Settings\'];
        remoteDrive = 'U:\Data\AtomChip Data\';
    case '192.168.104.187' %Experiment Control Computer
        dataDirectory = 'D:\AtomChip Data\';
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        matlabDir = [dataDirectory 'Analysis\'];
        analysisSettingsDir = [matlabDir 'Analysis Settings\'];
        remoteDrive = 'Z:\Data\AtomChip Data\';
    case '192.168.104.186' %Imaging Computer
        dataDirectory = 'E:\AtomChip Data\';
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        matlabDir = [dataDirectory 'Analysis\'];
        analysisSettingsDir = [matlabDir 'Analysis Settings\'];
        remoteDrive = 'Z:\Data\AtomChip Data\';
    case '192.168.90.36' %Darth analysis computer
        dataDirectory = '/mnt/workspace/Data/AtomChip Data/';
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        matlabDir = [dataDirectory 'Analysis/'];
        analysisSettingsDir = [matlabDir 'Analysis Settings/'];
        remoteDrive = dataDirectory;
    case '172.22.191.195' %mac ntu analysis computer
        dataDirectory = '/Users/paul/Data/University stuff/NTU/Data';
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        matlabDir = ['/Users/paul/Data/Code Projects/Matlab/Analysis/'];
        analysisSettingsDir = [matlabDir 'Analysis Settings/'];
        remoteDrive = dataDirectory;
    case 'mac_ntu' %mac ntu analysis computer
        dataDirectory = '/Users/paul/Data/University stuff/NTU/Data';
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        matlabDir = ['/Users/paul/Data/Code Projects/Matlab/Analysis/'];
        analysisSettingsDir = [matlabDir 'Analysis Settings/'];
        remoteDrive = dataDirectory;
    otherwise %Paul's laptop
        dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
        matlabDir = [dataDirectory 'Analysis\'];
        todaysDataDir = [dataDirectory dateString];
        exists = exist(todaysDataDir, 'dir');
        analysisSettingsDir = [matlabDir 'Analysis Settings\'];
        remoteDrive = 'U:\Data\AtomChip Data\';
end

if isempty(varargin)
    %Turn the directory exists warning off
    warning('off', 'MATLAB:MKDIR:DirectoryExists');

    %Make Folders
    mkdir([todaysDataDir 'Images' sep 'ObjectImages']);
    mkdir([todaysDataDir 'Images' sep 'RefImages']);
    mkdir([todaysDataDir 'Images' sep 'BGImages']);
    mkdir([todaysDataDir 'Images' sep 'MatlabProcessed']);

    %Turn directory exists warning on again.
    warning('on', 'MATLAB:MKDIR:DirectoryExists');
end



