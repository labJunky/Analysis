%Run an experiment script in labview.

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

%runBECBasic = startBECProgram( viServer );
%pause(); %Unpause when the control program is ready

%Set the path to the script to run
dipoleTrapScript = '\\Zeus\C$\Documents and Settings\Administrator\Desktop\Crete\Data\Scripts\ScriptRunFolder\Dipole Trap Script_v2.xml';
parameterName = 'MOT_Loading_Time';
for i=1:10
    scriptDoc = loadScript(dipoleTrapScript);
    value = i;
    disp(['parameter ' parameterName ' new value = ' num2str(value)]);
    changeScriptParameter(scriptDoc, parameterName, value);
    xmlwrite(dipoleTrapScript, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(2);
    %run the script
    timeStamp = runScript( viServer, dipoleTrapScript );
    disp(timeStamp);
end