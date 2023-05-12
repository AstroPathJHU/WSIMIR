%% get_initial_transformation_on_region
%
%%
function output = get_transformation_on_region(...
    moving_image_clip, current_fixed_image, input_reg_data)
%                                
done = false;
checked = false;
scaling_factors = [.1 .5 1];
resolution_step = 1;
output = cell(length(scaling_factors), 1);
%
while ~done
    %
    scaling_factor = scaling_factors(resolution_step);
    search_region = get_transformation_search_regions(...
        current_fixed_image, input_reg_data);
    %
    moving_image_subclip = moving_image_clip(...
        search_region(1):search_region(2), ...
        search_region(3):search_region(4),:);
    rescaled_moving_image_subclip = imresize(...
        moving_image_subclip, scaling_factor);
    %
    rescaled_current_fixed_image = imresize(...
        current_fixed_image.image, scaling_factor);
    %
    moving_optimal_layers = get_self_info(...
        double(rescaled_moving_image_subclip), 2);
    fixed_optimal_layers = get_self_info(...
        rescaled_current_fixed_image(...
        :, :, 1:(input_reg_data.tile_ncomponents - 1)), 2);
    %
    [~, MMI_all(1:2), MMI_maps] = get_NDJH_registration(...
        rescaled_moving_image_subclip(:, :, moving_optimal_layers), ...
        rescaled_current_fixed_image(:, :, fixed_optimal_layers),...
        struct('parallel', true));
    %
    current_fixed_image.coordinates(3:4) = adjust_MI(...
        'initial_transformation', MMI_maps, MMI_all, scaling_factor, ...
        search_region);
    %
    conf = mi_confidence(MMI_maps, 1);
    c_resolution_step = resolution_step;
    %
    if conf >= 0.9
        %
        checked = true;
        [input_reg_data, current_fixed_image, resolution_step, done] = ...
            get_next_resolution_step(...
            resolution_step, current_fixed_image, input_reg_data);
        %
    else
        %
        if ~checked
            %
            if strcmp(input_reg_data, 'initial_transformation')
                input_reg_data.initial_search_boarder = [...
                    input_reg_data.tile_width input_reg_data.tile_height];
            else
                input_reg_data.initial_search_boarder = ...
                    input_reg_data.initial_search_boarder * 2;
                current_fixed_image.coordinates(1:2) = ...
                    current_fixed_image.coordinates(3:4);
            end
            %
        else
            [input_reg_data, current_fixed_image, resolution_step, done] = ...
                get_next_resolution_step(...
                resolution_step, current_fixed_image, input_reg_data);
        end
        %
        checked = true;
        %
    end
    %
    output{c_resolution_step}.MMI_maps = MMI_maps;
    output{c_resolution_step}.MMI_all = MMI_all;
    output{c_resolution_step}.resolution = scaling_factors(c_resolution_step);
    output{c_resolution_step}.upper_left_corner = current_fixed_image.coordinates;
    %
end
%
output = [output{:}];
%
end
