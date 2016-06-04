host = '192.168.104.186';
port = 3333;
con=pnet_remote('connect', host, port);
pause
status = [];
stop=0;

if con>=0 
    pnet_remote(con, 'PUT', 'data', sin(0:0.1:20));
    pnet_remote(con, 'eval', 'newData = data;');
    pause(0.5)
    newData = pnet_remote(con,'GET', 'newData');
    plot(newData);
    pause(0.5);
    pnet_remote(con, 'eval', 'test_Temperature;');
    while stop~=1
        status = pnet_remote(con,'status');
        stop = strcmp(status,'ready'); 
        pause(0.2);
    end
    times = pnet_remote(con,'GET', 'times');
    sizeX = pnet_remote(con,'GET', 'sizeX');
    plot(sizeX,times);
end


%remember to close connection afterwards!