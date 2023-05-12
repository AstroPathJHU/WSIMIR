%% calculate_and_apply_transform
% calculates and applies the transformation to the 'current_image' based
% on old and new points supplied to the function
%% Output
% transformed_image: the transformed image
%%
function [transformed_image, tform] = calculate_and_apply_transform(...
    old_points, new_points, current_image)
[ab, cd, e, f] = newtform(old_points, new_points);
%
% transform the moving image
%
tform = affine2d([ab(1) ab(2) e; cd(1) cd(2) f; 0 0 1]');
%
% Referencing the moving image
%
Rin = imref2d(size(current_image));
%
transformed_image = imwarp(current_image, Rin, tform, 'OutputView', Rin);
%
end