%Load an experiment script into matlab and get/set some variables.

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
scriptFile = [scriptDir 'Dipole Trap Script_v2.xml'];

scriptDoc = xmlread(scriptFile);

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
event = xpath.compile('//event[@channel_name=''MOT coil'']').evaluate(scriptDoc, XPathConstants.NODE);
newValue = eval(xpath.compile('newValue').evaluate(event, XPathConstants.STRING));
newValueNode = xpath.compile('newValue').evaluate(event, XPathConstants.NODE);
newValue = newValue + 4;

%Replace
newValueNode.setTextContent(num2str(newValue));

%Save the script
xmlwrite(scriptFile,scriptDoc);
xmlremoveextralines(scriptFile);

