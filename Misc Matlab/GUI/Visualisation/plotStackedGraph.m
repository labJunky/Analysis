function plotStackedGraph(Y,x,zbound,palette,fAlpha,eAlpha)

if nargin<2 || isempty(x), x = 1:size(Y,1); end
if nargin<3, zbound = 1; end
if zbound, Y = [zeros(size(Y,1),1) Y]; end
if nargin<4, palette=jet(size(Y,2)); end
if nargin<5, fAlpha = 0.2; end
if nargin<6, eAlpha = 0; end;

for i=2:size(Y,2)
size([Y(:,i); flipud(Y(:,i-1))]')
size([x fliplr(x)])
%size(palette(i-1,:))
end
for i=2:size(Y,2)
    patch([x fliplr(x)],[Y(:,i); flipud(Y(:,i-1))]',palette(i-1,:),'FaceAlpha',fAlpha,'EdgeAlpha',eAlpha);
end