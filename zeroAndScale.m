function zs = zeroAndScale(im,sc)%data,sc)
%if ndims(im) == 3
[h,w,bands] = size(im);
if bands > 1
data = reshape(im,[],bands);%data,[],bands);
end
if bands == 1
    data = reshape(im,[],bands);
end
%end
%if ndims(im) < 3
  %  data = im;
%end
mincol = min(data,[],1);
zs = data - mincol;
maxcol = max(zs,[],1);
%avg = mean(zeroed,1);
scale = sc./cast((maxcol),'single');%255./(2*avg);%
zs = cast(zs,'single').*scale;%repmat(scale,h*w,1);
% scaled = zeros(size(zeroed));
% for iy = 1:length(zeroed(:,1))
%     for ix = 1:length(zeroed(1,:))
%         scaled(iy,ix) = zeroed(iy,ix) * scale(ix);
%     end
% end

%scaled = cast(scaled,'uint8');
%if ndims(im) == 3
zs = reshape(zs, h,w,[]);
%end
%zeroAndScale = reshape(zeroAndScale, h,w,[]);