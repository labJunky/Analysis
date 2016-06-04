%load channel configuration from the database

%lets look for the Cooling_Detuning for example which is connected to
%Ao8a_Ao_00
channelName = 'Coil_Switch';
state = 'on';

path = ['C:\Users\Administrator\Desktop\Crete\Data\Scripts\Settings Database\'...
'DeviceSettingsAtomChip.xml'];

dbDoc = loadScript( path );

import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
% Find the channel_config node that has a mappedTo node value of the
% channelName i.e. 'Cooling_Detuning' in this case.
% channel_configNode= xpath.compile(['//channel_config[mapping/mappedTo=''' channelName ''']'])...
%     .evaluate(dbDoc, XPathConstants.NODE);
channel_configNode= xpath.compile(['//channel_config[mapping/mappedTo=''' channelName ''']'])...
    .evaluate(dbDoc, XPathConstants.NODE);

%what is the channel type?
channelType = char( xpath.compile('channel_type')...
    .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() );

%based on the channel type, find the state value
switch 1
    case strcmp(channelType,'ao');
        stringResult = char( xpath.compile(['mapping/states/' state])...
            .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() );
        result = str2double(stringResult);
    case strcmp(channelType, 'ethernet');
        stringResult = char( xpath.compile(['mapping/states/' state])...
            .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() );
        result = str2double(stringResult);
    case strcmp(channelType, 'do');
        stringResult = char( xpath.compile(['mapping/states/' state])...
            .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() )
        result = str2double( char( xpath.compile(['digital_config/levels/' stringResult])...
            .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() ) );
    case strcmp(channelType, 'rf');
        stringResult = char( xpath.compile(['mapping/states/' state '/amplitude'])...
            .evaluate(channel_configNode, XPathConstants.NODE).getTextContent() );
        result = str2double( stringResult );      
end
  
units = xpath.compile('mapping/units')...
    .evaluate(channel_configNode, XPathConstants.NODE).getTextContent();

getStateFromDb(channelName, state)

