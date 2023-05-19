%% argparser
% parse the input arguments and define defaults, see README for more
% details on options
%%
function meta = argparser(moving_image_path, varargin)
%
vars = varargin{1};
%
opts.nbands = 1;
opts.numcores = 16;
opts.numthreads = 1;
opts.test = 0;
opts.keep_moving_original = 0;
opts.keep_moving_rotated = 0;
opts.keep_moving_initial_transformed = 0;
opts.keep_moving_affine_transformed = 0;
opts.keep_all_moving = 0;
opts.keep_all_fixed = 0;
opts.keep_all = 0;
opts.run_all = 1;
opts.run_step_1 = 0;
opts.run_step_2 = 0;
opts.run_step_3 = 0;
opts.run_step_4 = 0;
opts.output_dir = '';
%
opts.write_moving_image_tiles = 1;
opts.write_registered_moving_image_wsi = 0;
opts.write_step2_rotated_moving_image_wsi = 0;
opts.write_step3_initial_transformed_moving_image_wsi = 0;
%
opts.step2_out_filename = 'step2_rotated_moving_image_wsi.tif';
opts.step3_out_filename = 'step3_initial_transformed_moving_image_wsi.tif';
opts.registered_moving_image_wsi = 'registered_moving_image_wsi.tif';
%
for i1 = 1:2:length(vars)
    if (isfield(opts, vars{i1}))
        opts.(vars{i1}) = vars{i1 + 1};
    else 
        error(strcat('variable not valid: mismatch variable pairs or invalid', ...
            ' name: ', vars{i1}))
    end
end
%
if opts.keep_all_moving
    opts.keep_moving_original = 1;
    opts.keep_moving_rotated = 1;
    opts.keep_moving_initial_transformed = 1;
    opts.keep_moving_affine_transformed = 1;
end
%
if opts.keep_all
    opts.keep_moving_original = 1;
    opts.keep_moving_rotated = 1;
    opts.keep_moving_initial_transformed = 1;
    opts.keep_moving_affine_transformed = 1;
    opts.keep_all_moving = 1;
    opts.keep_all_fixed = 1;
end
%
% for running up to a particular step, typically used for testing purposes.
%
if opts.run_step_1
    opts.run_all = 0;
    opts.test = 0;
end
%
if opts.run_step_2
    opts.run_step_1 = 1;
    opts.run_step_2 = 1;
    opts.run_all = 0;
    opts.test = 0;
end
%
if opts.run_step_3
    opts.run_step_1 = 1;
    opts.run_step_2 = 1;
    opts.run_step_3 = 1;
    opts.run_all = 0;
    opts.test = 0;
end
%
if opts.run_step_4
    opts.run_all = 1;
    opts.test = 0;
end
%
if opts.run_all
    opts.run_step_1 = 1;
    opts.run_step_2 = 1;
    opts.run_step_3 = 1;
    opts.run_step_4 = 1;
end
%
if isempty(opts.output_dir)
    fpath = fileparts(moving_image_path);
    opts.output_dir = fullfile(fpath, 'wsimir_registration');
    if ~isfolder(opts.output_dir)
        mkdir(opts.output_dir)
    end
end
%
meta.opts = opts;
%
end