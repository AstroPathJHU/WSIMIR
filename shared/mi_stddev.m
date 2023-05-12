%% mi_stddev
% find the standard deviation over the image for input to confidence
%%
function MMI_map_stddev = mi_stddev(MMI_map, opt, range)
%
MMI_map_sz = size(MMI_map);
MMI_map_height = MMI_map_sz(1);
MMI_map_width = MMI_map_sz(2);
[max_MMI, max_MMI_idx] = max(MMI_map(:));
[MMI_map_max_y, MMI_map_max_x] = ind2sub(MMI_map_sz, max_MMI_idx);
%
confidence_logic(1) = MMI_map_max_y > size(MMI_map, 1)/10 && ...
    MMI_map_height - MMI_map_max_y > size(MMI_map, 1)/10 && ...
    MMI_map_max_x > size(MMI_map, 2)/10 && ...
    MMI_map_width - MMI_map_max_x > size(MMI_map, 2)/10;
confidence_logic(2) = MMI_map_max_y > 1 && ...
    MMI_map_height - MMI_map_max_y > 0 && ...
    MMI_map_max_x > 1 && MMI_map_width - MMI_map_max_x > 0;
%
if confidence_logic(opt)
    MMI_map_mean = mean(MMI_map(:));
    MMI_map_scaling = (max_MMI - MMI_map_mean);
    range2 = 1 ./ range .* MMI_map_scaling + MMI_map_mean;
    I2 = [];
    for i2 = 1:length(range2)
        I2 = [I2; find(MMI_map(:) > range2(i2))];
    end
    [Iy2, Ix2] = ind2sub(size(MMI_map), I2);
    distance = euc_dist(Iy2, MMI_map_max_y, Ix2, MMI_map_max_x);
    MMI_map_stddev = std(distance);
else
    MMI_map_stddev = NaN;
end
%
end
