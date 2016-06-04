% Draw some rectangles

%position in terms of [startX, startY, lengthX, lengthY)

figure(1)
rectangle('Position',[0,1,6,1],'Curvature',1,'LineWidth',1,'LineStyle','-',...
    'FaceColor',[0.1,0.5,0.7])
text(0+6/2,1+1/2,'block 1','HorizontalAlignment','center');
rectangle('Position',[5,0,5+3,1],'Curvature',1,'LineWidth',1,'LineStyle','-',...
    'FaceColor',[0.1,0.9,0.7])
text(5+8/2,0+1/2,'block 2','HorizontalAlignment','center');
daspect([1,1,1])

% rectangle('Position',[times{4}{1}(1),length(ind)-1,times{4}{2}(1)-times{4}{1}(1),1],'Curvature',1,'LineWidth',1,'LineStyle','-',...
%         'FaceColor',[0.1,0.5,0.7])
% rectangle('Position',[times{4}{1}(2),length(ind)-1,times{4}{2}(2)-times{4}{1}(2),1],'Curvature',1,'LineWidth',1,'LineStyle','-',...
%         'FaceColor',[0.1,0.5,0.7])

% for i = 4
%     for j = 1:length(times{i}{1})
%        rectangle('Position',[times{i}{1}(j),1,times{i}{2}(j)-times{i}{1}(j),1],'Curvature',1,'LineWidth',1,'LineStyle','-',...
%        'FaceColor',[0.1,0.5,0.7])
%         text((times{i}{2}(j)-times{4}{1}(j))/2+times{4}{1}(j),1+1/2,['block ' num2str(j)],'HorizontalAlignment','center');
%     end
% end
