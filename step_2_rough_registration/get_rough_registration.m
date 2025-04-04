%% get_rough_registration
%% Description
%
% starting at a low resolution then performing at 6 higher resolutions,
% detect the highest mutual information point. If the image is registered
% on the fixed image boundary, restart the registration with image padding.
% 
%% Input
% image_info_a: the moving image and it's info
% image_info_b: the fixed image and it's info
%% Output
% MMI_maps: the mutual information maximum for each resolution step
% rotation_correction: the total rotation correction applied
% image_info_a: the image info struct with rotated image a added in
% image_info_b: the image info object of b
%% -----------------------
function [fixed_image, moving_image, meta] = ...
    get_rough_registration(fixed_image, moving_image, meta)
%
logger('Setting up coarse registration', 'INFO', meta)
%
% rotation loop parameters
%
cropping_bounds = [0, 2000, 400, 200, 100, 40];
rotation_params = [180, 5, 1, 0.2, 0.08, 0];
rotation_steps = [361, 21, 15, 11, 7, 1];
n_steps = length(rotation_steps);
rotation_limits = cell(n_steps, 1);
for i1 = 1:n_steps
    rotation_limits{i1} = linspace(...
        -rotation_params(i1), rotation_params(i1), rotation_steps(i1));
end
scaling_factors = [0.001 ,0.005, 0.01, 0.02, 0.05, 0.1];
subsampling_fractions = [1, 1, 1, 1, 0.5, 0.1];
%
% initial registration parameters
%
MMI_maps = cell(n_steps, 1);
rotation_correction = 0;
resolution_step = 1;
bb = double([1, 1, moving_image.meta.size(2), moving_image.meta.size(1)]);
rotated_moving = moving_image.image;
mi_vars.step_size = [1 1];
mi_vars.scale = true;
%
while resolution_step <= n_steps
   %
   tic
   %
   mi_vars.cropped_bound = [...
       cropping_bounds(resolution_step), cropping_bounds(resolution_step)];
   mi_vars.scaling_factor = scaling_factors(resolution_step);
   mi_vars.rotation_param = rotation_limits{resolution_step};
   mi_vars.subsampling_fraction = subsampling_fractions(resolution_step);
   %
   % rescale fixed image, then rescale the moving image
   %
   rescaled_fixed = imresize(...
       fixed_image.image(:,:,1), mi_vars.scaling_factor);
   [cropped_rescaled_moving, mi_vars] = resize_and_crop(...
       rotated_moving, rescaled_fixed, bb, mi_vars);
   %
   % get the initial coarse registration
   %
   msg = strcat("Calculating initial coarse registration step ", ...
       string(resolution_step), " of ", string(n_steps));
   logger(msg, 'INFO', meta)
   [coords, rotation_delta, MMI_maps{resolution_step}] = ...
       get_rigid_registration(cropped_rescaled_moving, rescaled_fixed, mi_vars);
   %
   % edit moving variables
   %
   rotation_correction = rotation_correction + rotation_delta;
   rotated_moving = imrotate(rotated_moving, rotation_delta);
   bb = [coords(1), coords(2), coords(1) + fixed_image.meta.width,...
       coords(2) + fixed_image.meta.height];
   resolution_step = resolution_step + 1;
   %
   % check relative location of moving image. If image is on a boarder
   % restarts the registration with additional padding. 
   %
   [bb, coords, resolution_step, moving_image, rotated_moving] = ...
       pad_image_a(mi_vars.scaling_factor, rotated_moving, coords,...
       fixed_image, bb, resolution_step, moving_image, meta);
   %
   logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
   %
end
%
logger('Saving coarse registration parameters', 'INFO', meta)
%
moving_image.rotated_image = rotated_moving;
moving_image.meta.rotated_boundingbox = bb;
moving_image.meta.rotated_upperleftcorner = coords;
% 
meta.rough_registration_output.MMI_maps = MMI_maps;
meta.rough_registration_output.rotation_correction = rotation_correction;
%
meta.initial_transformation.input_reg_data.moving_image_size = ...
    size(moving_image.rotated_image);
%
if ~(meta.opts.keep_step_1 || meta.opts.show_any || meta.opts.save_overlay_any)
    fixed_image = rmfield(fixed_image, 'image');
end
%
if ~meta.opts.keep_step_1
    moving_image = rmfield(moving_image, 'image');
end
%
write_image(moving_image.rotated_image, meta)
show_images(fixed_image, moving_image, {'image', 'rotated_image'}, meta)
%
end
