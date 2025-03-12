%% get_search_grids
%% Description
% define the search grids on the fixed_image for the registration and 
% define the control points for the intial transformation, the current 
% solution uses the image tiles as the grid - more general solution is 
% needed 
%% Input
% moving_image: moving_image struct output from @get_rough_registration
% fixed_image: fixed_image struct output from @get_rough_registration
% meta: the metadata object output from @get_rough_registration
%% Output
% fixed_image: data struct with added 'relative_ul_corners' that releates
% the fixed image grids to the moving image
% meta: the updated metadata structure with added
% initial_transformation.input_reg_data and input_reg_data fields. The
% initial data will be used for data specific to that registration step. 
%% -------------------------
%
function [fixed_image, meta] = get_search_grids(...
    fixed_image, moving_image, meta)
%
% if the fixed image is a TILE image then use the coordinates
% for the grid but adjust to the rotated image upper left hand corner
%
logger('Building search grids', 'INFO', meta)
%
if strcmp(fixed_image.meta.type, 'TILE')
    %
    fixed_image.meta.relative_ul_corners = ...
        double(fixed_image.meta.upperleftcorners) ...
        + moving_image.meta.rotated_upperleftcorner - 1;
    %
    meta.initial_transformation.input_reg_data.search_boarder = [...
        fixed_image.meta.tile_width fixed_image.meta.tile_height];
    meta.initial_transformation.input_reg_data.initial_search_boarder = ...
        meta.initial_transformation.input_reg_data.search_boarder / 2;
    meta.input_reg_data.tile_width = ...
        fixed_image.meta.tile_width;
    meta.input_reg_data.tile_height = ...
        fixed_image.meta.tile_height;
    meta.input_reg_data.tile_ncomponents = ...
        fixed_image.meta.ncomponents;
    meta.input_reg_data.n_total_grids = length(fixed_image.meta.image_names); 
    %
elseif strcmp(moving_image.type, 'TILE') 
   %
   % need to use the image info a type grid
   %
   msg = 'NOT IMPLEMENTED - image b is not a TILE image but image a is';
   logger(msg, 'ERROR', meta)
   %
else
    %
    % need to create a grid
    %
    msg = 'NOT IMPLEMENTED - image a nor image b is a TILE image';
    logger(msg, 'ERROR', meta)
    %
end
%
% create a completely filled grid from image boundary grid coordinates. We
% will use this to ensure that control points are evenly distributed in the
% physical space below. We call this grid gc. 
%
gx = unique(fixed_image.meta.relative_ul_corners(:, 1));
gy = unique(fixed_image.meta.relative_ul_corners(:, 2));
gc = reshape([repmat(gx', length(gy), 1),...
    repmat(gy, 1, length(gx))], [], 2);
grid_boundary_indexes = boundary(fixed_image.meta.relative_ul_corners);
fixed_image_grid_boundary = fixed_image.meta.relative_ul_corners(...
    grid_boundary_indexes, :);
%
lower_limit_grids = min(100, length(fixed_image.meta.relative_ul_corners));
meta.initial_transformation.input_reg_data.control_point_idx = 0;
ngc = lower_limit_grids;
%
% create an evenly spaced vector within the grid space gc
% using the vector as indexes, select those grid coordinates which are 
% inside or on the image boundary. find the nearest unique coordinates for 
% each of the evenly spaced grid spaces selected. 
%
while length(...
        meta.initial_transformation.input_reg_data.control_point_idx) < ...
        lower_limit_grids    
    gic = round(linspace(1, length(gc), ngc));
    [in,on] = inpolygon(gc(gic, 1), gc(gic, 2), ...
       fixed_image_grid_boundary(:, 1),...
       fixed_image_grid_boundary(:, 2));
    meta.initial_transformation.input_reg_data.control_point_idx = unique(...
        knnsearch(fixed_image.meta.relative_ul_corners, gc(gic(in|on),:)));
    ngc = ngc + 1;
end
%
end