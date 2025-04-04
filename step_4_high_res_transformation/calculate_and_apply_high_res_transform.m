%% calculate_and_apply_high_res_transform
% calculate a confidence on each control point registration based on the
% lowest resolution (hypothesis is that first guess typically determines if
% the registration will succeed). Then using the top 50% of registrations
% calculate a high resolution affine transformation and apply it.
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
    calculate_and_apply_high_res_transform(fixed_image, moving_image, meta)
%
logger('Applying estimated high resolution transform', 'INFO', meta)
%
meta.high_res_transformation.output = [meta.high_res_transformation.output{:}];
[~,index] = sortrows([meta.high_res_transformation.output.control_point_idx].');
meta.high_res_transformation.output = meta.high_res_transformation.output(index);
%
% calculate the confidence of the transformation
%
confidence = mi_confidence({meta.high_res_transformation.output(:).MMI_maps}, 2);
confidence = num2cell(confidence);
[meta.high_res_transformation.output(:).confidence] = confidence{:};
%
% get the new coordinates
%
new_coordinates = [meta.high_res_transformation.output(...
    [meta.high_res_transformation.output(:).resolution] == 1).new_coordinates];
new_coordinates = reshape(new_coordinates, 2, [])';
%
old_control_pts = fixed_image.meta.relative_ul_corners - 1;
new_control_pts = new_coordinates;
%
moving_image.final_grid_coordinates = new_coordinates;
% we don't need this since we already have the coordinates for tiling
% unless one of the options below was specified.
if meta.opts.keep_step_4 || meta.opts.show_step_4 || meta.opts.write_step_4 || ...
        meta.opts.save_overlay_step_4
    [moving_image.high_res_transformed_image, moving_image.high_res_tform] = ...
        calculate_and_apply_transform(old_control_pts, new_control_pts,...
        moving_image.initial_transformed_image);
    write_image(moving_image.high_res_transformed_image, meta)
    %
    show_images(fixed_image, moving_image, ...
        {'image', 'high_res_transformed_image'}, meta)
    % 
    if ~meta.opts.keep_step_4
        moving_image = rmfield(moving_image, 'high_res_transformed_image');
    end
    %
end
%
if ~meta.opts.run_step_5 && ~meta.opts.keep_step_3
    moving_image = rmfield(moving_image, 'initial_transformed_image');
end
%
logger('Finished applying estimated high resolution transform', 'INFO', meta)
%
end