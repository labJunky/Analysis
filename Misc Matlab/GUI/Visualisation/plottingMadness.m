%Load a Script, and extract events from the xml
%Then load an image
%Plot everything you can image

%path = ['C:\Users\Administrator\Desktop\Crete\Data\Scripts\ScriptRunFolder\'...
%'Dipole Trap Script_v2 Molasses (double shutter).xml'];

close(gcf)
h=figure(1);

%Dipole Trap Script_v2 Molasses (double shutter)
%dipole_grey MOT_V1
%currentVersionMOT
iptsetpref('ImshowBorder','tight');
path = ['C:\Users\Administrator\Desktop\Crete\Data\Scripts\ScriptRunFolder\'...
'Dipole Trap Script_v2 Molasses (double shutter).xml'];

scriptDoc = loadScript( path );

import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

% Evaluate the XPath Expression, and then evalute the Matlab encoded string
% Find all parameter nodes and display there content.
eventNodes= xpath.compile('//event').evaluate(scriptDoc, XPathConstants.NODESET);
time = zeros(eventNodes.getLength(),1);
dt = zeros(eventNodes.getLength(),1);
channel = cell(eventNodes.getLength(),1);
value = zeros(eventNodes.getLength(),1);
stage = cell(eventNodes.getLength(),1);

%Display all the nodes with parameters
for i = 1:eventNodes.getLength()
    node = eventNodes.item(i-1); %nodeset.item('index') indexs from 0
    time(i) = (10^-6)*str2double(char(node.item(0).getTextContent()));
    %dt(i) = (10^-6)*str2double(char(node.item(1).getTextContent()));
    channel{i} = char(node.item(2).getTextContent());
    value(i) = str2double(char(xpath.compile('newValue').evaluate(node, XPathConstants.NODE).getTextContent()));
    stage{i} = char(xpath.compile('stage').evaluate(node, XPathConstants.NODE).getTextContent());
end

%nonlinear scaling of time
%first get the differences
power = 0.3;
timex(1) = 0;
for i = 1:(length(time)-1)
   dt(i) = time(i+1)-time(i);
   timex(i+1) = timex(i)+(dt(i))^power;
end

%Group by stage
 stages = stage;
 index={};
 j=1;
for i = 1:eventNodes.getLength();
     if isempty(find(vertcat(index{:})==i))
        index{j} = find(strcmp(stages,stage{i})==1);
        j=j+1;
     end
end
%index contains the indices for each stage group.
%So the length of index will tell you how many
%different stages there are in the script.

%Now I want to split the indexes into continuous
%blocks. So if say index{3} = [12,13,14,15,19,20,21]
%I want it to come out as index{3} = {[12,13,14,15],[19,20,21]}
k = 1;
block = [];
ind = {};
l=0;
for i = 1:length(index)
    for j = 1:(length(index{i})-1)
        if index{i}(j+1)==(index{i}(j)+1)
            if j == 1 %First iteration to initialise array
                block = [index{i}(j) index{i}(j+1)];
            else
                if l
                    block = [block index{i}(j)];
                    l=0;
                else
                    block = [block index{i}(j+1)];
                end
            end
            if j == length(index{i})-1 %last iteration to store that block
                blks{k} = block;
                block = [];
                k=k+1;
            end
        else
            l = 1;
            blks{k} = block;
            block = [];
            k = k+1;
        end
    end
    l=0;
    %block=[];
    ind{i} = blks;
    blks = {};
    k=1;
end
    
%Now I want to extract the start and stop times
%for each stage block.

startTime = [];
stopTime = [];
times = {};
j=1;
for i = 1:length(ind) %for each stage
    for k = 1:length(ind{i}) % for each block in that stage
       if isempty(ind{i}{k})
           %do nothing is the indexed element is empty
           empty=1;
       else
           empty=0;
           startTime(j) = timex( ind{i}{k}(1) );
           try 
            endTime(j) = timex( ind{i}{k}(end) + 1 );
           catch ME1
               if strcmp(ME1.identifier, 'MATLAB:badsubscript')
                   %Its the last element in the script
                   %so index = end+1 is out of range.
                   endTime(j) = timex( ind{i}{k}(end) );
               else %its not cause by the above. Rethrow the exception
                   rethrow(ME1)
               end
           end
           j=j+1;
       end
    end
    if empty
    else
        times{i} = {startTime, endTime};
    end
    startTime = [];
    endTime = [];
    j=1;
end

%Load an image

myDir = directory();
myDir = myDir.getDirectoryOnDate('bitwise', '120709');

timeStamp = '120709_1751_28 FR_2';

imageFile = dir([myDir.Processed timeStamp '*.tif']);
imageFile = [myDir.Processed imageFile.name];

image = double(imread(imageFile))./(2^12-1);
od = image(1:1000,1:1300);
h1 = subplot(2,1,1);

surf(flipud(od),...
   'FaceColor','texturemap',...
   'EdgeColor','none',...
   'CDataMapping','scaled')
axis([1 1400 1 1100 0 8]);
colormap(hsv)
view(-35,35)
hs1 = shadowplot(2);
hs2 = shadowplot(4);
% alpha(hs1,.85) ;
% alpha(hs2,.85) ;
hold on;
planeimg = flipud(od);
minplaneimg = min(min(planeimg)); % find the minimum
scaledimg = (floor(((planeimg - minplaneimg) ./ ...
    (max(max(planeimg)) - minplaneimg)) * 255)); % perform scaling
 
% convert the image to a true color image with the jet colormap.
colorimg = ind2rgb(scaledimg,jet(256));
surf([1 1300], [1 1000], repmat(8, [2,2]),colorimg, 'FaceColor','texturemap')

h = subplot(2,1,2);

units = '';
color=lines(length(ind));
k=1;
%makes figure with blocks lah
for i = 1:length(ind) %for each stage
    for k = 1:length(ind{i}) %for each block in stage
        %block
        %[startX, startY, lengthX, lengthY]   
        if isempty(ind{i}{k})
            %cell element is empty
        else
            if times{i}{2}(j)-times{i}{1}(j)~=0
                rectangle('Position',[times{i}{1}(j),length(ind)-i,times{i}{2}(j)-times{i}{1}(j),0.6],'Curvature',0.5,'LineWidth',1,'LineStyle','-',...
                'FaceColor',color(i,:));
                text((times{i}{2}(1)-times{i}{1}(1))/2+times{i}{1}(1),length(ind)-i+0.3,[stage{index{i}(1)}],'HorizontalAlignment','center');
                if i ~= length(ind)
                    timeDif = time(ind{i}{k}(end)+1)-time(ind{i}{k}(1));
                    switch 1 %search for the true case
                        case timeDif < 0.01 | timeDif<=0.09
                           timeDif = timeDif * 10^3;
                           units = 'ms';
                        case timeDif <= 0.0009
                           timeDif = timeDif * 10^6;
                           units = 'us';
                        case timeDif > 0.09
                            units = '';
                    end
                    text((times{i}{2}(j)-times{i}{1}(j))/2+times{i}{1}(j),length(ind)+0.5+mod(i,2)/3,[num2str(timeDif,3) units],'HorizontalAlignment','center');
                else
                    timeDif = time(ind{i}{k}(end))-time(ind{i}{k}(1));
                    switch 1 %search for the true case
                        case timeDif < 0.01 | timeDif<=0.09
                           timeDif = timeDif * 10^3;
                           units = 'ms';
                        case timeDif <= 0.0009
                           timeDif = timeDif * 10^6;
                           units = 'us';
                        case timeDif > 0.09
                            units = '';
                    end
                    text((times{i}{2}(j)-times{i}{1}(j))/2+times{i}{1}(j),length(ind)+0.5+mod(i,2)/3,[num2str(timeDif,3) units],'HorizontalAlignment','center');
                end
                line([times{i}{1}(j) times{i}{1}(j)],[-1 length(ind)+1],'LineStyle', ':');
                %j=j+1;
            end
            j=j+1;
        end
    end 
    if i == length(ind)
        if isempty(ind{i});
        else
            line([times{i}{2}(k) times{i}{2}(k)],[-1 length(ind)+1],'LineStyle', ':');
        end
    end
    j=1;   
end

if isempty(times{end}{2})
    axis([-0.01,times{end-1}{2}(end)+0.01,-1,length(ind)+1]);
else
    axis([-0.01,times{end}{2}(end)+0.01,-1,length(ind)+1]);
end
set(h,'ytick', [], 'xtick',[]);
set(h, 'box', 'off');
set(h, 'position', [0, 0, 1, 0.3]);
set(h1, 'position', [0.1, 0.35, 0.8, 0.6]);
set(gcf,'Position',[-1000 200 300*2.5 300*3*(1/1.618)]);
set(gcf, 'MenuBar', 'none');
pause(0.1)
jFigPeer = get(handle(gcf),'JavaFrame');
jWindow = jFigPeer.fFigureClient.getWindow;
com.sun.awt.AWTUtilities.setWindowOpacity(jWindow,0.90)

