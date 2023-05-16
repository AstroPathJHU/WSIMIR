%% read_wsi_image
%% Description
% read a whole slide image
%% Input
% image_info_a: a data structure from image info for patha from 
% get_image_info
% image_info_b: a data structure from image info for pathb from 
% get_image_info
%% Output
% WSI type images will have the "image" field populated with an image
%% ----------------------------------
function [moving_image, fixed_image] =...
    read_wsi_image(moving_image, fixed_image)
%
moving_image = open_wsi(moving_image);
fixed_image = open_wsi(fixed_image);
%
end
%% open_wsi
%
function image_data = open_wsi(image_data)
%
if ~strcmp(image_data.meta.type, 'WSI')
    return
end
%
path = fullfile(image_data.meta.image_names.folder,...
    image_data.meta.image_names.name);
fprintf('Reading WSI %s \n', path);
%
tic
%
t = Tiff(path);
if isTiled(t)
    close(t)
    image_data.image = read_big_tiff(path, image_data.meta.level);
else
    close(t)
    fprintf('WARNING WSI is not in TILED format \n') ;
    image_data.image = imread(path, image_data.meta.level);
end
%
ss = size(image_data.image);
image_data.meta.width = ss(2);
image_data.meta.height = ss(1);
image_data.meta.size = ss;
%
fprintf('           ');
toc;
%
end 
