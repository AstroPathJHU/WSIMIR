%% write_transform_output_table
%
%%
function write_transform_output_table(moving_image, meta)
%
table_path = fullfile(meta.opts.output_fullimage_path, ...
    "registration_parameters.csv");
%
msg = strcat("Writing transform output table to ", table_path);
logger(msg, 'INFO', meta)
%
if ~isfolder(meta.opts.output_fullimage_path)
    mkdir(meta.opts.output_fullimage_path)
end
%
% step 1
output_struct.original_h  = moving_image.meta.original_size(1);
output_struct.original_w  = moving_image.meta.original_size(2);
output_struct.original_scale = moving_image.meta.scale;
output_struct.rescaled_h  = moving_image.meta.size(1);
output_struct.rescaled_w  = moving_image.meta.size(2);
% step 2
output_struct.rotation = meta.rough_registration_output.rotation_correction;
output_struct.rotated_bb_w1 = moving_image.meta.rotated_boundingbox(1);
output_struct.rotated_bb_h1 = moving_image.meta.rotated_boundingbox(2);
output_struct.rotated_bb_w2 = moving_image.meta.rotated_boundingbox(3);
output_struct.rotated_bb_h2 = moving_image.meta.rotated_boundingbox(4);
% step 3
output_struct.a1 = moving_image.initial_tform.T(1, 1);
output_struct.b1 = moving_image.initial_tform.T(1, 2);
output_struct.c1 = moving_image.initial_tform.T(2, 1);
output_struct.d1 = moving_image.initial_tform.T(2, 2);
output_struct.e1 = moving_image.initial_tform.T(3, 1);
output_struct.f1 = moving_image.initial_tform.T(3, 2);
% step 4
output_struct.a2 = moving_image.high_res_tform.T(1, 1);
output_struct.b2 = moving_image.high_res_tform.T(1, 2);
output_struct.c2 = moving_image.high_res_tform.T(2, 1);
output_struct.d2 = moving_image.high_res_tform.T(2, 2);
output_struct.e2 = moving_image.high_res_tform.T(3, 1);
output_struct.f2 = moving_image.high_res_tform.T(3, 2);
%
output_table = struct2table(output_struct);
%
writetable(output_table, table_path, 'Delimiter', ',')
%
end