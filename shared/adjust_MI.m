%% adjust_MI
%
%%
function coords = adjust_MI(opt, ...
    MMI_maps, coords, scaling_factor, search_region)

%
if size(MMI_maps) > 1
    [X,Y] = meshgrid(1:size(MMI_maps, 2),1:size(MMI_maps, 1));
    [Xq,Yq] = meshgrid(...
        1:scaling_factor:size(MMI_maps, 2),...
        1:scaling_factor:size(MMI_maps, 1));
    Vq = interp2(X, Y, MMI_maps, Xq, Yq, 'spline');
    [~, mind] = max(Vq(:));
    [iy, ix] = ind2sub(size(Vq), mind);
    if strcmp(opt, 'rigid')
        coords = [ix iy] + search_region([3,1]);
    elseif strcmp(opt, 'initial_transformation')
        coords = uint32([ix iy]) + search_region([3,1]);
    end
else
    %
    if strcmp(opt, 'rigid')
        coords = cast(coords, 'single') / scaling_factor + ...
            double(search_region([3,1]));
    elseif strcmp(opt, 'initial_transformation')
        coords = double(coords) / scaling_factor + ...
            double(search_region([3,1]));
    end
    %
end
% current_fixed_image.coordinates(3:4)
    % current_fixed_image.coordinates(3) = double(rloc{i2}(1))/scaling_factor + search_region(3);
    % current_fixed_image.coordinates(4) = double(rloc{i2}(2))/scaling_factor + search_region(1);
    