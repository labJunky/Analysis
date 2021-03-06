function [ temperature ] = measureTemperature( scriptFile )
%MEASURETEMPERATURE Measures the temperature of a cloud of atoms, using the
%input script. 
% Assumes that the BEC program is running in the main application instance
% of labview.
%   

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

[d, scriptName] = fileparts(scriptFile);

%Set the path to the script to run
parameterName = 'Expansion_Time';
disp('here is the script')
times = [0.6:0.3:5.1]*10^-3;
for i=times
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = i;
    disp(['parameter ' parameterName ' new value = ' num2str(value)]);
    %Change the parameter in the script xml
    changeScriptParameter(scriptDoc, parameterName, value);
    %Save the modified script
    xmlwrite(scriptFile, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(3);
    %run the script
    [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
    %Display the timestamp.
    disp([timeStamp ' ' scriptName]);
    if stoppedByUser
        disp('Experiment Stopped');
        temperature=0;
        break
    end
end

%wait for analysis to finish
% ((pause(2);
% 
% if stoppedByUser
% else
%     [timeStamps, data] = getLastNResults(length(times));
%     atomNum = data(1,1);
%     sizeX = data(:,3)';
%     sizeY = data(:,4)';
%     name = [char(timeStamps(1,1)) ' ' scriptName];
%     %sizeY(sizeY<0)=[];
%     %times(find(sizeY<0))=[];
%    
%     
%     [d,todaysDir,as,remoteDir] = getDirectory();
%     sep = filesep;
%     dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
%     savePath = [remoteDir dateString 'Images' sep 'MatlabProcessed' sep name '.fig'];
%     
%     [initialCloudSize, temperature, psd, residual] = FitTemperature(times*10^3, sizeY, name, savePath, atomNum, sizeX(1));    
%     
% end
% end))
% 
