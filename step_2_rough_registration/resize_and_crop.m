%% resize_and_crop
%% Description
% estimate the resized image, if it is outside the bounds adjust slightly
% then perform the resizing for the cropped region and scaling factor added
% as input
%% Input
% image_a: image to be scaled
% image_b: reference image to define largest size
% bb: the bounding box of the image
% mi_vars: struct with:
% - scaling_factor: the scaling factor for the resizing
% - cropped_bound: the cropped boundaries
function [rescaled_a_cropped, mi_vars] = resize_and_crop(...
    image_a, image_b, bb, mi_vars)
%
mi_vars.search_region = [...
       bb(2) - mi_vars.cropped_bound(2),...
       bb(4) + mi_vars.cropped_bound(2) - 1,...
       bb(1) - mi_vars.cropped_bound(1),...
       bb(3) + mi_vars.cropped_bound(1) - 1 ...
   ];
%
mi_vars.search_region = adjust_bounds(image_a, mi_vars.search_region);
%
estimated_size = ceil(mi_vars.search_region * mi_vars.scaling_factor);
%
if estimated_size(2) <= size(image_b, 1)
    mi_vars.search_region(1) = ...
        bb(2) - mi_vars.cropped_bound(2) - 1 / mi_vars.scaling_factor;
    mi_vars.search_region(2) = ...
        bb(4) + mi_vars.cropped_bound(2) - 1 + 1 / mi_vars.scaling_factor;
end
%
if estimated_size(4) <= size(image_b, 2)
    mi_vars.search_region(3) = ...
        bb(1) - mi_vars.cropped_bound(1) - 1 / mi_vars.scaling_factor;
    mi_vars.search_region(4) = ...
        bb(3) + mi_vars.cropped_bound(1) - 1 + 1 / mi_vars.scaling_factor;
end
%
mi_vars.search_region = adjust_bounds(image_a, mi_vars.search_region);
%
rescaled_a_cropped = imresize(image_a(...
       mi_vars.search_region(1):mi_vars.search_region(2),...
       mi_vars.search_region(3):mi_vars.search_region(4),...
       1), mi_vars.scaling_factor);
%
end
%%
function search_region = adjust_bounds(image_a, search_region)
%
a_size = size(image_a);
%
search_region(search_region < 1) = 1;
search_region = adjust_bound(a_size(1), search_region, 2);
search_region = adjust_bound(a_size(2), search_region, 4);
%
end
%%
function cr = adjust_bound(s1, cr, l)
%
if (cr(l) > s1)
    cr(l) = s1;
end
%
end
