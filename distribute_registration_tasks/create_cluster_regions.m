%% create_cluster_regions
%
%%
function [image_group, moving_image_clip] = ...
    create_cluster_regions(moving_image, fixed_image,...
    input_reg_data, image_group, opt)
%
if ~isempty(image_group.bb)
    %
    cluster_search_region = uint32([...
        image_group.bb(2) - input_reg_data.search_boarder(2), ...
        image_group.bb(4) + input_reg_data.tile_height + ...
        input_reg_data.search_boarder(2), ...
        image_group.bb(1) - input_reg_data.search_boarder(1),...
        image_group.bb(3) + input_reg_data.tile_width + ...
        input_reg_data.search_boarder(1)]);
    %
    cluster_search_region(cluster_search_region <= 0) = 1;
    %
    % if over edge assign to edge
    %
    if cluster_search_region(2) > input_reg_data.moving_image_size(1)
        cluster_search_region(2) = input_reg_data.moving_image_size(1);
    end
    %
    if cluster_search_region(4) > input_reg_data.moving_image_size(2)
        cluster_search_region(4) = input_reg_data.moving_image_size(2);
    end
    %
    control_pt_coordinates = fixed_image.meta.relative_ul_corners(...
        image_group.control_point_idx, :);
    %
    if strcmp(opt, 'initial_transformation')
        %
        moving_image_clip = moving_image.rotated_image(...
            cluster_search_region(1):cluster_search_region(2),....
            cluster_search_region(3):cluster_search_region(4), :);
        %
        % set fixed image grid coordinates relative to the cluster search
        % region, this version of it sets the zero at -1 of the search 
        % region, I think it's a mistake but may be irrelevent.
        %
        cluster_relative_control_pt_xcoords =  control_pt_coordinates(:, 1) - ...
            cast(cluster_search_region(3) + 1, ...
            class(fixed_image.meta.relative_ul_corners));
        cluster_relative_control_pt_ycoords =  control_pt_coordinates(:, 2) - ...
            cast(cluster_search_region(1) + 1, ...
            class(fixed_image.meta.relative_ul_corners));
        %
    elseif strcmp(opt, 'affine_transformation')
        %
        moving_image_clip = moving_image.initial_transformed_image(...
            cluster_search_region(1):cluster_search_region(2),....
            cluster_search_region(3):cluster_search_region(4), :);
        %
        % origin for final registration is 1
        %
        control_pt_coordinates = control_pt_coordinates + 1;
        %
        % set fixed image grid coordinates relative to the cluster search
        % region using 1 as origin 
        %
        cluster_relative_control_pt_xcoords =  control_pt_coordinates(:, 1) - ...
            cast(cluster_search_region(3), ...
            class(fixed_image.meta.relative_ul_corners)) + 1;
        cluster_relative_control_pt_ycoords =  control_pt_coordinates(:, 2) - ...
            cast(cluster_search_region(1), ...
            class(fixed_image.meta.relative_ul_corners)) + 1;
    end
    %
    image_group.cluster_relative_control_pt_coordinates = ...
        [cluster_relative_control_pt_xcoords cluster_relative_control_pt_ycoords];
    %
    image_group.cluster_search_region = cluster_search_region;
    %
    image_group.fixed_image_files = ...
        fixed_image.meta.image_names(image_group.control_point_idx);
else 
    moving_image_clip = [];
end
%
end