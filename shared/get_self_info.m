function [cb,S] = get_self_info(img,nb,nbins)
[h,w,bands] = size(img);
if ~exist('nbins','var')
  nbins = max(ceil(sqrt(range(reshape(img,[],size(img,3))))),1);
end
if ~exist('nb','var')
    nb = 1;
end
pr = zeros(h*w,bands);
for i1 = 1:bands
   [N,~,bin] = histcounts(reshape(img(:,:,i1),[],1),nbins(i1));
   pr(:,i1) = N(bin)/length(bin);
end

I = log(1./pr);
H = pr.*I;
H(isnan(H)) = 0;
H = sum(H);
[S,si] = sort(H,'descend');
cb = si(1:nb);

end