function [ROIx, ROIy, signalMask] = getROIFromFile()
% getROIFromFile
%
% Reads a file called Analysis_Settings.xml, and extracts the 
% Region of Interest and the signal mask used by the data analysis
% routines.
% The ROI in this case specifies how much of the image is cropped.
% If for example the camera takes images of 1024 by 1024
% and you specify a ROI region in x of 200:800, and  y 
% of 400:600 only that region of the image will be loaded.
% 
% The Analysis settings file should be located in the Data directory:
% '...Data\Analysis\Analysis Settings\'
%
% Example:
%   [ROIx, ROIy, signalMask] = getROIFromFile()
%   ROIx = 1:1392
%   ROIy = 1:1024
%   signalMask = [1, 1392, 250, 400]
%
%   In this case the ROI takes into account the whole image (pixelfly)
%   and the signal region is along x from 1:1392 pixels, and 
%   in y from 250:400 pixels. This region would be excluded in the image
%   fringe removal process, for example.
%
% This file also contains the magnification and pixelsize of the camera.
% See also getOpticalSettingFromFile

% get the xpath mechanism into the workspace
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

dir = directory();
settings_file = [dir.getAnalysisDir('bitwise') 'Analysis_Settings.xml'];

settingsDoc = xmlread(settings_file);

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
ROIx = eval(xpath.compile('//ROI/Crop/Cropx').evaluate(settingsDoc, XPathConstants.STRING));
ROIy = eval(xpath.compile('//ROI/Crop/Cropy').evaluate(settingsDoc, XPathConstants.STRING));
signalx = eval(xpath.compile('//ROI/Signal_Region/signalx').evaluate(settingsDoc, XPathConstants.STRING));
signaly = eval(xpath.compile('//ROI/Signal_Region/signaly').evaluate(settingsDoc, XPathConstants.STRING));

signalMask = [signalx(1),signalx(end), signaly(1), signaly(end)];

