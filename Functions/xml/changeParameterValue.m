function changeParameterValue( parameterNode, eventNode, value )
%CHANGEPARAMETERVALUE Changes the value of the event
%  Inputs: parameterNode, eventNode, value

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;


parameterNode.setTextContent(num2str(value));

end

