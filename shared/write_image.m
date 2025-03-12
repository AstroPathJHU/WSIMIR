%% write_image
%
%%
function write_image(image, meta)
%
if ~meta.opts.(['write_step_', num2str(meta.opts.step)])
    return
end
%
if ~isfolder(meta.opts.output_fullimage_path)
    mkdir(meta.opts.output_fullimage_path)
end
%
impath = fullfile(meta.opts.output_fullimage_path,...
    meta.opts.(['output_filename_step_', num2str(meta.opts.step)]));
%
msg = strcat("Writing image for step ", ...
    num2str(meta.opts.step), " to ", impath);
logger(msg, 'INFO', meta)
%
imwrite(image, impath)
%
end