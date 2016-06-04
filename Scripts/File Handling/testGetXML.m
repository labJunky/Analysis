
% Read an xml file and use xpath search in Java to get elements of the 
%xml document.

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

sep = filesep;
dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
matlabDir = [dataDirectory 'Analysis\'];
anaysisSettingsDir = [matlabDir 'Analysis Settings\'];
settings_file = [anaysisSettingsDir 'Analysis_Settings.xml'];

settingsDoc = xmlread(settings_file);

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
ROIx = eval(xpath.compile('//ROI/Crop/Cropx').evaluate(settingsDoc, XPathConstants.STRING));
ROIy = eval(xpath.compile('//ROI/Crop/Cropy').evaluate(settingsDoc, XPathConstants.STRING));
signalx = eval(xpath.compile('//ROI/Signal_Region/signalx').evaluate(settingsDoc, XPathConstants.STRING));
signaly = eval(xpath.compile('//ROI/Signal_Region/signaly').evaluate(settingsDoc, XPathConstants.STRING));

%This used the XPathConstants.STRING constant. 
%Here is a list of all of them:
%http://docs.oracle.com/javase/1.5.0/docs/api/javax/xml/xpath/XPathConstants.html

[pixel_size, magnification] = getOpticalSettingsFromFile();
