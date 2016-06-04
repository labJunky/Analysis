function [dummy] = scanFields( scriptFile )
%SCANFIELDS Scan the MOT magnetic fields.
%Input script. 
% Assumes that the BEC program is running in the main application instance
% of labview.
%   

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');
dummy=1;
[d, scriptName] = fileparts(scriptFile);

%Set the path to the script to run
biasCurrent = 'BiasField';
updownCurrent = 'UpDownField';
biasScanValues = [1.2:0.1:1.9]; %15 steps
updownScanValues = [0.2:0.1:1.0]; %13 steps
flag=0;
for j=updownScanValues
    scriptDoc = loadScript(scriptFile);
    updown = j;
    disp(['parameter ' updownCurrent ' new value = ' num2str(updown)]);
    %Change the parameter in the script xml
    changeScriptParameter(scriptDoc, updownCurrent, updown);
    %Save the modified script
    xmlwrite(scriptFile, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(2);
    for i=biasScanValues
        %Load the script 
        value = i;
        disp(['parameter ' biasCurrent ' new value = ' num2str(value)]);
        %Change the parameter in the script xml
        changeScriptParameter(scriptDoc, biasCurrent, value);
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
            flag=1;
            break
        end
    end
    if (flag==1);
        break
    end
end

end