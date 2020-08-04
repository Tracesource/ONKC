function [inXCell, y] = extractVarible(dataset)
% For single view data : 'X', 'y'
% For multiple view data : 'views', 'X1', ..., 'Xm', 'y'
load(dataset);
if ~exist('y', 'var')
    error('The variable y not found in data');
end
if exist('views', 'var')
    nView = length(views);
    inXCell = cell(nView, 1);
    for i = 1:nView
        eval(sprintf('%s = %s/max(%s(:));', ['X', num2str(i)], ['X', num2str(i)], ['X', num2str(i)]));
        eval(sprintf('inXCell{i} = %s;', ['X', num2str(i)]));
    end
else
    inXCell{1} = X;
end
end