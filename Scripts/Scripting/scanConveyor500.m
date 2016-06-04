%Scan conveyor Belt through 100 positions
%And repeat 5 times.
runsLeft = 500;

for x=1:5;
    %[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
    %dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
    dataDirectory = 'D:\AtomChip Data\';
    scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
    scriptFile = [scriptDir '04Amp-Dimple-CB3-CB2-LR-RFSwitch-TrapBottom_Insitu.xml']; 

    %Load the script and labview activeX control.
    viServer = actxserver('LabVIEW.Application');
    scriptDoc = loadScript(scriptFile);

    %Name the parameter you want to change and its new value

    cb3RampTimeP = 'cb3RampTime';
    cb3RampStopP = 'cb3RampStop';
    cb2RampTimeP = 'cb2RampTime';
    cb2RampStopP = 'cb2RampStop';
    magneticHoldTimeP = 'CB3CB2_Hold_Time';
    rfFrequencyP = 'rf_Frequency';
    rfSwitchP = 'rfSwitch';

    rampTimeOriginal = 250000; %microSeconds
    delayOriginal = 325000-rampTimeOriginal; %microSeconds

    cb3StartValue = 1.35;
    cb3StopFinal = 0; 
    cb2StartValue = 0;
    cb2StopFinal = 1.35;
    cb3Value = cb3StartValue;
    cb2Value = cb2StartValue;
    cb3RampTimeValue = 0;

    %Points to scan
    cbPositionPoints = 100;
    cbStep = (cb3StartValue-cb3StopFinal)/cbPositionPoints;
    cbTimeStep = rampTimeOriginal/cbPositionPoints;

    i=0; %Loop counter
    for y=1:cbPositionPoints; %Scan conveyor belt
        i = i+1;
        runsLeft = runsLeft - 1;

        cb3RampTimeValue = cb3RampTimeValue+cbTimeStep
        cb3Value = cb3Value - cbStep
        cb2RampTimeValue = cb3RampTimeValue;
        cb2Value = cb2Value + cbStep
        delayTime = cb3RampTimeValue+delayOriginal

        changeScriptParameter(scriptDoc, cb3RampTimeP , cb3RampTimeValue);
        changeScriptParameter(scriptDoc, cb3RampStopP , cb3Value);

        changeScriptParameter(scriptDoc, cb2RampTimeP , cb2RampTimeValue);
        changeScriptParameter(scriptDoc, cb2RampStopP , cb2Value);

        changeScriptParameter(scriptDoc, magneticHoldTimeP , delayTime/1000000);
        %Switch on or off the rf Ramp, and set rfFrequency.
        changeScriptParameter(scriptDoc, rfSwitchP , 0); %Switch rf off

        xmlwrite(scriptFile,scriptDoc);

        pause(2);
        minutesLeft = (runsLeft)/3 %approximates 3 runs per minute!
        [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );

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
    %             ROI=[24,1002,502,1014];
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

