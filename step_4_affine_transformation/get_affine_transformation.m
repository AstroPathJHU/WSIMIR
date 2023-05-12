%% get_affine_transformation
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
% affine_transformed_image. will delete the transformed_image if specified 
% by input opts (default)
% meta: metadata with added affine_transformation struct 
%% --------------------------
function [moving_image, fixed_image, meta] = ...
    get_affine_transformation(moving_image, fixed_image, meta)
%
meta = initialize_affine_transformation_parameters(meta, moving_image);
%
[fixed_image, meta] = distribute_registration_tasks(...
    moving_image, fixed_image, meta, 'affine_transformation');
%
[moving_image, meta] = ...
    calculate_and_apply_affine_transform(moving_image, fixed_image, meta);
%
end