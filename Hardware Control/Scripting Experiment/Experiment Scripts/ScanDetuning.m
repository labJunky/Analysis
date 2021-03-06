function ScanDetuning( scriptFile )
%SCANMOTLOADING Scan the MOT loading time to determine the MOT loading
%rate.
%Input script. 
% Assumes that the BEC program is running in the main application instance
% of labview.
%   

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

[d, scriptName] = fileparts(scriptFile);

%Set the path to the script to run
parameterName = 'MOT_Detuning';
res2_3=17.2; %MHz
detuning=[-26,-24,-22,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0]+res2_3;
for i=detuning
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = i;
    disp(['parameter ' parameterName ' new value = ' num2str(value)]);
    %Change the parameter in the script xml
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

end