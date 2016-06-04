function changeParameterTimeD( parameterNode, eventNode, value )
%CHANGEPARAMETERTIMED Changes the Time difference of the event, and delays all later
%events
%  Inputs: parameterNode, eventNode, value

value = value*10^6;

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%Get Previous event time
previousEvent = eventNode.getPreviousSibling
timeNode = xpath.compile('time').evaluate(previousEvent, XPathConstants.NODE);
previousTime = str2double(timeNode.getTextContent());

%Add new delay
newTime = previousTime + value;
eventNode.setAttribute('time', num2str(newTime));
timeNode = xpath.compile('time').evaluate(eventNode, XPathConstants.NODE);
timeNode.setTextContent(num2str(newTime));
parameterNode.setTextContent(num2str(value)); %edit the parameter

nextEvent = eventNode.getNextSibling;
%Delay all later events
while ~isempty(nextEvent)
    timeDNode = xpath.compile('time_difference').evaluate(nextEvent, XPathConstants.NODE);
    timeDiff = str2double(timeDNode.getTextContent);
    newTime = timeDiff + value;
    nextEvent.setAttribute('time', num2str(newTime));
    timeNode = xpath.compile('time').evaluate(nextEvent, XPathConstants.NODE);
    timeNode.setTextContent(num2str(newTime));
    nextEvent = nextEvent.getNextSibling;
end

end

