%% zero_and_scale
%% Description
% perform a zeroing then scaling of the images
%%
%
function zs = zero_and_scale(img, sc)
%
[h, w, bands] = size(img);
data = reshape(img, [], bands);
%
mincol = min(data,[],1);
zs = data - mincol;
%
maxcol = max(zs,[],1);
scale = sc ./ cast((maxcol), 'single');
%
zs = cast(zs, 'single') .* scale;
zs = reshape(zs, h, w, []);
%
end