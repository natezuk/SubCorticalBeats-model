function [kw,mdleg] = plotmedians(v,x,cmap)
% Plot each row of v as a function of the dependent variable x. Each point
% in the row is plotted as a separate point, and a line is drawn through 
% the median of the values. If v is a cell array of matrices, each matrix
% is plotted in a different color. The stats from a kruskal-wallis test and
% multiple comparisons, performed separately for each matrix, is then
% returned.
% Inputs:
%   - v = cell array of matrixes or a single matrix.  Each row is for a
%   dependent variable, each column is an observation
%   - x (optional) = dependent variables (if not specified, 1:size(v,1) is used)
%   - cmap (optional) = a colormap
% Outputs:
%   - kw = statistics from kruskal-wallis test
%   - mcmp = results from multiple comparisons
% Nate Zuk (2018)

if ~iscell(v), 
    if size(v,3)>1,
        error('v must be a cell array of 2-D matrixes');
    else
        v{1} = v; 
    end
end % make v a cell array if it isn't already

if nargin<2,
    x = 1:size(v{1},1);
end

if nargin<3,
    cmap = colormap('jet');
end

%% Plotting
jitrange = 0.1; % +/- of randomness in dot placement for each x value
brrange = 0.1; % 1/2 width of the bar for the median value, in x indexes
xdiv = linspace(-0.4,0.4,length(v)+1); % positions of divisions between colors
xpos = diff(xdiv)/2+xdiv(1:end-1); % positions of each color relative to each x value
figure
hold on
for jj = 1:length(v),
    cind = round((jj-1)/length(v)*(size(cmap,1)-1))+1; % index in color map
    jits = (rand(size(v{jj},2),1)-0.5)*jitrange;
    for ii = 1:size(v{jj},1),
        plot(ones(size(v{jj},2),1)*(ii+xpos(jj))+jits,v{jj}(ii,:),...
            '.','Color',cmap(cind,:),'MarkerSize',14);
        md = median(v{jj}(ii,:),'omitnan');
        mdleg(jj) = plot([-brrange brrange]+(ii+xpos(jj)),[md md],'-','LineWidth',2,...
            'Color',cmap(cind,:));
    end
end
set(gca,'FontSize',16,'XTick',1:size(v{1},1),'XTickLabel',x);

%% Statistics
kw = cell(length(v),1);
for jj = 1:length(v),
    [kw{jj}.pval,kw{jj}.tbl,kw{jj}.stats] = kruskalwallis(v{jj}',[],'off');
    kw{jj}.mcmp = multcompare(kw{jj}.stats,'display','off');
end