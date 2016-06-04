%Open a handle to the labview vi server.
% viServer = actxserver('LabVIEW.Application');
% 
% runBECBasic = startBECProgram( viServer );
% pause(); %Unpause when the control program is ready

%Set the path to the script to run

motScript = ['\\Zeus\C$\Documents and Settings\Administrator\Desktop'...
                '\Crete\Data\Scripts\ScriptRunFolder\Test scrip_dipole_grey MOT_V1_Dp.xml']


%measure temperature of the mot produced by this script
measureDipoleLifeTime( motScript );

%Alternatively you can call the function the way labview does using feval
%script = 'measureTemperature';
%temperature = feval(script, motScript);