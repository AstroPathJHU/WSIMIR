%% get_images
%% Description
% part of the registration protocol for slides from different microscopes
% reads in the images to memory and gets image parameters
% -- Possible Improvement in readYCBCr2RGB for parloop reading in subset of
% main IHC image to improve read time -- use imread 'Region Property'
%% Input
% patha
% pathb
%% Output
% image_info_a: a data structure from image info for patha from 
% get_image_info
% image_info_b: a data structure from image info for pathb from 
% get_image_info
% nbands: number of component layers to read in for the stiching with
% a default of 1
%% ----------------------------------
function [moving_image, fixed_image] = get_images(moving_image, fixed_image, meta)
%
moving_image.meta = get_image_info(moving_image.meta.path);
fixed_image.meta = get_image_info(fixed_image.meta.path);
%
[moving_image, fixed_image] = read_wsi_image(moving_image, fixed_image);
[moving_image, fixed_image] = read_tile_image(...
    moving_image, fixed_image, meta);
%
% resize moving image to the fixed image scaling scaling. 
% just replaces the image object in moving_image.image
%
moving_image.image = imresize(moving_image.image,...
    [moving_image.meta.height * fixed_image.meta.scale / moving_image.meta.scale,...
    moving_image.meta.width * fixed_image.meta.scale / moving_image.meta.scale]);
%
moving_image.meta.original_size = moving_image.meta.size;
moving_image.meta.original_height = moving_image.meta.height;
moving_image.meta.original_width = moving_image.meta.width;
%
moving_image.meta.size = size(moving_image.image);
moving_image.meta.height = moving_image.meta.size(1);
moving_image.meta.width = moving_image.meta.size(2);
%
end
%