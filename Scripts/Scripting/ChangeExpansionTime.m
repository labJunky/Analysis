viServer = actxserver('LabVIEW.Application');
scriptFile='D:\AtomChip Data\Scripts\ScriptRunFolder\MOT U-wire.xml';
[d, scriptName] = fileparts(scriptFile);

%Set the path to the script to run
parameterName = 'Expansion_Time';
times = [0.6:0.3:5.1]*10^-3;

%Load the script 
scriptDoc = loadScript(scriptFile);
value = times(1);
disp(['parameter ' parameterName ' new value = ' num2str(value)]);
%Change the parameter in the script xml
changeScriptParameter(scriptDoc, parameterName, value)

%check that it has changed
readScriptParameter(scriptDoc, parameterName)

%then normally you should save the change to the file.