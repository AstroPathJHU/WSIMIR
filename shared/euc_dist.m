%% euc_dist
% find the eucledian distance between two points or vectors
%%
function dist = euc_dist(y1, y2, x1, x2)
dist = ((y1 - y2) .^2 + (x1 - x2) .^2 ) .^ 0.5;
end