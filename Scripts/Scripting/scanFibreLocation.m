%Scan conveyor Belt through 100 positions
%And repeat 5 times.
runsLeft = 500;

for x=1:1;
    %[dataDirectory, matlabDir, analysisSettingsDir] = getDirectory();
    %dataDirectory = 'C:\Users\Administrator\Desktop\Crete\Data\';
    dataDirectory = 'D:\AtomChip Data\';
    scriptDir = [dataDirectory 'Scripts' filesep 'ScriptRunFolder' filesep];
    scriptFile = [scriptDir '04Amp-Dimple-CB3-CB2-LR-RFSwitch-TrapBottom_Insitu.xml']; 

    %Load the script and labview activeX control.
    viServer = actxserver('LabVIEW.Application');
    scriptDoc = loadScript(scriptFile);

    %Name the parameter you want to change and its new value
    iWireStop = 'iWireStop';
    iWireStopStep = 'iWireStopStep';
    iWireStart = 'iWireStart';
    iWireStartStep = 'iWireStartStep';
    fibreShutter = 'fibreShutter';
    
    iWireStopValues = [0.8:-0.05:0.1];
    steps = 60;
    iStart = 0.9;
   

    %Points to scan
    cbPositionPoints = 100;
    cbStep = (cb3StartValue-cb3StopFinal)/cbPositionPoints;
    cbTimeStep = rampTimeOriginal/cbPositionPoints;

    i=0; %Loop counter
    for iStopValue=iWireStopValues; %Scan conveyor belt
        i = i+1
       
        iWireStepValue = ( iStart - iStopValue ) / steps;
        iWireStartValue = iStopValue;
        
        %Run with fibre light on (780nm)
        changeScriptParameter(scriptDoc, iWireStop , iStopValue);
        changeScriptParameter(scriptDoc, iWireStart , iWireStartValue);

        changeScriptParameter(scriptDoc, iWireStopStep , -iWireStepValue);
        changeScriptParameter(scriptDoc, iWireStartStep , iWireStepValue);
        changeScriptParameter(scriptDoc, fibreShutter, 'on');
        
        xmlwrite(scriptFile,scriptDoc);

        pause(2);
        [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );

        if stoppedByUser
            disp('Experiment Stopped');
            flag=1;
            break
        end
        
        %rerun with no fibre light
        changeScriptParameter(scriptDoc, fibreShutter, 'off');
        xmlwrite(scriptFile,scriptDoc);

        pause(2);
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

