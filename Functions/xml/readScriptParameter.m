function [value] = readScriptParameter(scriptDoc, parameterName)
%CHANGESCRIPTPARAMETER Replaces the value of the parameter in the script 
%   Input: 
%       scriptDoc is the DOM reference to the loaded script
%       parameterName is the name of the parameter you want to change,
%           as it is written in the xml document
%       value is the new value you want the parameter to have
%
%   Note that this function only changes the parameter in the DOM model,
%   and does not change the file. Use xmlwrite() to write the changes into
%   the file.

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%Find the parameter event. './/*[@parameter=''MOT_loading_time'']'
xpathStr = ['.//*[@parameter=''' parameterName ''']'];
parameterNode = xpath.compile(xpathStr).evaluate(scriptDoc, XPathConstants.NODE);
try 
    %find the parent event
    value = str2double(parameterNode.getTextContent());
catch ME1
    try
        xpathStr = ['.//*[@label=''' parameterName ''']'];
        delayNode = xpath.compile(xpathStr).evaluate(scriptDoc, XPathConstants.NODE);
        timeNode = xpath.compile('time_difference').evaluate(delayNode, XPathConstants.NODE);
        value =str2double( timeNode.getTextContent());
    catch ME2
        fprintf('\n\r');
        disp('You have selected a parameter that does not exist.');
        disp('Here is a list of all available parameters in the script');
        displayScriptParameters(scriptDoc);
        value= 1;
    end
        
end

     
end