function runBECBasic = startBECProgram( viServer )
%STARTBECPROGRAM Interfaces to Labview and starts the runBECBasic program
%   Inputs: viServer is an activeX server reference to the windows labview
%           application
%   Outputs: runBECBasic is a viserver reference to the labview vi

runBECBasicPath = 'C:\Users\Administrator\Desktop\Crete\x2 Lite local\Hal\testing\runBECBasic.vi';

%Start the experiment control program, if it is not already running
runBECBasic = invoke(viServer, 'GetVIReference', runBECBasicPath); %Get reference
state =  runBECBasic.get('ExecState');
if strcmp(state,'eRunTopLevel')
else
    runBECBasic.FPWinOpen = 1; %Open the front panel
    runBECBasic.SetControlValue('Hardware On?', 0); %Run with no hardware
    runBECBasic.SetControlValue('Camera on?', 0); %Run with no camera
    runBECBasic.Run(1); %Run the vi, and do not wait for it to finish
end

end

