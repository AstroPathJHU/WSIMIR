%% prepare_mi_vars
%% Description
% create a structure to be passed to the mutual information estimation
%% Input 
% image_a: the stationary, reference image
% image_b: is the floating image 
% mi_vars: a data structure with the following values
%   - scale (logical): whether or not to scale the images
%   - subsampling: the amount of the image to subsample for the
%   registration
%% ---------------------------------------
function [mi_vars, image_a] = prepare_mi_vars(...
    image_a, image_b, mi_vars)
%
if ~isfield(mi_vars,'scale')
    mi_vars.scale = 1;
end
%
if ~isfield(mi_vars,'subsampling_fraction')
    mi_vars.subsampling_fraction = 1;
end
%
if ~isfield(mi_vars,'step_size')
    mi_vars.step_size = [1 1];
end
%
if mi_vars.scale
    image_a = zero_and_scale(image_a, 16);
    image_b = zero_and_scale(image_b, 16);
end
%
image_a = round(single(image_a));
image_b = round(single(image_b));
%
[mi_vars.height_a, mi_vars.width_a, mi_vars.levels_a] = size(image_a);
[mi_vars.height_b, mi_vars.width_b, mi_vars.levels_b] = size(image_b);
%
reshaped_image_b = reshape(image_b, [], mi_vars.levels_b) + 1;
mi_vars.ndim = mi_vars.levels_a + mi_vars.levels_b;
%
mi_vars.search_space = [(mi_vars.width_a - mi_vars.width_b + 1),...
    (mi_vars.height_a - mi_vars.height_b + 1)];
%
% Subsampling
%
if mi_vars.subsampling_fraction == 1
    mi_vars.np = mi_vars.height_b * mi_vars.width_b;
    mi_vars.p = 1:mi_vars.np;
end
%
if mi_vars.subsampling_fraction ~= 1
    mi_vars.np = round(...
        mi_vars.height_b * mi_vars.width_b * mi_vars.subsampling_fraction);
    mi_vars.p = 1:...
        round(1 / mi_vars.subsampling_fraction):...
        mi_vars.height_b * mi_vars.width_b;
end
%
mi_vars.sampled_image_b = reshaped_image_b(mi_vars.p,:);
%
mi_vars.ix = 0;
mi_vars.iy = 0;
%
end