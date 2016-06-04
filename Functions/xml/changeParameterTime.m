function changeParameterTime( parameterNode, eventNode, value )
%CHANGEPARAMETERTIME Changes the Time of the event, and delays all later
%events
%  Inputs: parameterNode, eventNode, value
%
%TODO: Update time difference of event

value = value*10^6;

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%Edit the time. (delay by 1 microsecond for example)
newTime = value;
parameterNode.setTextContent(num2str(newTime)); %edit the parameter
%edit the event attribute
eventNode.setAttribute('time', num2str(newTime));
timeNode = xpath.compile('time').evaluate(eventNode, XPathConstants.NODE);
timeNode.setTextContent(num2str(newTime));

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

