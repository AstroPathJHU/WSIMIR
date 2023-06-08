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
 [moving_image, fixed_image, meta] = ...
wsimir(fixed_image_path, moving_image_path, 'test', 1)
%}
%% ----------------------------------
function [moving_image, fixed_image, meta] = ...
    wsimir(fixed_image_path, moving_image_path, varargin)
%%
meta = argparser(moving_image_path, varargin);
%
moving_image.meta.path = moving_image_path;
fixed_image.meta.path = fixed_image_path;
%
if meta.opts.test
    return
end
%
if ~meta.opts.run_step_1
    return
end
%
meta = startpar(meta);
%
[moving_image, fixed_image] = get_images(...
    moving_image, fixed_image, meta);
%
if ~meta.opts.run_step_2
    return
end
%
[moving_image, fixed_image, meta] = ...
    get_rough_registration(moving_image, fixed_image, meta);
%
if ~meta.opts.run_step_3
    return
end
%
[moving_image, fixed_image, meta] = ...
    get_initial_transformation(moving_image, fixed_image, meta);
%
if ~meta.opts.run_step_4
    return
end
%
[moving_image, fixed_image, meta] = ...
    get_affine_transformation(moving_image, fixed_image, meta);
%
if ~meta.opts.write_moving_image_tiles
    %
    if ~meta.opts.keep_moving_initial_transformed
        moving_image = rmfield(moving_image, 'initial_transformed_image');
    end
    %
    return
end
%
moving_image = write_moving_image_tiles(moving_image, meta);
%
end
