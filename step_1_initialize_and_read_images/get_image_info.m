%% get_image_info
%% Description
%
% get the image info standard variables to be used throughout the script.
% We make a couple assumptions at this step. First if the image is a WSI
% image and that image has multiple resolutions, the appropriate layer for 
% registration is a 20x image and the resolution labels are in the
% 'ImageDescription' field of the metadata. Other resolutions can be used
% if the WSI image is a single resolution image. Second, we assume that if
% the input is a directory of tiff images, the images are in the Akoya
% Biosciences component tiff format. 
% 
%% Input
% mpath: folder or file path
%% ----------------------------------
function out_struct = get_image_info(mpath, meta)

isfolderm = isfolder(mpath);
%
if ~isfolderm
    if ~exist(mpath, 'file')
        msg = [mpath, ' could not be found'];
        logger(msg, 'ERROR', meta)
    end
    %
    image_info = imfinfo(mpath);
    %
    if length(image_info) > 1
        ids = regexp({image_info(:).ImageDescription}, '20');
        level = find(~cellfun('isempty', ids));
        if level
            image_info = image_info(level);
        else 
            msg = ['image has more than one layer and correct layer',...
                ' correct layer cannot be identified ', mpath];
            logger(msg, 'ERROR', meta)
        end
    else 
        level = 1;
    end
    %
    image_names = dir(mpath);
    type = 'WSI';
    %
else 
    %
    image_names = dir(fullfile(mpath, '*component_data.tif'));
    %
    if isempty(image_names)
        msg = ['path was a directory, image tiles in the Akoya format',...
            'were expected but not found: ', mpath];
        logger(msg, 'ERROR', meta)
    end
    %
    image_info = imfinfo(fullfile(...
        image_names(1).folder, image_names(1).name));
    ii = strcmp({image_info(:).ColorType}, 'grayscale');
    image_info = image_info(ii);
    %
    % get the x and y coordinates into the names structure
    %
    for i1 = 1:length(image_names)
        split_names = strsplit(image_names(i1).name, {'[',',',']'});
        image_names(i1).x_coord = str2double(split_names(2));
        image_names(i1).y_coord = str2double(split_names(3));
        image_names(i1).coords = ...
            [image_names(i1).x_coord, image_names(i1).y_coord];
    end
    %
    out_struct.tile_height = image_info(1).Height;
    out_struct.tile_width = image_info(1).Width;
    %
    level = 1;
    type = 'TILE';
    %
end 
%
out_struct.image_info = image_info;
out_struct.isfolder = isfolderm;
out_struct.image_names = image_names;
out_struct.scale = 1 / (10^4 * (1 / image_info(1).XResolution));
out_struct.ncomponents = length(image_info);
out_struct.level = level;
out_struct.type = type;
out_struct.path = mpath;
%
end
