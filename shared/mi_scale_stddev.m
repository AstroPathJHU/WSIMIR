%% mi_scaled_stddev
% scale the stddev of the images 
%%
function scaled_stddev = mi_scale_stddev(MMI_map, MMI_map_stddev, range)
%
MMI_map_sz = size(MMI_map);
MMI_map_height = MMI_map_sz(1);
MMI_map_width = MMI_map_sz(2);
%
[Iy2, Ix2] = ind2sub(size(MMI_map), 1:numel(MMI_map));
MMI_map_height = MMI_map_height/2;
MMI_map_width = MMI_map_width/2;
distance = euc_dist(Iy2, MMI_map_height, Ix2, MMI_map_width);
MMI_map_stddev(end + 1) = std(repmat(distance, 1, length(range)));
MMI_map_stddev(isnan(MMI_map_stddev)) = max(MMI_map_stddev);
MMI_map_stddev(end + 1) = 0; 
%
scaled_stddev = 1 - zero_and_scale(MMI_map_stddev, 1);
scaled_stddev(end - 1:end) = [];
%
end