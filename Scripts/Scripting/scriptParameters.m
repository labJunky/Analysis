%Test getting and setting script parameters.

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
scriptFile = [scriptDir 'rampTesting.xml'];

scriptDoc = xmlread(scriptFile);

displayScriptParameters(scriptDoc);

rampStart = 'RampStart';
rampStop = 'RampStop';

%[value] = readScriptParameter(scriptDoc, parameter)

changeScriptParameter(scriptDoc, rampStart,3.0);
changeScriptParameter(scriptDoc, rampStop, 0.001);
%Save the modified script
xmlwrite(scriptFile, scriptDoc);