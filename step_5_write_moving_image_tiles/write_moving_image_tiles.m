%% write_moving_image_tiles
% write the tiles from the moving image to an TILES directory in the same
% folder as the moving_image. Note that the final affine coordinates for
% HPFs\ tiles\ grids are relative to the initial_transformed_image and not 
% the final affine_transformed_image coordinates. 
%% Input 
% moving_image: the moving_image struct from @get_affine_transformation
% meta: the metadata object output from @get_intial_transformation
%% Output
% moving_image: may have the intitial transformed image removed if
% specified by the input opts. 
%%
function [fixed_image, moving_image, meta] = ...
    write_moving_image_tiles(fixed_image, moving_image, meta)
%
meta.opts.step = 5;
%
if ~isfolder(meta.opts.output_tile_path)
    mkdir(meta.opts.output_tile_path);
end
%
% get the output filenames
%
final_coordinates = meta.affine_transformation.output(...
    [meta.affine_transformation.output(:).resolution] == 1);
fnames = {final_coordinates(:).filenames};
[~, fnames] = cellfun(@(x) fileparts(x), fnames, 'Uni', 0);
meta.hpf_filenames = fnames;
full_filenames = fullfile(meta.opts.output_tile_path,...
    strcat(extractBefore(fnames,"]_"), "]_IHC.tif"));
n_tiles = length(fnames);
%
% final registered tile locations
%
moving_lower_bounds = moving_image.final_grid_coordinates(:, 2);
moving_upper_bounds = moving_lower_bounds + meta.input_reg_data.tile_height - 1;
moving_left_bounds = moving_image.final_grid_coordinates(:, 1);
moving_right_bounds = moving_left_bounds + meta.input_reg_data.tile_width - 1;
%
logger(strcat("Indexing ", string(n_tiles), " image tiles"), 'INFO', meta)
tic
%
image_data = moving_image.initial_transformed_image;
tile_regions = cell(n_tiles, 1); 
%
for i1 = 1:n_tiles
    tile_regions{i1} = image_data(...  
       moving_lower_bounds(i1):moving_upper_bounds(i1),...
       moving_left_bounds(i1):moving_right_bounds(i1), :); 
end
%
logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
%
if meta.opts.write_step_5
    %
    msg = strcat("Writing ",string(n_tiles), " image tiles to ", ...
        meta.opts.output_tile_path);
    logger(msg, 'INFO', meta)
    tic
    %
    for i1 = 1:n_tiles
        imwrite(tile_regions{i1}, full_filenames{i1});
    end
    %
    write_transform_output_table(fixed_image, moving_image, meta)
    %
    logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
    %
end
%
if meta.opts.keep_step_5 || meta.opts.show_step_5
    %
    logger("Creating restitched image", 'INFO', meta)
    tic
    %
    bb = moving_image.meta.rotated_boundingbox;
    %
    fixed_lower_bounds = moving_lower_bounds - bb(2) + 2;
    fixed_upper_bounds = moving_upper_bounds - bb(2) + 2;
    fixed_left_bounds = moving_left_bounds - bb(1) + 2;
    fixed_right_bounds = moving_right_bounds - bb(1) + 2;
    %
    moving_image.final_restitched_image = 255 * ones(...
        bb(4)-bb(2), bb(3)-bb(1), 3, 'uint8');
    %
    for i1 = 1:n_tiles
        moving_image.final_restitched_image(...
            fixed_lower_bounds(i1):fixed_upper_bounds(i1), ...
            fixed_left_bounds(i1):fixed_right_bounds(i1), :) = ...
            tile_regions{i1};
    end
    %
    logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
    %
end
%
show_images(fixed_image, moving_image, ...
    {'image', 'final_restitched_image'}, meta)
%
if ~meta.opts.keep_step_5
    moving_image = rmfield(moving_image, 'final_restitched_image');
end
%
if ~meta.opts.keep_step_3
    moving_image = rmfield(moving_image, 'initial_transformed_image');
end
%
end
