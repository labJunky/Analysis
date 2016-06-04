classdef directory
    %directory represents the file directories of the computer you run it
    %on, or the computer you specify, using the ip address, in the
    %constructor.
    properties 
        DataDir;
        TodaysDataDir;
        AnalysisDir;
        AnalysisSettingsDir;
        RemoteDrive;
        ObjImages;
        RefImages;
        BgImages;
        Processed;
        Bitwise;
        Imaging;
        Imaging_Data;
        Control;
        LvProcessed
    end
    methods
        function obj = directory(varargin)
            % Using the ip address of the computer, this function returns the path
            % string to the data directorys of the computer
            %
            % Inputs: varargin is an optional input if you want to get the directory of
            % a different computer than the one the function is executed on.
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
                obj.DataDir = 'C:\Users\Administrator\Desktop\Crete\Data\';
                obj.AnalysisDir = [obj.DataDir 'Analysis\'];
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings\'];
                obj.RemoteDrive = 'U:\Data\AtomChip Data\';
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];
                obj.Bitwise = 'U:\Data\AtomChip Data\';
                obj.Imaging = 'X:\AtomChip Data\';
                obj.Imaging_Data = 'V:\Data\AtomChip Data\';
                obj.Control = 'W:\AtomChip Data\';
            case '192.168.104.187' %Experiment Control Computer
                obj.DataDir = 'D:\AtomChip Data\';
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisDir = [obj.DataDir 'Analysis\'];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings\'];
                obj.RemoteDrive = 'Z:\Data\AtomChip Data\';
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];              
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];
                obj.Bitwise = 'Z:\Data\AtomChip Data\';
                obj.Imaging = 'Y:\AtomChip Data\';
                obj.Imaging_Data = 'X:\Data\AtomChip Data\';
                obj.Control =obj.DataDir;
            case '192.168.104.186' %Imaging Computer
                obj.DataDir = 'E:\AtomChip Data\';
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisDir = [obj.DataDir 'Analysis\'];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings\'];
                obj.RemoteDrive = 'Z:\Data\AtomChip Data\';
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];
                obj.Bitwise = 'Z:\Data\AtomChip Data\';
                obj.Imaging = 'D:\AtomChip Data\';
                obj.Imaging_Data = 'E:\AtomChip Data\';
                obj.Control = 'Y:\AtomChip Data\';
            case '192.168.90.36' %Darth analysis computer
                obj.DataDir = '/mnt/workspace/Data/AtomChip Data/';
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisDir = [obj.DataDir 'Analysis/'];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings/'];
                obj.RemoteDrive = obj.DataDir;
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep]; 
                obj.Bitwise = obj.DataDir;
                obj.Imaging = 'mnt/imaging/AtomChip Data/';
                obj.Imaging_Data = 'mnt/imaging-data/AtomChip Data/';
                obj.Control = 'mnt/control/AtomChip Data/';
            case 'darth.imaging' %Darth analysis computer, /mnt/imaging-data
                obj.DataDir = '/mnt/imaging-data/AtomChip Data/';
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisDir = ['/mnt/imaging/AtomChip Data/' 'Analysis/'];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings/'];
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];                
            otherwise %Paul's laptop
                obj.DataDir = 'C:\Users\Administrator\Desktop\Crete\Data\';
                obj.AnalysisDir = [obj.DataDir 'Analysis\'];
                obj.TodaysDataDir = [obj.DataDir dateString];
                obj.AnalysisSettingsDir = [obj.AnalysisDir 'Analysis Settings\'];
                obj.RemoteDrive = 'U:\Data\AtomChip Data\';
                obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
                obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
                obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
                obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];
                obj.Bitwise = 'U:\Data\AtomChip Data\';
                obj.Imaging = 'X:\AtomChip Data\';
                obj.Imaging_Data = 'V:\Data\AtomChip Data\';
                obj.Control = 'W:\AtomChip Data\';
            end

            if isempty(varargin)
                %Turn the directory exists warning off
                warning('off', 'MATLAB:MKDIR:DirectoryExists');

                %Make Folders
                mkdir([obj.TodaysDataDir 'Images' sep 'ObjectImages']);
                mkdir([obj.TodaysDataDir 'Images' sep 'RefImages']);
                mkdir([obj.TodaysDataDir 'Images' sep 'BGImages']);
                mkdir([obj.TodaysDataDir 'Images' sep 'MatlabProcessed']);

                %Turn directory exists warning on again.
                warning('on', 'MATLAB:MKDIR:DirectoryExists');
            end
        end %Constructor
        
        function obj = getDirectoryOnDate(obj, drive, date)
            %date example '120622'
            daten = datenum(date,'yymmdd');
            sep = filesep;
            dateString = [datestr(daten,'yyyy'),sep,datestr(daten,'yymm'),sep,datestr(daten,'yymmdd'), sep];
            switch drive
                case 'bitwise'
                    obj.DataDir = obj.Bitwise;
                case 'imaging'
                    obj.DataDir = obj.Imaging;
                case 'imaging-data'
                    obj.DataDir = obj.Imaging_Data;
                case 'control'
                    obj.DataDir = obj.Control;
                otherwise
                    obj.DataDir = obj.DataDir;
            end
            obj.TodaysDataDir = [obj.DataDir dateString];
            obj.ObjImages = [obj.TodaysDataDir 'Images' sep 'ObjectImages', sep];
            obj.RefImages = [obj.TodaysDataDir 'Images' sep 'RefImages', sep];
            obj.BgImages = [obj.TodaysDataDir 'Images' sep 'BGImages', sep];
            obj.Processed = [obj.TodaysDataDir 'Images' sep 'MatlabProcessed', sep];
            obj.LvProcessed = [obj.TodaysDataDir 'Images' sep 'ProcessedAbsorptionImages', sep];
        end %getDirectoryOnDate
        
        function folderPath = getAnalysisDir(obj, drive)
            switch drive
                case 'bitwise'
                    folderPath = [obj.Bitwise 'Analysis' filesep 'Analysis Settings'...
                                    filesep];
                case 'imaging'
                    folderPath = [obj.Imaging 'Analysis' filesep 'Analysis Settings'...
                                    filesep];
                case 'control'
                    folderPath = [obj.Control 'Analysis' filesep 'Analysis Settings'...
                                    filesep]; 
            end
        end %getAnalysisDir
      
    end %methods
end %class