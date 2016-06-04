%Load a Script, and extract events from the xml
%Then plot the values for each channel.

%Does not understand ramp events yet.

%path = ['C:\Users\Administrator\Desktop\Crete\Data\Scripts\ScriptRunFolder\'...
%'Dipole Trap Script_v2 Molasses (double shutter).xml'];
%Dipole Trap Script_v2 Molasses (double shutter)
%dipole_grey MOT_V1
%currentVersionMOT
%iptsetpref('ImshowBorder','tight');

path = ['C:\Users\Administrator\Desktop\Crete\Data\Scripts\ScriptRunFolder\'...
'currentVersionMOT.xml'];

scriptDoc = loadScript( path );

import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
% Find all parameter nodes and display there content.
eventNodes= xpath.compile('//event').evaluate(scriptDoc, XPathConstants.NODESET);
time = zeros(eventNodes.getLength(),1);
dt = zeros(eventNodes.getLength(),1);
channel = cell(eventNodes.getLength(),1);
value = cell(eventNodes.getLength(),1);
stage = cell(eventNodes.getLength(),1);

%Display all the nodes with parameters
for i = 1:eventNodes.getLength()
    node = eventNodes.item(i-1); %nodeset.item('index') indexs from 0
    time(i) = (10^-6)*str2double(char(node.item(0).getTextContent()));
    %dt(i) = (10^-6)*str2double(char(node.item(1).getTextContent()));
    channel{i} = char(node.item(2).getTextContent());
    value{i} = char(xpath.compile('newValue').evaluate(node, XPathConstants.NODE).getTextContent());
    stage{i} = char(xpath.compile('stage').evaluate(node, XPathConstants.NODE).getTextContent());
end

%nonlinear scaling of time
%first get the differences
power = 0.3;
timex(1) = 0;
for i = 1:(length(time)-1)
   dt(i) = time(i+1)-time(i);
   timex(i+1) = timex(i)+(dt(i))^power;
end

%Group by channel
 channels = channel;
 index={};
 j=1;
for i = 1:eventNodes.getLength();
     if isempty(find(vertcat(index{:})==i))
        index{j} = find(strcmp(channels,channel{i})==1);
        j=j+1;
     end
end
%index contains a list of indices for each event of the same channel

k=1;
values = {};
channelName = {};
plotTimes = {};
for i =1:length(index)
    channelName{i} = channels{index{i}};
    for j = 1:length(index{i})
        if isnan(str2double(value{index{i}(j)}))
            values{i}(k) = getStateFromDb(channelName{i}, value{index{i}(j)});
        else values{i}(k) = str2double(value{index{i}(j)});
        end
        plotTimes{i}(k) = timex(index{i}(j));
        k = k+1;   
    end
    subplot(length(index),1,i)
    stairs( plotTimes{i}(:), values{i}(:))
    %sort out axis, and label the subplots
end



 
    

    



