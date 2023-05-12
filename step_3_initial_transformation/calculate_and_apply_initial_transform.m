%% calculate_and_apply_initial_transform
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
    calculate_and_apply_initial_transform(moving_image, fixed_image, meta)
%
meta.initial_transformation.output = [meta.initial_transformation.output{:}];
[~,index] = sortrows([meta.initial_transformation.output.control_point_idx].');
meta.initial_transformation.output = meta.initial_transformation.output(index);
%
% calculate the confidence of the initial transformation
%
confidence = mi_confidence({meta.initial_transformation.output(:).MMI_maps}, 2);
confidence = num2cell(confidence);
[meta.initial_transformation.output(:).confidence] = confidence{:};
initial_registration_confidences = [meta.initial_transformation.output( ...
    [meta.initial_transformation.output(:).resolution] == .1).confidence];
%
% detect confidence 50% of control points are above
%
confidence_cut_off = 0.99;
registrations_above_cut_off = sum(...
    initial_registration_confidences > confidence_cut_off);
percent_above_cut_off = ...
    registrations_above_cut_off / length(initial_registration_confidences);
%
while percent_above_cut_off < 0.5
    confidence_cut_off = confidence_cut_off - 0.01;
    registrations_above_cut_off = sum(...
        initial_registration_confidences > confidence_cut_off);
    percent_above_cut_off = ...
        registrations_above_cut_off / length(initial_registration_confidences);
end
%
% get the new coordinates
%
new_coordinates = [meta.initial_transformation.output(...
    [meta.initial_transformation.output(:).resolution] == 1).new_coordinates];
new_coordinates = reshape(new_coordinates, 2, [])';
%
T = calcIndTr(...
    new_coordinates, fixed_image.meta.relative_ul_corners,...
    confidence_cut_off, initial_registration_confidences',...
    meta.initial_transformation.input_reg_data.control_point_idx,...
    registrations_above_cut_off); 
meta.T = T;
%
% Calculate transformation for registrations with confidence >
% confidence_cut_off defined above
%
high_confidence_control_pts = ...
    initial_registration_confidences > confidence_cut_off;
high_confidence_control_pts_idx = ...
    meta.initial_transformation.input_reg_data.control_point_idx(...
    high_confidence_control_pts);

old_high_confidence_control_pts = fixed_image.meta.relative_ul_corners(...
    high_confidence_control_pts_idx, 1:2);
new_high_confidence_control_pts = new_coordinates(...
    high_confidence_control_pts_idx, 1:2);
%
[moving_image.initial_transformed_image, moving_image.intial_tform] = ...
    calculate_and_apply_transform(old_high_confidence_control_pts, ...
    new_high_confidence_control_pts, moving_image.rotated_image);
%
if ~meta.opts.keep_moving_rotated
    moving_image = rmfield(moving_image, 'rotated_image');
end
%
if meta.opts.write_step3_initial_transformed_moving_image_wsi
    ipath = fullfile(meta.opts.output_dir, meta.opts.step3_out_filename);
    imwrite(moving_image.initial_transformed_image, ipath)
end
%
end