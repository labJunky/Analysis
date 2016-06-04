% Scan fields near the fibre optics on the chip.

%[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
%dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
dataDirectory = 'D:\AtomChip Data\';
scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
scriptFile = [scriptDir '08Amp-Dimple-CB3-CB2-CB1-CB4-Fibre-LR-InSitu-2Photon.xml'];

%Load the script and labview activeX control.
viServer = actxserver('LabVIEW.Application');
scriptDoc = loadScript(scriptFile);

%Name the parameter you want to change and its new value
iWireCurrentP = 'IWireCurrent';
upDownP = 'upDownCurrent';
biasP = 'biasCurrent';
cb3RampTimeP = 'cb3RampTime';
cb3RampStopP = 'cb3RampStop';
cb4RampTimeP = 'cb4RampTime';
cb4RampStopP = 'cb4RampStop';
magneticHoldTimeP = 'Fibre_Hold_Time';

rampTimeOriginal = 150000; %microSeconds
delayOriginal = 225000-rampTimeOriginal; %microSeconds

cb3StartValue = 0;
cb3StopFinal = 1.35; %it is turned negative below
cb4StartValue = 1.35;
cb4StopFinal = 0;

iWireValues = 0.4:0.1:0.6;
upDownCurrents = -0.5:-0.25:-2;
biasCurrents = 1:0.25:2.5;

%Points to scan
cbPositionPoints = 50;

i=0; %Loop counter
for x = updownCurrents; %Scan I-wire current
    
    updownValue = x;
    changeScriptParameter(scriptDoc, upDownP , upDownValue);
    j = 0; %Step counter
%     for y=1:numberOfPoints; %Scan conveyor belt
%         i = i+1
%         j = j+1;
%         n=numberOfPoints/j;
% 
%         cb3RampTimeValue = rampTimeOriginal/n;
%         cb3StopValue = -(cb3StartValue + cb3StopFinal/n);
%         cb4RampTimeValue = cb3RampTimeValue;
%         cb4StopValue = (cb4StartValue - cb4StartValue/n);
%         delayTime = delayOriginal + cb3RampTimeValue;
% 
%         changeScriptParameter(scriptDoc, cb3RampTimeP , cb3RampTimeValue);
%         changeScriptParameter(scriptDoc, cb3RampStopP , cb3StopValue)
% 
%         changeScriptParameter(scriptDoc, cb4RampTimeP , cb4RampTimeValue);
%         changeScriptParameter(scriptDoc, cb4RampStopP , cb4StopValue);
% 
%         changeScriptParameter(scriptDoc, magneticHoldTimeP , delayTime/1000000);
%         xmlwrite(scriptFile,scriptDoc);
    for y=biasCurrents;
        biasValue = y;
        changeScriptParameter(scriptDoc, biasP , biasValue);
        i = i+1
        j = j+1     

        pause(2);
        [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
        %Display the timestamp.
        disp([timeStamp ' ' scriptName]);
        if stoppedByUser
            disp('Experiment Stopped');
            flag=1;
            break
        end

        %analysis
%         if stoppedByUser;
%         else %Program still running
%             [dataDir, todaysDir, d, remoteDir] = getDirectory();
%             sep = filesep;
%             dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
%             directory = [dataDir, dateString, 'Images', filesep, 'ObjectImages', filesep];
%             atomFile = [directory, timeStamp,' Image 0_Pixis.tif'];
%             laserFile = [directory, timeStamp,' Image 1_Pixis.tif'];
%             atoms=imread(atomFile);
%             laser=imread(laserFile);
%             ROI=[18,1002,700,1000];
%             imagePath=[dataDir, dateString, 'Images', filesep,'ProcessedImages',filesep, timeStamp,' MLFluorescence.tif'];
%             [atomNumber(i), sizeX(i), sizeY(i), centreX(i), centreY(i)]=Fluorescence(atoms,laser,ROI,1,imagePath)
%             resultsArray = [cb3StopValue, atomNumber(i), sizeX(i), sizeY(i), centreX(i), centreY(i)];
%             writeAnalysisResultsToFileS('AnalysisResults.txt', timeStamp, resultsArray);
%             disp(['ioffe size: ' num2str(sizeX(i)) ' UpDown size: ' num2str(sizeY(i))]);
%             disp(['AtomNumber: ' num2str(atomNumber(k))])
%         end
    end
    if stoppedByUser
        disp('Experiment Stopped');
        flag=1;
        break
    end
end
