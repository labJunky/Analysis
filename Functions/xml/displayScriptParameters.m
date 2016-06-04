function displayScriptParameters( scriptDoc )
% DISPLAYSCRIPTPARAMETERS Display all the parameters in a script
%   Inputs: scriptDoc is a reference to the script DOM document

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
% Find all parameter nodes and display there content.
parameterNodes= xpath.compile('.//*[@parameter]').evaluate(scriptDoc, XPathConstants.NODESET);
delayNodes = xpath.compile('.//*[@label]').evaluate(scriptDoc, XPathConstants.NODESET);

%Display all the nodes with parameters
for i = 1:parameterNodes.getLength()
    node = parameterNodes.item(i-1); %nodeset.item('index') indexs from 0
    %find the parent event
    parent = node.getParentNode();
    parentNodeName = char(parent.getNodeName());
    while ~strcmp(parentNodeName, 'event')
        parent = parent.getParentNode();
        parentNodeName = char(parent.getNodeName());
    end
    %extract and display information
    name = char(node.getNodeName());
    parameter = char(node.getAttribute('parameter'));
    value = char(node.getTextContent());
    channel_name = char(parent.getAttribute('channel_name'));
    disp(['channel' ' ' channel_name ' ' ', parmeter ' name ' ' parameter ' = ' value]) 
end

%Display all the nodes with parameters
for i = 1:delayNodes.getLength()
    node = delayNodes.item(i-1);
    delay = char(node.getAttribute('label'));
    value = char(xpath.compile('time_difference').evaluate(node, XPathConstants.STRING));
    disp(['Delay parameter ' delay ' = ' value]);
end
    
end

