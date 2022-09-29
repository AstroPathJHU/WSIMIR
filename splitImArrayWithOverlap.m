% This function takes an image object, ichrs, and splits it into a cell of
% arrays with overlap ol/2. This is primarily used for splitting a large
% image for parallel processing. The overlap is necessary for searching
% algorithms - ol would then be on the order of the size of the objects
% that are being searched for. For image registration this would be the
% dimensions of the floating image where ihcrs is the reference image.
% 
% @param
% ihcrs - Image object to be split
% gn - the gridding, ie how many regions in each direction as [d1 d2]
% ol - the overlap in each direction as [d1 d2].
% band - which band(s) to include in the final image cell.

function [ihcrop,pts] = splitImArrayWithOverlap(ihcrs,gn,ol,band,histc)
% histsc = 16;
ssw = size(ihcrs,2)/gn(2);
ssh = size(ihcrs,1)/gn(1);
ihcrop = cell(gn(1),gn(2));
pts = zeros(gn(1)*gn(2),4);
tic
for i1 = 1:gn(1)
    for i2 = 1:gn(2)
        pts(sub2ind([gn(1) gn(2)],i1,i2),:) = ...
            [uint32((i1-1)*ssh+1) uint32(i1*ssh) ...
             uint32((i2-1)*ssw+1) uint32(i2*ssw)];
    end
end
pts = uint32(double(pts) + repmat(double([-ol(1)/2 ol(1)/2 -ol(2)/2 ol(2)/2]),size(pts,1),1));
pts(pts<1) = 1;
pts(pts(:,2)>size(ihcrs,1),2)=size(ihcrs,1);
pts(pts(:,4)>size(ihcrs,2),4)=size(ihcrs,2);
pts = uint32(pts);
if exist('histsc','var')
ihcrs = uint8(zeroAndScale(ihcrs,histsc));
end
for i1 = 1:gn(1)
    for i2 = 1:gn(2)
        i3 = sub2ind([gn(1) gn(2)],i1,i2);
        ihcrop{i1,i2} = ihcrs(pts(i3,1):pts(i3,2),pts(i3,3):pts(i3,4),band);
    end
end
% 
end