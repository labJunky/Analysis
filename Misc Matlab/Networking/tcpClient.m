%con=pnet('tcpconnect','localhost',3333)
host = '192.168.104.171';
con=pnet('tcpconnect', host, 33336)

pause
data2 = pnet(con,'read',11);

pnet(con,'close');
