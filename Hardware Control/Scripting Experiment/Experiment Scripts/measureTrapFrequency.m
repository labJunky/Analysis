function [ frequency ] = measureTrapFrequency( scriptFile )
%MEASURETRAPFREQUENCY Measures the trapping frequency of a cloud of atoms, using the
%input script, by modulating the trap with an external source. In this case
%we use the Keithley k3390 to provide the modulation of a Dipole Trap
% Assumes that the BEC program is running in the main application instance
% of labview.
%   

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

[d, scriptName] = fileparts(scriptFile);

freqParam = 'Modulation_Freq';
ampParam = 'Modulation_Amp';

frequency = [0.05:5:0.8] %Frequency stored in kHz
amplitude = [0.04,0.06,0.08,0.1,0.15];
flag = 0; %To break out of the loop when the user has stopped the experiment.
atomNumberAverage=[];
k=1;
for i=frequency
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = i;
    switch 1 %search for the true case
        case 0.05<=value<=1
            ampValue = amplitude(5);
        case 140<=value<=170
            ampValue = amplitude(2);
        case 180<=value<=290
            ampValue = amplitude(3);
        case 300<=value<=310
            ampValue = amplitude(4);
        case 320<=value<=370
            ampValue = amplitude(5); 
    end
    disp(['parameter ' freqParam ' new value = ' num2str(value)]);
    %Change the parameter in the script xml
    changeScriptParameter(scriptDoc, freqParam, value);
    disp(['parameter ' ampParam ' new value = ' num2str(ampValue)]);
    %Change the parameter in the script xml
    changeScriptParameter(scriptDoc, ampParam, ampValue);
    %Save the modified script
    xmlwrite(scriptFile, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(3);
    for j=1:10
        %run the script
        [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
        %Display the timestamp.
        disp([timeStamp ' ' scriptName]);
        if stoppedByUser
            disp('Experiment Stopped');
            frequency=0;
            flag = 1;
            break
        end   
    end
    if flag
        break
    else
        pause(3);
        [t,d] = getLastNResults(10);
        atomNumber=d(:,1)';
        atomNumberAverage(k) = mean(atomNumber);
        figure(1)
        plot(atomNumberAverage);
        k=k+1;
    end
end

%wait for analysis to finish
pause(2);

% if stoppedByUser
% else
%     [timeStamps, data] = getLastNResults(length(times));
%     sizeX = data(:,3)';
%     sizeY = data(:,4)';
%     name = [char(timeStamps(1,1)) ' ' scriptName];
%     
%     [d,todaysDir,as,remoteDir] = getDirectory();
%     sep = filesep;
%     dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
%     savePath = [remoteDir dateString 'Images' sep 'MatlabProcessed' sep name '.fig'];
%     
%     [initialCloudSize, temperature, residual] = FitTemperature(times*10^3, sizeY, name, savePath);
% end
end

