%% read_big_tiff
% read a big tiff in chuncks using a parallel pool
%% Usage
% imname = '\\bki04\Clinical_Specimen_3\MA77\IHC\MA77.tif';
%%
function rgb = read_big_tiff(imname, level)
%
t = Tiff(imname);
setDirectory(t, level)
tile_width = getTag(t, 'TileWidth');
tiles_wide = getTag(t, 'ImageWidth') / tile_width;
tile_length = getTag(t, 'TileLength');
tiles_long = getTag(t, 'ImageLength') / tile_length;
close(t)
im2 = cell(tiles_long, 1);
%
parfor i2 = 1:tiles_long
    %
    im2{i2} = open_tiled_tiff_strip(...
        imname, i2, tile_length, tile_width, tiles_wide, level);
    %
end
%
im2 = [im2{:}];
im2 = reshape(im2, 3, tile_length, tile_width, tiles_wide, tiles_long);
im2 = permute(im2, [2, 5, 3, 4, 1]);
im3 = reshape(im2, [], 3);
rgb = fast_ycbcr2rgb(im3);
rgb = reshape(rgb, tile_length * tiles_long, tile_width * tiles_wide, 3);
%
end