%% get_next_resolution_step
% in the initial tranformation step, this 
function [input_reg_data, current_fixed_image, resolution_step, done] = ...
    get_next_resolution_step(resolution_step, current_fixed_image, ...
    input_reg_data)
%
done = false;
%
search_boarder_steps = {[5 5; 20 20;], [2 2; 10 10]};
if strcmp(input_reg_data, 'initial_transformation')
    opt_count = 1;
else
    opt_count = 2;
end
%
switch resolution_step
    case 3
        current_fixed_image.coordinates(1:2) = ...
            current_fixed_image.coordinates(3:4);
        done = true;
    case 2
        resolution_step = 3;
        input_reg_data.initial_search_boarder(1:2) = ...
            search_boarder_steps{opt_count}(1,:);
        current_fixed_image.coordinates(1:2) = ...
            current_fixed_image.coordinates(3:4);
    case 1
        resolution_step = 2;
        input_reg_data.initial_search_boarder(1:2) = ...
            search_boarder_steps{opt_count}(2,:);
        current_fixed_image.coordinates(1:2) = ...
            current_fixed_image.coordinates(3:4);
end
end