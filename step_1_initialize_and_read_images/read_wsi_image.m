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
function [fixed_image, moving_image] = ...
    read_wsi_image(fixed_image, moving_image, meta)
%
moving_image = open_wsi(moving_image, meta);
fixed_image = open_wsi(fixed_image, meta);
%
end
%% open_wsi
%
function image_data = open_wsi(image_data, meta)
%
if ~strcmp(image_data.meta.type, 'WSI')
    return
end
%
path = fullfile(image_data.meta.image_names.folder,...
    image_data.meta.image_names.name);
logger(['Reading WSI at ', path], 'INFO', meta)
%
tic
%
t = Tiff(path);
setDirectory(t, image_data.meta.level)
is_tiles_logical = isTiled(t);
close(t)
%
if is_tiles_logical
    try
        image_data.image = read_big_tiff(path, image_data.meta.level);
    catch err
       input_err.message = ['Could not read image, the image ', path, ...
           ' may be corrupt'];
       input_err.stack = err.stack;
       input_err.identifier = err.identifier;
       logger(input_err, 'ERROR', meta)
    end
else
    msg = 'WSI is not in TILED format, will take longer to read';
    logger(msg, 'WARN', meta)
    image_data.image = imread(path, image_data.meta.level);
end
%
ss = size(image_data.image);
image_data.meta.width = ss(2);
image_data.meta.height = ss(1);
image_data.meta.size = ss;
%
logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
%
end 
