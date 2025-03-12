%% get_initial_transformation
%
%% Description
% Define a set of control points and group them into grids based on their
% locations. Next divide the image into the gridded parts and distribute
% them to parallel workers to perform a mutual information registration of
% each control point. Calculate a mutual information confidence (based on
% the standard deviation of the mutual information) and use the top 50% of
% control points to create an image warp then apply that warping mask.
%% Input
% moving_image: moving_image struct output from @get_rough_registration
% fixed_image: fixed_image struct output from @get_rough_registration
% meta: the metadata object output from @get_rough_registration
%% Output
% moving_image: the moving_image struct with the initial_transformed_image
% will delete the rotated_image if specified by input opts (default)
% meta: metadata with added initial_transformation struct 
%% --------------------------
function [fixed_image, moving_image, meta] = get_initial_transformation(...
    fixed_image, moving_image, meta)
%
meta.opts.step = 3;
%
[fixed_image, meta] = get_search_grids(fixed_image, moving_image, meta);
%
[fixed_image, meta] = distribute_registration_tasks(...
    fixed_image, moving_image, meta, 'initial_transformation');
%
[moving_image, meta] = ...
    calculate_and_apply_initial_transform(fixed_image, moving_image, meta);
%
end
