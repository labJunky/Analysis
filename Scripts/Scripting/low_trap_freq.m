%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

scriptFile = 'D:\AtomChip Data\Scripts\ScriptRunFolder\Trap Measurement_v2.xml';

[d, scriptName] = fileparts(scriptFile);

freqParam = 'Modulation_Freq';
ampParam = 'Modulation_Amp';

frequency = [0.05:0.01:0.8]; %Frequency in KHz
amplitude = [0.15,0.125,0.12,0.11,0.105,0.1,0.09,0.085,0.08,0.078,0.075];
flag = 0; %To break out of the loop when the user has stopped the experiment.
atomNumberAverage=[];
plotFreq=[];
k=1;

for i=frequency
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value =i;
    switch 1 %search for the true case
        case 0.05<=value<=0.139
            ampValue = amplitude(1);
        case 0.140<=value<=0.179
            ampValue = amplitude(2);
        case 0.180<=value<=0.219
            ampValue = amplitude(3);
        case 0.220<=value<=0.239
            ampValue = amplitude(4);
        case 0.240<=value<=0.299
            ampValue = amplitude(5);
        case 0.3<=value<=0.369
            ampValue = amplitude(6);
        case 0.37<=value<=0.449
            ampValue = amplitude(7);
        case 0.450<=value<=0.599
            ampValue = amplitude(8);
        case 0.6<=value<=0.799
            ampValue = amplitude(9); 
        case 0.8<=value<=0.899
            ampValue = amplitude(10); 
        case 0.9<=value<=1
            ampValue = amplitude(11); 
        
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
        disp(j)
    end
    if flag
        break
    else
        pause(3);
        [t,d] = getLastNResults(10);
        atomNumber=d(:,1)';
        atomNumberAverage(k) = mean(atomNumber);
        plotFreq(k) = value;
        figure(1)
        plot(atomNumberAverage);
        k=k+1;
    end
end



