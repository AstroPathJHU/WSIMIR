%% write_moving_image_tiles
% write the tiles from the moving image to an TILES directory in the same
% folder as the moving_image. Note that the final high res coordinates for
% HPFs\ tiles\ grids are relative to the initial_transformed_image and not 
% the final high_res_transformed_image coordinates. 
%% Input 
% moving_image: the moving_image struct from @get_high_res_transformation
% meta: the metadata object output from @get_intial_transformation
%% Output
% moving_image: may have the intitial transformed image removed if
% specified by the input opts. 
%%
function [fixed_image, moving_image, meta] = ...
    write_moving_image_tiles(fixed_image, moving_image, meta)
%
if ~isfolder(meta.opts.output_tile_path)
    mkdir(meta.opts.output_tile_path);
end
%
% get the output filenames
%
final_coordinates = meta.high_res_transformation.output(...
    [meta.high_res_transformation.output(:).resolution] == 1);
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
    logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
    write_transform_output_table(moving_image, meta)
    %
end
%
if meta.opts.keep_step_5 || meta.opts.show_step_5 || meta.opts.save_overlay_step_5
    %
    logger("Creating restitched image", 'INFO', meta)
    tic
    %
    bb = moving_image.meta.rotated_boundingbox;
    %
    fixed_lower_bounds = fixed_image.meta.upperleftcorners(:, 2);
    fixed_upper_bounds = fixed_lower_bounds + meta.input_reg_data.tile_height - 1;
    fixed_left_bounds = fixed_image.meta.upperleftcorners(:, 1);
    fixed_right_bounds = fixed_left_bounds + meta.input_reg_data.tile_width - 1;
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
    show_images(fixed_image, moving_image, ...
        {'image', 'final_restitched_image'}, meta)
    %
    if ~meta.opts.keep_step_5
        moving_image = rmfield(moving_image, 'final_restitched_image');
    end
    %
end
%
if ~meta.opts.keep_step_3
    moving_image = rmfield(moving_image, 'initial_transformed_image');
end
%
end
