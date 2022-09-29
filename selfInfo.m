function [cb,S] = selfInfo(img,nb,nbins)
[h,w,bands] = size(img);
if ~exist('nbins','var')
  nbins = max(ceil(sqrt(range(reshape(img,[],size(img,3))))),1);%repmat(16,bands,1);% = 0:4:99;
end
if ~exist('nb','var')
    nb = 1;
end
% N = cell(bands,1);%zeros(length(edges)-1,bands);
% edges = cell(bands,1);
% bin = zeros(h*w,bands);
pr = zeros(h*w,bands);
for i1 = 1:bands
%     uni = unique(ifim(:,:,i1));
%     [S,si] = sortrows(uni);
%     [N,edges,nbin] = histcounts(uni,[S;S(end)+1]);
%     bc(si) = N;
%    pr = bc/length(bc);
%    [N{i1},edges{i1},bin(:,i1)] = histcounts(reshape(img(:,:,i1),[],1),nbins(i1));%edges);
%    bin(bin(:,i1)<1,i1) =  1;
%    pr(:,i1) = N{i1}(:,bin(:,i1))/length(bin);
   [N,~,bin] = histcounts(reshape(img(:,:,i1),[],1),nbins(i1));%histcounts(reshape(img(:,:,i1),[],1));
%    bin(bin<1) = 1;
   pr(:,i1) = N(bin)/length(bin);
% %    I = log(1./pr(pr~=0));
% % H(i1) = sum(pr.*I); 
end

I = log(1./pr);
H = pr.*I;
H(isnan(H)) = 0;
H = sum(H);
[S,si] = sort(H,'descend');
cb = si(1:nb);

end