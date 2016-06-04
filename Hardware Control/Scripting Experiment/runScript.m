function [timeStamp, stoppedByUser] = runScript( viServer, scriptPath )
%RUNSCRIPT Runs an experiment script using the Labview BEC program
%   Labview must be up and running already, started from Matlab and the
%   viserver must have been initalised. 

%Set the paths.
runAScriptPath = 'D:\Code Projects\Labview\x2 Lite 2011\Hal\testing\runAScript.vi';

%runAScriptPath = 'D:\Code Projects\Labview\x2 Lite AtomChip\Hal\testing\runAScript.vi';

%Run the Dipole Trap Script.
runAScript = invoke(viServer, 'GetVIReference', runAScriptPath);
runAScript.SetControlValue('Path', scriptPath);
disp('running script');
runAScript.Run(0); %Run the Script, and wait for it to finish

%Get the timestamp of the last ran script
timeStamp = runAScript.GetControlValue('TimeStamp');
stoppedByUser = runAScript.GetControlValue('stoppedByUser');

end

