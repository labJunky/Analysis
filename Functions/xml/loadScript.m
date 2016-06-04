function [ scriptDoc ] = loadScript( scriptFile )
%LOADSCRIPT Loads the Script xml into a DOM object.
%   Input: scriptFile is the full path to the script.xml
%   Output: A reference to the scriptDoc document in the DOM model

%Load the script.
% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

scriptDoc = xmlread(scriptFile);

%remove whitespace
xpathExp = xpath.compile('//text()[normalize-space(.) = '''']');  
emptyTextNodes = xpathExp.evaluate(scriptDoc, XPathConstants.NODESET);
for i=1:emptyTextNodes.getLength()
    emptyTextNode = emptyTextNodes.item(i-1);
    emptyTextNode.getParentNode().removeChild(emptyTextNode);
end

end

