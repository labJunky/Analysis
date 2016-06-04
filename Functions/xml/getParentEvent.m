function eventNode = getParentEvent( node )
%GETPARENTEVENT Get the Parent Event
%   

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%find the parent event
parent = node.getParentNode();
parentNodeName = char(parent.getNodeName());
while ~strcmp(parentNodeName, 'event')
    parent = parent.getParentNode();
    parentNodeName = char(parent.getNodeName());
end
eventNode = parent;

end

