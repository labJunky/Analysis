function [ temperature ] = measureDipoleLifeTime( scriptFile )
%MEASUREDIPOLELIFETIME Measures the lifetime of a cloud of atoms,held in a
%dipole trap or lattice.
% Assumes that the BEC program is running in the main application instance
% of labview.
%   

%Open a handle to the labview vi server.
viServer = actxserver('LabVIEW.Application');

[d, scriptName] = fileparts(scriptFile);

%Set the path to the script to run
parameterName = 'Dipole_Hold_Time';
 times = [50:50:1000]*10^-3;
for i=times
    %Load the script 
    scriptDoc = loadScript(scriptFile);
    value = i;
    disp(['parameter ' parameterName ' new value = ' num2str(value)]);
    %Change the parameter in the script xml
    changeScriptParameter(scriptDoc, parameterName, value);
    %Save the modified script
    xmlwrite(scriptFile, scriptDoc);
    %wait a couple of seconds for script to compile.
    pause(3);
    %run the script
    [timeStamp, stoppedByUser] = runScript( viServer, scriptFile );
    %Display the timestamp.
    disp([timeStamp ' ' scriptName]);
    if stoppedByUser
        disp('Experiment Stopped');
        temperature=0;
        break
    end
end

%wait for analysis to finish
pause(2);

if stoppedByUser
else
    [timeStamps, data] = getLastNResults(length(times));
    atomNumber = data(:,1)';
    name = [char(timeStamps(1,1)) ' ' scriptName];
    
    [d,todaysDir,as,remoteDir] = getDirectory();
    sep = filesep;
    dateString = [datestr(now,'yyyy'),sep,datestr(now,'yymm'),sep,datestr(now,'yymmdd'), sep];
    savePath = [remoteDir dateString 'Images' sep 'MatlabProcessed' sep name '.fig'];
    
    %Fit the data
    initialCoeff = [max(atomNumber),1/0.6]; %initial guess for lifetime is 0.6 seconds

    [x1, resnorm, residual] = lsqcurvefit(@fit_lifeTime,initialCoeff,times,atomNumber);

    curve = x1(1)*exp(-x1(2)*times);
    scriptName = name;
    %Plot the data over the fitted curve
    handle = figure;
    set(handle,'Name',['Lifetime Measurement : ' scriptName],'NumberTitle','off')
    plot(times,atomNumber,'o',times,curve)
    xlabel('Hold Time s');
    ylabel('Number of Atoms');
    plotLabel = ['Lifetime = ' num2str(1/x1(2)) ' s'];
    nameLabel= ['Script Name = ' scriptName];
    %text(1,max(sizeX+0.02),nameLabel);
    text(median(times),max(atomNumber)*0.9,plotLabel);
    title('Lifetime Measurement');
    saveas(handle,savePath);
end


end