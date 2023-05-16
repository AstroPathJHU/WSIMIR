%% open_tiled_tiff_strip
%
%%
function tile = open_tiled_tiff_strip(...
    imname, row_id, tile_length, tile_width, tiles_wide, level)
    %
    t = Tiff(imname);
    setDirectory(t, level)
    row = (row_id - 1) * tiles_wide;
    im1 = zeros(tile_length * tile_width * tiles_wide, 3, 'uint8');
    %
    for i1 = 1:tiles_wide
        %
        tile = i1 + row;
        [Y, Cb, Cr] = readEncodedTile(t, tile);
        %
        lower = tile_length * tile_width * (i1 - 1) + 1;
        upper = tile_length * tile_width * i1;
        %
        im1(lower:upper, :) = [Y(:), Cb(:), Cr(:)];
        %
    end
    %
    tile = im1';
    close(t)
    %
end