% Load a script, and change a parameter

%[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
scriptFile = [scriptDir 'testParameters.xml'];

%Load the script.
scriptDoc = loadScript(scriptFile);

%Name the parameter you want to change and its new value
parameterName = 'MOT_Loading_Time';
value = 3.0;

%Find the parameter in the script and change its value, along with all
%affected events
changeScriptParameter(scriptDoc, parameterName, value);

%Print the script
%xmlwrite(scriptDoc)











