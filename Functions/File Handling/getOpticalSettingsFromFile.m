function [pixel_size, magnification] = getOpticalSettingsFromFile()
%This function opens the Analysis settings xml file, and read the 
%pixel_size and magnification we are using in the imaging setup.

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

dir = directory();
settings_file = [dir.getAnalysisDir('bitwise') 'Analysis_Settings.xml'];

settingsDoc = xmlread(settings_file);

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
pixel_size = eval(xpath.compile('//Optical_settings/pixel_size').evaluate(settingsDoc, XPathConstants.STRING));
magnification = eval(xpath.compile('//Optical_settings/magnification').evaluate(settingsDoc, XPathConstants.STRING));

