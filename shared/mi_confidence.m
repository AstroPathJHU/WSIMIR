%% mi_confidence
% compute the standard deviation of 
%%
function scaled_stddev = mi_confidence(MMI_map, opt, range)
%
if ~exist('range','var')
    range = 1.25:0.25:2;
end
%
if opt == 1
    MMI_map_stddev = mi_stddev(MMI_map, 1, range);
else
    MMI_maps = MMI_map;
    MMI_map_length = length(MMI_maps);
    MMI_map_stddev = zeros(MMI_map_length, 1);
    for mi_count = 1:MMI_map_length
        MMI_map = MMI_maps{mi_count};
        MMI_map_stddev(mi_count) = mi_stddev(MMI_map, opt, range);
    end
end
%
scaled_stddev = mi_scale_stddev(MMI_map, MMI_map_stddev, range);
%
end