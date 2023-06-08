%% get_NDJH_registration
% Joshua Doyle, 07/2018
% Edited: Benjamin Green 12/2022
%% Description
% calculate the optimal mututal information registration between two 
% images. 
% size(im) - size(im2) should be positive and determines the search space.
%% Input
% image_a: the stationary, reference image
% image_b: is the floating image 
% mi_vars: a data structure with the following values
%   - step_size: is the step size as [stepx stepy]
%   - scale (logical): whether or not to scale the images
%   - subsampling: the amount of the image to subsample for the
%   registration
%
%% Output
% an array of the maximum mutual information and position (x, y)
%% ---------------------------------------
function [MMI_all, MMI_coords, MMI2] = get_NDJH_registration(...
    image_a, image_b, mi_vars)
%
[mi_vars, image_a] = prepare_mi_vars(image_a, image_b, mi_vars);
%
% sort the mutual information locations
%
if any(mi_vars.search_space <= 0)
    MMI2 = cast(0, 'single');
    MMIx = MMI2;
    MMIy = MMI2;
    mi_vars.global_search_grids = [];
else
    search_space_x = 1:mi_vars.step_size(1):mi_vars.search_space(1);
    search_space_y = 1:mi_vars.step_size(2):mi_vars.search_space(2);
    [MMIx, MMIy] = meshgrid(search_space_x, search_space_y);
    X2 = reshape(MMIx, [], 1);
    Y2 = reshape(MMIy, [], 1);
    mi_vars.global_search_grids = [X2, Y2];
    MMI2 = zeros(size(Y2), 'single');
    mi_vars.global_search_grids(:,3) = ...
        (mi_vars.global_search_grids(:,1) + mi_vars.width_b - 1);
    mi_vars.global_search_grids(:,4) = ...
        (mi_vars.global_search_grids(:,2) + mi_vars.height_b - 1);
end
%
if isfield(mi_vars,'parallel')
    %
    MMI2 = num2cell(MMI2);
    s = size(mi_vars.global_search_grids);
    %
    parfor correction = 1:s(1)
        %
        sliced_image_a = image_a(...
            mi_vars.global_search_grids(correction, 2):...
            mi_vars.global_search_grids(correction, 4), ...
            mi_vars.global_search_grids(correction, 1):...
            mi_vars.global_search_grids(correction, 3), ...
            :);
        %
        reshaped_image_a = reshape(sliced_image_a, [], mi_vars.levels_a) + 1;
        reshaped_image_a = reshaped_image_a(mi_vars.p, :);
        %
        MMI2{correction} = estimate_mi(reshaped_image_a, mi_vars);
        %
    end
    %
    MMI2 = cell2mat(MMI2);
    %
else
    %
    s = size(mi_vars.global_search_grids);
    %
    for correction = 1:s(1)
       %
        sliced_image_a = image_a(...
            mi_vars.global_search_grids(correction, 2):...
            mi_vars.global_search_grids(correction, 4), ...
            mi_vars.global_search_grids(correction, 1):...
            mi_vars.global_search_grids(correction, 3), ...
            :);
        %
        reshaped_image_a = reshape(sliced_image_a, [], mi_vars.levels_a) + 1;
        reshaped_image_a = reshaped_image_a(mi_vars.p, :);
        %
        MMI2(correction) = estimate_mi(reshaped_image_a, mi_vars);
        %
    end
    %
end
%
MMI2 = reshape(MMI2, size(MMIy));
%
[MMI_all, ind] = max(MMI2, [], 'all', 'linear');
MMIx_all = MMIx(ind);
MMIy_all = MMIy(ind);
% 
MMI_coords = [MMIx_all, MMIy_all];
%
end
