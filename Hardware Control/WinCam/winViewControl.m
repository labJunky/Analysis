%operate WinView program via activeX commands

loadlibrary('proEmWin32','proEmWin32');

a=calllib('proEmWin32', 'Init2Win32');

pause

for i=[1:10];
    counts = calllib('proEmWin32', 'Start2Win32', a)
    %pause(0.5)
end

unloadlibrary('proEmWin32')