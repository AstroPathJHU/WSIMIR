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
function moving_image = write_moving_image_tiles(moving_image, meta)
%
tile_directory = fullfile(fileparts(meta.opts.output_dir), 'HPFs');
%
if ~isfolder(tile_directory)
    mkdir(tile_directory);
end
%
final_coordinates = meta.affine_transformation.output(...
    [meta.affine_transformation.output(:).resolution] == 1);
%
fnames = {final_coordinates(:).filenames};
[~, fnames] = cellfun(@(x) fileparts(x), fnames, 'Uni', 0);
%
tile_lower_bounds = moving_image.final_grid_coordinates(:, 2);
tile_upper_bounds = tile_lower_bounds + meta.input_reg_data.tile_height - 1;
tile_left_bounds = moving_image.final_grid_coordinates(:, 1);
tile_right_bounds = tile_left_bounds + meta.input_reg_data.tile_width - 1;
%
for i1 = 1:length(final_coordinates)
    %
   name_id = strsplit(fnames{i1}, ']_');
   full_filename = fullfile(tile_directory, [name_id{1}, ']_IHC.tif']);   
   %
   moving_tile_region = moving_image.initial_transformed_image(...
       tile_lower_bounds(i1):tile_upper_bounds(i1),...
       tile_left_bounds(i1):tile_right_bounds(i1), :);
   %
   imwrite(moving_tile_region, full_filename);
   % 
end
%
if ~meta.opts.keep_moving_initial_transformed
    moving_image = rmfield(moving_image, 'initial_transformed_image');
end
%
end