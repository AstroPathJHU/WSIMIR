%% calculate_and_apply_affine_transform
% calculate a confidence on each control point registration based on the
% lowest resolution (hypothesis is that first guess typically determines if
% the registration will succeed). Then using the top 50% of registrations
% calculate an affine transformation and apply it.
%% Input
% moving_image: moving_image struct output from @get_rough_registration
% fixed_image: fixed_image struct output from @get_search_grids
% meta: the metadata object output updated with the
% initial_transformation.output from distribute tasks
%% Output
% moving_image: the moving_image struct with the initial_transformed_image
% will delete the rotated_image if specified by input opts (default)
% meta: the initial_transformation struct will be updated, will also
% contain 'T'
%%
function [moving_image, meta] = ...
    calculate_and_apply_affine_transform(moving_image, fixed_image, meta)
%
meta.affine_transformation.output = [meta.affine_transformation.output{:}];
[~,index] = sortrows([meta.affine_transformation.output.control_point_idx].');
meta.affine_transformation.output = meta.affine_transformation.output(index);
%
% calculate the confidence of the initial transformation
%
confidence = mi_confidence({meta.affine_transformation.output(:).MMI_maps}, 2);
confidence = num2cell(confidence);
[meta.affine_transformation.output(:).confidence] = confidence{:};
%
% get the new coordinates
%
new_coordinates = [meta.affine_transformation.output(...
    [meta.affine_transformation.output(:).resolution] == 1).new_coordinates];
new_coordinates = reshape(new_coordinates, 2, [])';
%
old_control_pts = fixed_image.meta.relative_ul_corners - 1;
new_control_pts = new_coordinates;
%
moving_image.final_grid_coordinates = new_coordinates;
%
if meta.opts.keep_moving_affine_transformed || ...
    meta.opts.write_registered_moving_image_wsi
    [moving_image.affine_transformed_image, moving_image.affine_tform] = ...
        calculate_and_apply_transform(old_control_pts, new_control_pts,...
        moving_image.initial_transformed_image);
end
%
if meta.opts.write_registered_moving_image_wsi
    ipath = fullfile(meta.opts.output_dir,...
        meta.opts.registered_moving_image_wsi);
    imwrite(moving_image.affine_transformed_image, ipath)
    if ~meta.opts.keep_moving_affine_transformed
        moving_image = rmfield(moving_image, 'affine_transformed_image');
    end
end
%
end