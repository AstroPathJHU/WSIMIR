%% pad_image_a
%% Description
% It is assumed  that image_a is larger than image_b, occasionally there 
% may be one edge of image_a that appears cropped. If the correct location
% is at the edge of the slide, we pad that edge and continue
% registration.
%% Input
% scaling_factor
% image_a: the stationary, reference image
% coords
% image_info_b
% bb
%% ----------------------------------
function [bb, coords, i1, moving_image, rotated_moving] = pad_image_a(...
    scaling_factor, rotated_moving, coords, fixed_image, bb, i1, moving_image)
if coords(1) <= 1
    [bb, coords, i1, moving_image, rotated_moving] = pad_image(...
        scaling_factor, moving_image, coords, 'pre', 'width');
end
%
if coords(1) >= size(rotated_moving, 2) - fixed_image.meta.width + 1
    [bb, coords, i1, moving_image, rotated_moving] = pad_image(...
        scaling_factor, moving_image, coords, 'post', 'width');
end
%
if coords(2) <= 1
    [bb, coords, i1, moving_image, rotated_moving] = pad_image(...
        scaling_factor, moving_image, coords, 'pre', 'height');
end
%
if coords(2) >= size(rotated_moving, 1) - fixed_image.meta.height + 1
    [bb, coords, i1, moving_image, rotated_moving] = pad_image(...
        scaling_factor, moving_image, coords, 'post', 'height');
end
%
end
%% pad_image
%% Description
% add padding to the image as needed
%%
function [bb, coords, i1, moving_image, rotated_moving] = pad_image(...
    scaling_factor, moving_image, coords, type_of_pad, side)
%
p = 1/scaling_factor;
moving_image.image = padarray(moving_image.image, [0, p], 0, type_of_pad);
%
if strcmp(side, 'width')
    coords(1) = p/2;
else 
    coords(2) = p/2;
end
%
warning('moving image registered at edge of fixed image and the moving image has been padded')
moving_image.Padding ={[0, p], 0, type_of_pad};
i1 = 1;
bb(4) = size(moving_image.image, 1);
bb(3) = size(moving_image.image, 2);
bb(2) = 1;
bb(1) = 1;
%
rotated_moving = moving_image.image;
%
end