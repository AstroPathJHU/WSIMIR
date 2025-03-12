%% write_transform_output_table
%
%%
function write_transform_output_table(fixed_image, moving_image, meta)
%
if ~isfolder(meta.opts.output_dir)
    mkdir(meta.opts.output_dir)
end
%
table_path = fullfile(meta.opts.output_dir, ...
    "wsimir_registration_params.csv");
%
% step 1
output_struct.original_size = moving_image.meta.original_size;
output_struct.original_scale = moving_image.meta.scale;
output_struct.rescaled_size = moving_image.meta.size;
output_struct.output_size = fixed_image.meta.size;
% step 2
output_struct.rotated_boundingbox = moving_image.meta.rotated_boundingbox;
% step 3
output_struct.initial_affine_transform = moving_image.initial_tform.T;
% step 4
output_struct.high_res_affine_transform = moving_image.affine_tform.T;
%
output_table = struct2table(output_struct, "AsArray", true);
%
writetable(output_table, table_path, 'Delimiter', ',')
%
end