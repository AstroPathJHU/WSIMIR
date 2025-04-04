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
% previous_conf = double(0.5);
stored_MMI_maps = [];
stored_MMI_all = [];
%
while ~done
    %
    search_region = get_transformation_search_regions(...
        current_fixed_image, input_reg_data);
    %
    moving_image_subclip = moving_image_clip(...
        search_region(1):search_region(2), ...
        search_region(3):search_region(4),:);
    rescaled_moving_image_subclip = imresize(...
        moving_image_subclip, scaling_factors(resolution_step));
    %
    rescaled_current_fixed_image = imresize(...
        current_fixed_image.image, scaling_factors(resolution_step));
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
        'initial_transformation', MMI_maps, MMI_all, ...
        scaling_factors(resolution_step), search_region);
    %
    conf = mi_confidence(MMI_maps, 1);
    %
    if isempty(stored_MMI_maps)
        stored_MMI_maps = MMI_maps;
        stored_MMI_all = MMI_all;
        stored_conf = conf;
    end
    %
    if conf >= 0.25
        %
        current_fixed_image.coordinates(1:2) = ...
            current_fixed_image.coordinates(3:4);
        % previous_conf = conf;
        %
        stored_MMI_maps = MMI_maps;
        stored_MMI_all = MMI_all;
        stored_conf = conf;
        %
    end
    %
    if conf >= 0.9 || checked
        %
        output{resolution_step}.MMI_maps = stored_MMI_maps;
        output{resolution_step}.MMI_all = stored_MMI_all;
        output{resolution_step}.resolution = ...
            scaling_factors(resolution_step);
        output{resolution_step}.conf = stored_conf;
        output{resolution_step}.upper_left_corner = ...
            current_fixed_image.coordinates;
        %
        [input_reg_data, resolution_step, done] = ...
            get_next_resolution_step(resolution_step, input_reg_data);
        checked = true;
        stored_MMI_maps = [];
        stored_MMI_all = [];
        % previous_conf = double(0.01);
        %
    else
        %
        if strcmp(input_reg_data.opt, 'initial_transformation')
            input_reg_data.initial_search_boarder = [...
                input_reg_data.tile_width input_reg_data.tile_height];
        else
            input_reg_data.initial_search_boarder = ...
                input_reg_data.initial_search_boarder * 2;
        end
        %
        checked = true;
        %
    end
    %
end
%
output = [output{:}];
%
end
