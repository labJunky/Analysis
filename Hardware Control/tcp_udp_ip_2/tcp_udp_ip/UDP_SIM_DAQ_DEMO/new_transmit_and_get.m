function [data_matrix,id_list,data ] = new_transmit_and_get(REMOTEIP,REMOTEPORT,RECVPORT)
%NEW_TRANSMIT_AND_GET transmits a call and gets the data from all channels
%output is an matrix with the data for all the channels
%
% UDP demo using pnet, by Peter Rydesäter, Bollnäs, Sweden
%

pnet('closeall'); %  Prepare by closing existing pnet connections if not properly closed last time

DATASIZE =   12500;
BYTEORDER = 'network';
%BYTEORDER = 'intel';
TIMEOUT = 2;                          % Seconds timeout for receive loop
%data_matrix=uint16(zeros(DATASIZE,16)); % For efficiency, prepare empty matrix
id_list    =uint16(zeros(58));          % And prepare this, "small one" to to be consequent

imageLen = [1024 24];
data_matrix = uint16(zeros(imageLen(1),imageLen(2),58)); %for images of size 1024 by 1392.

%Setup UDP socket for reciving packets to port RECVPORT
udpsock=pnet('udpsocket',RECVPORT);
pnet(udpsock,'setwritetimeout',1);
pnet(udpsock,'setreadtimeout',0);

%Send request. Use reciving sockets as "platform" to create
% and send packet from also... recycling/saving....;-)
disp 'Send request...'
pnet(udpsock,'printf','XMITCALLANDGET,ALL,END');
pnet(udpsock,'writepacket',REMOTEIP,REMOTEPORT);

%Receiving packets. Do some output and receive the 16 channels
disp 'Receive...'
packnr=0;
start_time=clock();
while packnr<58,
    len=pnet(udpsock,'readpacket');
    if len == imageLen(1)*imageLen(2)*2+2, %2050??? % Valid sized packet received? => take care
        packnr=packnr+1;
        id_list(packnr)       =pnet(udpsock,'read',1,'uint16',BYTEORDER);
        %data_matrix(:,packnr) =pnet(udpsock,'read',DATASIZE,'uint16',BYTEORDER);
        data_matrix(:,:,packnr) =pnet(udpsock,'read',imageLen,'uint16',BYTEORDER);
        %data = pnet(udpsock,'read',imageLen,'uint16',BYTEORDER);
        %fprintf('PACK %02d len=%06d id=%d\n',packnr,len,id_list(packnr));
    elseif len>0,
        fprintf('PACK BAD size:%d \n',len);
    end
    if etime(clock(),start_time) > TIMEOUT,
        fprintf('TIMEOUT....:-(\n');
        break;
    end
end;
pnet(udpsock,'close');
if packnr==58,
    fprintf('All packs received :-)\n');
end

return;

