function writeAnalysisResultsToFile(filename, timestamp, imageNumber, resultsArray, varargin)
% writeAnalysisResultsToFile filename timestamp resultsArray analysisType
% 
% Opens a file and saves the results into that file.
% The results should be in the form:
% resultsArray = [AtomNumber, OpticalDensityMax, Sizex, SizeY];
%
% analysisType is the type of analysis used.
% For example: 'FR_Absorption' for the fringe removal absorption analysis
%              'Absorption' for standard absorption analysis
%              'Fluorescence' etc...
%
% Example:
%   writeAnalysisResultsToFile('c:\test.txt', '120511_1104_12',
%                                      [0.5,1.04,12,0.5],'FR_Absorption');
%   '120511_1104_12, 0.50, 1.04, 12.00, 0.50, 'FR_Absorption, \n\r\n\r'

% Get Directory
[d,todaysDir]=getDirectory();
directory = [todaysDir 'Images' filesep 'MatlabProcessed' filesep];

% set defaults for optional inputs
optargs = {directory};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;

% Place optional args in memorable variable names
[directory] = optargs{:};

%Check If file exists
exists = exist(filename, 'file')==2;

%if the file does not exist, create it and write:
%'TimeStamp', ' Atom Number', ' Max Optical Density', ' Size X (mm)', ' Size Y (mm)'
if exists ~= 1
    column_headers = {'TimeStamp', ' Image Number', ' TOF (ms)',' compressed', ' Atom NumberX', 'Atom NumberY', ' Size X (mm)', ' Size Y (mm)', ' Size Peak X (mm)',' CentreX',' CentreY'};
    
    %Open File, convert cell into a string, and write it into the file
    %before closing it.
    fid = fopen(filename,'W');
    csvFun = @(str)sprintf('%s,',str);
    xchar = cellfun(csvFun, column_headers, 'UniformOutput', false);
    xchar = strcat(xchar{:});
    xchar = strcat(xchar(1:end-1),'\r\n');
    fprintf(fid,xchar);
    %fprintf(fid,'\n\r');
    fclose(fid);
end

%format results array into a string, with timestamp at the beginning
s = sprintf('%0.4f, ',resultsArray);
formattedResults = [timestamp, ', ',imageNumber, ', ', s];

%Open file, append results string to the end of it, and close
fid = fopen(filename,'a');
fprintf(fid,[formattedResults, '\r\n']);
%fprintf(fid,'\n\r');
fclose(fid);


