%need to load in some data from a table.
 a=textread('data.txt', '%f');
 j=1;
 for i=1:13
     Y(i,:)=a(j:j+16);
     j=j+17;
     x(i)=Y(i);
 end

% Offset (need positive data)
for i=1:size(Y,2)
    Y(:,i) = Y(:,i)+abs(min(Y(:,i)));
end

% Find the lower bound function

% ThemeRiver Soln
g0 = -sum(Y,2)/2;
% Min-Wiggle
g0 = -sum( repmat(size(Y,2)+1-[1:size(Y,2)],size(Y,1),1).*Y ,2) /(size(Y,2)+1);
% Min-Weighted-Wiggle
gprime = -sum((diff(Y)/2 + cumsum(diff(Y),2)).*Y(1:(end-1),:),2)./ sum(Y(1:(end-1),:),2);
g0 = cumsum([0; gprime]);


%% Plot
plotStackedGraph(cumsum(([g0 Y]),2),[],0,summer(17),0.9)

%% Plot Sorted
clf
[b,idx] = sort(max(Y));
cmap = hot(size(Y,2)+2);
cmap = cmap([idx 1],:);
%[b,idx] = sort(groups);
plotStackedGraph(cumsum(([g0 Y(:,idx)]),2),[1995:2007],0,spring(size(Y,2)),0.75,0)
%plotStackedGraph(cumsum(([g0 Y(:,idx)]),2),[],0,cmap,0.5,0)
set(gca,'YTick',[])
% set(gca,'XTick',[])
box on
axis tight
ylim(ylim()*1.2)
set(gca,'FontSize',12)