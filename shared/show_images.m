%% show_images
% parse the input arguments and define defaults, see README for more
% details on options
%%
function show_images(image_1, image_2, image_ids, meta)
%
if ~(meta.opts.(['show_step_', num2str(meta.opts.step)]) || ...
        meta.opts.(['save_overlay_step_', num2str(meta.opts.step)]))
    return
end
%
msg = strcat("Displaying images: fixed ", image_ids{1}, ...
    " (Left/R) - moving ", image_ids{2}, " (Right/B)");
logger(msg, 'INFO', meta)
%
if meta.opts.(['show_step_', num2str(meta.opts.step)])
    showme = 'on';
else
    showme = 'off';
end
%
XX = figure('visible' , showme);
set(gcf, 'units','normalized','outerposition',[0 0 1 1],...
    'PaperUnits','inches');
XX.PaperPositionMode = 'auto';
%
positions = [ ...
    -.07 0.51 0.65 0.45; ...
    0.42 0.51 0.65 0.45; ...
    0.175 0.02 0.65 0.45];
%
p1 = axes('Position', positions(1, :));
im1 = prepare_display_image(image_1, image_ids{1});
imshow(im1)
title(p1, strcat("Fixed ", image_ids{1}))
%
p2 = axes('Position', positions(2, :));
im2 = prepare_display_image(image_2, image_ids{2});
imshow(im2)
title(p2, strcat("Moving ", replace(image_ids{2}, '_', ' ')))
%
im1 = convert_rgb2_gray(im1);
im2 = convert_rgb2_gray(im2);
%
im3 = zeros(1000, 2000, 3);
im3(:, :, 1) = .75 * im1;
im3(:, :, 3) = .75 * im2;
%
p3 = axes('Position', positions(3, :));
imshow(uint8(im3))
title(p3, strcat("Overlay of Fixed ", image_ids{1}, " (Red) and Moving ", ...
    replace(image_ids{2}, '_', ' '), " (Blue)"))
%
if meta.opts.(['save_overlay_step_', num2str(meta.opts.step)])
    %
    if ~isfolder(meta.opts.output_fullimage_path)
        mkdir(meta.opts.output_fullimage_path)
    end
    %
    impath = fullfile(meta.opts.output_fullimage_path,...
        meta.opts.(['output_filename_step_', num2str(meta.opts.step)]));
    impath = replace(replace(impath, "_moving", ""), ".tif", "_overlay.tif");        
    print(XX, impath, '-dtiff', '-r0')
    %
end
%
if ~meta.opts.show_any
    close all
end
%
end

function im_out = prepare_display_image(image, image_id)
%
im_out = image.(image_id);
%
if ~strcmp(image_id, 'image') && ~strcmp(image_id, 'final_restitched_image')
    bb = image.meta.rotated_boundingbox;
    im_out = im_out(bb(2)+1:bb(4), bb(1)+1:bb(3), :);
end
%    
im_out = imresize(im_out, [1000, 2000]);
if length(image.meta.size) == 2
    im_out = uint8(180 * asinh(1.25 * im_out / prctile(im_out, 95, "all")));
end
%
end

function im_out = convert_rgb2_gray(im)
%
if length(size(im)) == 2
    im_out = im;
else
    img = single(255 - rgb2gray(im));
    im_out = uint8(180 * asinh(1.25 * img / prctile(img, 95, "all")));
end
%
end