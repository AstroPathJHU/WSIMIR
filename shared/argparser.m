%% argparser
% parse the input arguments and define defaults, see README for more
% details on options
%%
function [fixed_image, moving_image, meta] = argparser(...
    fixed_image_path, moving_image_path, varargin)
%
vars = varargin{1};
%
opts.nbands = 1;
opts.numcores = 16;
opts.numthreads = 2; % threads available to workers in parjobs for 3 & 4
opts.test = 0;
%
opts.log_level = 'INFO';
opts.log_levels = struct(...
    'DEBUG', 0, ...
    'INFO', 1, ...
    'START', 2, ...
    'FINISH', 2, ...
    'WARN', 3, ...
    'ERROR', 4);
opts.format_log = 1;
opts.log_no_start_stop = 0;
%
opts.keep_all = 0;
opts.keep_step_1 = 0;
opts.keep_step_2 = 0;
opts.keep_step_3 = 0;
opts.keep_step_4 = 0;
opts.keep_step_5 = 0;
%
opts.run_all = 1;
opts.run_step_1 = 0;
opts.run_step_2 = 0;
opts.run_step_3 = 0;
opts.run_step_4 = 0;
opts.run_step_5 = 0;
%
opts.show_all = 0;
opts.show_step_1 = 0;
opts.show_step_2 = 0;
opts.show_step_3 = 0;
opts.show_step_4 = 0;
opts.show_step_5 = 0;
%
opts.save_overlay_all = 1;
opts.save_overlay_step_1 = 0;
opts.save_overlay_step_2 = 0;
opts.save_overlay_step_3 = 0;
opts.save_overlay_step_4 = 0;
opts.save_overlay_step_5 = 0;
%
opts.output_dir = '';
%
opts.write_all = 0;
opts.write_step_2 = 0;
opts.write_step_3 = 0;
opts.write_step_4 = 0;
opts.write_step_5 = 1;
%
opts.output_filename_step_1 = 'step_1_initial_moving_image.tif';
opts.output_filename_step_2 = 'step_2_rotated_moving_image.tif';
opts.output_filename_step_3 = 'step_3_initial_transformed_moving_image.tif';
opts.output_filename_step_4 = 'step_4_high_res_transformed_moving_image.tif';
opts.output_filename_step_5 = 'step_5_restitched_moving_image.tif';
%
opts.step_names = ["initializing"; "get_images"; ...
    "get_rough_registration"; "get_initial_transformation"; ...
    "get_high_res_transformation"; "write_moving_image_tiles";
    "post_processing"];
opts.step = 0;
meta.opts = opts;
%
logger( ...
    'Whole Slide Imaging, Mutual Information Registration', 'START', meta)
%
for i1 = 1:2:length(vars)
    if (isfield(opts, vars{i1}))
        opts.(vars{i1}) = vars{i1 + 1};
    else
        msg = strcat('Variable not valid: mismatch variable pairs or', ...
            'invalid name: ', vars{i1});
        logger(msg, 'ERROR', meta)
    end
end
%
if opts.keep_all
    for step = 1:5
        opts.(['keep_step_', num2str(step)]) = 1;
    end
end
%
if opts.show_all
    for step = 1:5
        opts.(['show_step_', num2str(step)]) = 1;
    end
end
%
opts.show_any = (opts.show_all || opts.show_step_1 || opts.show_step_2 ...
        || opts.show_step_3 || opts.show_step_4 || opts.show_step_5);
%
% for running up to a particular step; ensures all previous steps are
% enabled when a higher step is selected
%
for step = 1:5
    if opts.(['run_step_', num2str(step)])
        for prev_step = 1:step
            opts.(['run_step_', num2str(prev_step)]) = 1;
        end
        opts.run_all = 0;
        opts.test = 0;
    end
end
%
if opts.run_all
    for step = 1:5
        opts.(['run_step_', num2str(step)]) = 1;
    end
end
%
for step = 1:5
    if opts.(['save_overlay_step_', num2str(step)])
        opts.save_overlay_all = 0;
    end
end
%
if opts.save_overlay_all
    for step = 1:5
        opts.(['save_overlay_step_', num2str(step)]) = 1;
    end
end
%
opts.save_overlay_any = (opts.save_overlay_all || ...
    opts.save_overlay_step_1 || opts.save_overlay_step_2 || ...
    opts.save_overlay_step_3 || opts.save_overlay_step_4 || ...
    opts.save_overlay_step_5);
%
if opts.write_all
    for step = 1:5
        opts.(['write_step_', num2str(step)]) = 1;
    end
end
%
if isempty(opts.output_dir)
    %
    fpath = fileparts(moving_image_path);
    opts.output_dir = fullfile(fpath);
    %
end
%
if ~isfolder(opts.output_dir)
    mkdir(opts.output_dir)
end
%
opts.output_fullimage_path = fullfile(...
    opts.output_dir, 'wsimir_registration_data');
opts.output_tile_path = fullfile(opts.output_dir, 'HPFs');
%
opts.steps = {
    @get_images;
    @get_rough_registration;
    @get_initial_transformation;
    @get_high_res_transformation;
    @write_moving_image_tiles
};
%
opts.step_names = ["initializing"; "get_images"; ...
    "get_rough_registration"; "get_initial_transformation"; ...
    "get_high_res_transformation"; "write_moving_image_tiles";
    "post_processing"];
%
meta.opts = opts;
%
moving_image.meta.path = moving_image_path;
fixed_image.meta.path = fixed_image_path;
%
end