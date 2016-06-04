function changeDelayTimeD( delayNode, value )
%CHANGEDELAYTIMED Change the Time difference of a Delay event
%   Inputs: delayNode is the delay event node
%           value is the new time difference to be applied

value = value*10^6;

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%Get Previous event time
previousEvent = delayNode.getPreviousSibling;
timeNode = xpath.compile('time').evaluate(previousEvent, XPathConstants.NODE);
previousTime = str2double(timeNode.getTextContent());

%Add new delay
newTime = previousTime + value;
delayNode.setAttribute('time', num2str(newTime));
timeNode = xpath.compile('time').evaluate(delayNode, XPathConstants.NODE);
timeNode.setTextContent(num2str(newTime));
timeNode = xpath.compile('time_difference').evaluate(delayNode, XPathConstants.NODE);
timeNode.setTextContent(num2str(value));

nextEvent = delayNode.getNextSibling;
%Delay all later events
while ~isempty(nextEvent)
    timeDNode = xpath.compile('time_difference').evaluate(nextEvent, XPathConstants.NODE);
    timeDiff = str2double(timeDNode.getTextContent);
    newTime = timeDiff + newTime;
    nextEvent.setAttribute('time', num2str(newTime));
    timeNode = xpath.compile('time').evaluate(nextEvent, XPathConstants.NODE);
    timeNode.setTextContent(num2str(newTime));
    nextEvent = nextEvent.getNextSibling;
end

end

