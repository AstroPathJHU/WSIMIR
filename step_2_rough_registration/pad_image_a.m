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
function [bb, coords, i1, image_info_a] = pad_image_a(...
    scaling_factor, rotated_a, coords, image_info_b, bb, i1, image_info_a)
if coords(1) <= 1
    [bb, coords, i1, image_info_a] = pad_image(...
        scaling_factor, rotated_a, image_info_a, coords, 'pre', 'width');
end
%
if coords(1) >= size(rotated_a, 2) - image_info_b.meta.width + 1
    [bb, coords, i1, image_info_a] = pad_image(...
        scaling_factor, rotated_a, image_info_a, coords, 'post', 'width');
end
%
if coords(2) <= 1
    [bb, coords, i1, image_info_a] = pad_image(...
        scaling_factor, rotated_a, image_info_a, coords, 'pre', 'height');
end
%
if coords(2) >= size(rotated_a, 1) - image_info_b.meta.height + 1
    [bb, coords, i1, image_info_a] = pad_image(...
        scaling_factor, rotated_a, image_info_a, coords, 'post', 'height');
end
%
end
%% pad_image
%% Description
% add padding to the image as needed
%%
function [bb, coords, i1, image_info_a] = pad_image(...
    scaling_factor, rotated_a, image_info_a, coords, type_of_pad, side)
%
p = 1/scaling_factor;
rotated_a = padarray(rotated_a, [0, p], 0, type_of_pad);
%
if strcmp(side, 'width')
    coords(1) = p/2;
else 
    coords(2) = p/2;
end
%
warning('MIF registrered at edge of IHC image and the IHC image has been padded')
image_info_a.Padding ={[0, p], 0, type_of_pad};
i1 = 1;
bb(4) = size(rotated_a, 1);
bb(3) = size(rotated_a, 2);
bb(2) = 1;
bb(1) = 1;
%
end