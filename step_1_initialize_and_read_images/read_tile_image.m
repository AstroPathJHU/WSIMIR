%% read_tile_image
%% Description
% read a whole slide image tiles in the akoya format
%% Input
% image_info_a: a data structure from image info for patha from 
% get_image_info
% image_info_b: a data structure from image info for pathb from 
% get_image_info
% nbands: number of component layers to read in for the stiching with
% a default of 1
%% Output
% TILE type images will have the "image" field populated with an image
%% ----------------------------------
function [moving_image, fixed_image] =...
    read_tile_image(moving_image, fixed_image, meta)
%
if strcmp(moving_image.meta.type, 'TILE')
    %    
    moving_image = arrange_tiles(moving_image, meta);
    %
end
%
if strcmp(fixed_image.meta.type, 'TILE')
    %    
    fixed_image = arrange_tiles(fixed_image, meta);
    %
end
%
end