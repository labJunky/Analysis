%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

scriptFile = 'D:\AtomChip Data\Scripts\ScriptRunFolder\Trap Measurement_v2.xml';

[d, scriptName] = fileparts(scriptFile);

freqParam = 'Modulation_Freq';
ampParam = 'Modulation_Amp';

% frequency = [10, 25, 35, 40, 55, 60, 70, 75, 80, 100, 110, 120, 130, 140,... 
% 150,160, 170, 180, 190, 200,210, 220,230,240, 250,260,270,280,290, 300,310,320,...
% 330,340,350,360,370,380,390, 400,425, 450,475, 500,525, 550,575, 600]; %Frequency in kHz
% amplitude = [0.055, 0.06, 0.065, 0.07, 0.072, 0.08, 0.082, 0.087, 0.095, 0.105,...
% 0.11, 0.115, 0.12, 0.13, 0.14, 0.145, 0.15, 0.155, 0.16, 0.17,0.17, 0.18,...
% 0.18,0.18,0.2,0.2,0.2,0.2,0.2, 0.22,0.22,0.22,0.22,0.22, 0.23,0.23,0.23,0.235,0.235,...
% 0.24,0.25 0.26,0.27, 0.28, 0.285,0.29,0.295, 0.3];
frequency = [100, 110, 120, 130, 140,... 
150,160,165, 170, 175,180,185, 190,195,200,205,210, 220,230,240, 250,260,270,280,290, 300,310,320,...
330,335,340,345,350,355,360,370,380,390, 400,425, 450]; %Frequency in kHz
amplitude = [ 0.105,...
0.11, 0.115, 0.12, 0.13, 0.14, 0.145,0.145, 0.15,0.15, 0.155, 0.155, 0.16,0.165, 0.17,0.17,0.175, 0.18,...
0.18,0.18,0.2,0.2,0.2,0.2,0.2, 0.22,0.22,0.22,0.22,0.225,0.225,0.23, 0.23,0.23,0.23,0.23,0.235,0.235,...
0.24,0.25 0.26];
flag = 0; %To break out of the loop when the user has stopped the experiment.
atomNumberAverage=[];
plotFreq=[];
k=1;

for i=1:length(frequency)
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = frequency(i);
%     switch 1 %search for the true case
%         case 00.05<=value<=1
%             ampValue = amplitude(1);
%         case 140<=value<=170
%             ampValue = amplitude(2);
%         case 250<=value<=295
%             ampValue = amplitude(1);
%         case 300<=value<=335
%             ampValue = amplitude(2);
%         case 340<=value<=400
%             ampValue = amplitude(3); 
%     end
    ampValue=amplitude(i);
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



