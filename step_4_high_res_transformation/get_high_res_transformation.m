%% get_high_res_transformation
%
%% Description
% Divide the image into the gridded parts and distribute
% them to parallel workers to perform a mutual information registration of
% each control point. Calculate a mutual information confidence (based on
% the standard deviation of the mutual information), use
% control points to create an image warp, then apply that warping mask.
%% Input
% moving_image: moving_image struct output from @get_intial_transformation
% fixed_image: fixed_image struct output from @get_intial_transformation
% meta: the metadata object output from @get_intial_transformation
%% Output
% moving_image: the moving_image struct, if specified in opts, with final 
% high_res_transformed_image. will delete the transformed_image if specified 
% by input opts (default)
% meta: metadata with added high_res_transformation struct 
%% --------------------------
function [fixed_image, moving_image, meta] = ...
    get_high_res_transformation(fixed_image, moving_image, meta)
%
meta = initialize_high_res_transformation_parameters(moving_image, meta);
%
[fixed_image, meta] = distribute_registration_tasks( ...
    fixed_image, moving_image, meta, 'high_res_transformation');
%
[moving_image, meta] = calculate_and_apply_high_res_transform( ...
    fixed_image, moving_image, meta);
%
end