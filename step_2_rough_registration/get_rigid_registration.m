%% get_rigid_registration
%% Description
% loop through a range of rotation parameters to determine where the 
% mutal information is at the maximum for the section of the tissue.
%% Input
% image_a: the stationary, reference image
% image_b: is the floating image 
% mi_vars: a data structure with the following values
%   - step_size: is the step size as [stepx stepy]
%   - scale (logical): whether or not to scale the images
%   - subsampling: the amount of the image to subsample for the
%   registration
%% ------------------------
function [coords, rotation_delta, MMI_map] = ...
    get_rigid_registration(image_a, image_b, mi_vars)
%
MMI_all = {};
MMI_coords = {};
MMI_maps = {};
%
parfor i1 = 1:length(mi_vars.rotation_param)
    %
    rotated_image_a = imrotate(image_a, mi_vars.rotation_param(i1));
    [MMI_all{i1}, MMI_coords{i1}, MMI_maps{i1}] = get_NDJH_registration(...
        rotated_image_a, image_b, mi_vars);
    %
end
%
[~, ind] = max(cell2mat(MMI_all));
rotation_delta = mi_vars.rotation_param(ind);
coords = MMI_coords{ind};
MMI_map = MMI_maps{ind};
%
coords = adjust_MI('rigid',...
    MMI_map, coords, mi_vars.scaling_factor, mi_vars.search_region);
%
end
