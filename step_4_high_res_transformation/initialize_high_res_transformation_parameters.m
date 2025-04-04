%% initialize_high_res_transformation.parameters
% set up high resolution transformation inputs
%% Input
% meta and moving_image outputs from the initial_transformation
%% Output
% meta with additional struct: high_res_transformation.input_reg_data
%%
function meta = initialize_high_res_transformation_parameters(...
    moving_image, meta)
%
logger('Building high resolution search grids', 'INFO', meta)
%
meta.high_res_transformation.input_reg_data.moving_image_size = ...
    size(moving_image.initial_transformed_image);
meta.high_res_transformation.input_reg_data.initial_search_boarder = ...
    min(100, 2 * ceil(max(abs(meta.T(:, 5:6) - ...
        mean(meta.T(:, 5:6)))) + 10));
meta.high_res_transformation.input_reg_data.search_boarder = ...
    2 * meta.high_res_transformation.input_reg_data.initial_search_boarder;
meta.high_res_transformation.input_reg_data.control_point_idx = ...
    1:meta.input_reg_data.n_total_grids;
%
end