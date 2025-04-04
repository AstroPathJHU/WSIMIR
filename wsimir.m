%% wsimir
%% Description
% Start the whole slide image registration
%% Input
% fixed_image_path: a folder with image tiles or a file for the fixed image
% moving_image_path: a folder with image tiles or a file for the moving image
% nbands: number of component layers to read in for the stiching with
% a default of 1
%%
% Usage
% wsimir(fixed_image_path, moving_image_path, vars)
%{
 moving_image_path = '\\bki04\Clinical_Specimen\M21_1\IHC\M21_1.tif';
 fixed_image_path = ...
 '\\bki04\Clinical_Specimen\M21_1\inform_data\Component_Tiffs';
 [fixed_image, moving_image, meta] = ...
wsimir(fixed_image_path, moving_image_path, 'test', 1)
%}
%% ----------------------------------
function [fixed_image, moving_image, meta] = ...
    wsimir(fixed_image_path, moving_image_path, varargin)
%%
[fixed_image, moving_image, meta] = argparser(...
    fixed_image_path, moving_image_path, varargin);
%
if meta.opts.test; return; end
%
% Define corresponding functions for each step
%
steps = {
    @get_images;
    @get_rough_registration;
    @get_initial_transformation;
    @get_high_res_transformation;
    @write_moving_image_tiles
};
%
% Iterate over steps sequentially
%
for step_idx = 1:length(steps)
    if ~meta.opts.(['run_step_', num2str(step_idx)])
        break
    end
    %
    meta.opts.step = step_idx;
    logger(meta.opts.step_names(step_idx+1), 'START', meta)
    [fixed_image, moving_image, meta] = ...
        meta.opts.steps{step_idx}(fixed_image, moving_image, meta);
    logger(meta.opts.step_names(step_idx+1), 'FINISH', meta)
    %
end
%
meta.opts.step = 6;
%
if ~meta.opts.keep_step_1 && ...
        (meta.opts.show_any || meta.opts.save_overlay_any)
    fixed_image = rmfield(fixed_image, 'image');
end
%
msg = 'Whole Slide Imaging, Mutual Information Registration';
logger(msg, 'FINISH', meta)
%
end
