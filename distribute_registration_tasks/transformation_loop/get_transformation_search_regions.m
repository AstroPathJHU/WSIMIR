%% get_transformation_search_regions
% get the transformation search region, if the region is at the edge shift
% it to the edge
%% Output 
% search_region: the search region bounding box
%%
function search_region = get_transformation_search_regions(...
    current_fixed_image, input_reg_data)
%
search_region(1) = current_fixed_image.coordinates(2) - ...
    input_reg_data.initial_search_boarder(2);
search_region(2) = current_fixed_image.coordinates(2) + ...
    input_reg_data.tile_height + input_reg_data.initial_search_boarder(2);
search_region(3) = current_fixed_image.coordinates(1) - ...
    input_reg_data.initial_search_boarder(1);
search_region(4) = current_fixed_image.coordinates(1) + ...
    input_reg_data.tile_width + input_reg_data.initial_search_boarder(1);
%
search_region = uint32(search_region);
%
if strcmp(input_reg_data.opt, 'high_res_transformation')
    %
    search_region([2,4]) = search_region([2,4]) - 1;
    %
    edge = input_reg_data.moving_clip_size(1) - ...
        input_reg_data.tile_height + 1;
    %
    if search_region(1) > edge
        search_region(1) = edge;
    end
    %
    edge = input_reg_data.moving_clip_size(2) - ...
        input_reg_data.tile_width + 1;
    %
    if search_region(3) > edge
        search_region(3) = edge;
    end
    %
end
%
if search_region(2) > input_reg_data.moving_clip_size(1)
    search_region(2) = input_reg_data.moving_clip_size(1);
end
%
if search_region(4) > input_reg_data.moving_clip_size(2)
    search_region(4) = input_reg_data.moving_clip_size(2);
end
%
search_region(search_region <= 0) = 1;
%
end