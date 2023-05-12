%% find_nearest_images
% starting with the next available control point find the n,
% 'number_of_worker_images', closest using iterative knn clustering. 
%% Output
% unassigned_images_ii: a logical vector of the unassigned images the size
% of the control_point_idx
% image_group: a struct with control_point_idx and bb (bounding_box) fields
%%
function [unassigned_images_ii, image_group] = find_nearest_images(...
    fixed_image, unassigned_images_ii, number_of_worker_images,...
    input_reg_data)
%
current_unassigned_images = find(unassigned_images_ii == 1);

%
% all control point coordinates not yet assigned to an image group
%
unassigned_control_coords = fixed_image.meta.relative_ul_corners(...
    input_reg_data.control_point_idx(unassigned_images_ii), :);
%
% current control point coordinates
%
current_control_coord = fixed_image.meta.relative_ul_corners(...
    input_reg_data.control_point_idx(current_unassigned_images(1)), :);
%
% find the n nearest control points, where n is an input defined in the
% outer function
%
n_nearest_control_points = knnsearch(unassigned_control_coords,...
    current_control_coord, 'K', number_of_worker_images);
%
% the image group control point indexes
%
image_group.control_point_idx = input_reg_data.control_point_idx(...
    current_unassigned_images(n_nearest_control_points));
%
% removing assigned images
%
unassigned_images_ii(...
    current_unassigned_images(n_nearest_control_points)) = 0;
%
% bounding box for the image group
%
image_group.bb = ...
    [min(fixed_image.meta.relative_ul_corners(...
    image_group.control_point_idx, :), [], 1)...
    max(fixed_image.meta.relative_ul_corners(...
    image_group.control_point_idx, :), [], 1)];
%
if strcmp(input_reg_data.opt, 'affine_transformation')
    image_group.bb = image_group.bb + 1;
end
%
end