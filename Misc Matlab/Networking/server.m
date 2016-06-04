port = 3333;
sockcon = pnet('tcpsocket',port)
con=-1;

while con==-1
    con = pnet(sockcon, 'tcplisten');
end


%pnet_remote(con,'serverat');
pause(1);
hosting = pnet(con,'gethost')
image = imread('120709_1751_28 FR_2.tif');
%pnet(con,'printf','HelloWorld\n');
for i=1:10,
    pnet(con,'write',image);
    pause(0.1)
end


pause(0.1)
pnet('closeall');