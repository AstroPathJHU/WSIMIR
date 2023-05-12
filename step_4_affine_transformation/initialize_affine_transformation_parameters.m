%% initialize_affine_transformation.parameters
% set up affine transformation inputs
%% Input
% meta and moving_image outputs from the initial_transformation
%% Output
% meta with additional struct: affine_transformation.input_reg_data
%%
function meta = initialize_affine_transformation_parameters(...
    meta, moving_image)
%
meta.affine_transformation.input_reg_data.moving_image_size = ...
    size(moving_image.initial_transformed_image);
meta.affine_transformation.input_reg_data.initial_search_boarder = ...
    min(100, 2 * ceil(max(abs(meta.T(:, 5:6) - ...
        mean(meta.T(:, 5:6)))) + 10));
meta.affine_transformation.input_reg_data.search_boarder = ...
    2 * meta.affine_transformation.input_reg_data.initial_search_boarder;
meta.affine_transformation.input_reg_data.control_point_idx = ...
    1:meta.input_reg_data.n_total_grids;
%
end