function [ temperature ] = measureTemperature( scriptFile )
%MEASURETEMPERATURE Measures the temperature of a cloud of atoms, using the
%input script. 
% Assumes that the BEC program is running in the main application instance
% of labview.
%
% Inputs:
%           scriptFile: is the full path to the script you wish to run

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

[d, scriptName] = fileparts(scriptFile);

%Label the parameter which will be scanned. In this case the expansion time
%of the cloud.
parameterName = 'Expansion_time';
times = [0.5, 1:10];
for i=times
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = i;
    disp(['parameter ' parameterName ' new value = ' num2str(value)]);
    %Change the parameter in the script
    changeScriptParameter(scriptDoc, parameterName, value);
    %Save the modified script
    xmlwrite(scriptFile, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(2);
    %run the script
    [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
    %Display the timestamp.
    disp([timeStamp ' ' scriptName]);
    if stoppedByUser
        disp('Experiment Stopped');
        break
    end
end

%wait for analysis to finish
pause(2);

if stoppedByUser
else
    [timeStamps, data] = getLastNResults(length(times));
    sizeX = data(:,3);
    name = [timeStamps(1,1) ' ' scriptName];
    [d,todaysDir] = getDirectory();
    savePath = [todaysDir name '.fig'];
    [initialCloudSize, temperature, residual] = FitTemperature(times, sizeX, name, savePath);
end
end

