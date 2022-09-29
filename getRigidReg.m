function [c,rotcor,MMI] = getRigidReg(im1,im2,st,ss,rc)

if ~exist('rc','var')
    rc =-180:1:180;
end

% tc = round((size(im1)-size(im2))/2);

cl = zeros(length(rc),2);
rmi = zeros(length(rc),1);
mi = cell(length(rc),1);
for i1 = 1:length(rc)
% tic
    rotim = imrotate(im1,rc(i1));
%     cr = round((size(rotim) - size(im1)))/2;
%     rim = rotim(cr(1):end-cr(1),cr(2):end-cr(2));
    [cl(i1,:),rmi(i1),mi{i1}] = getNDJHRegistration(rotim,im2,st,ss,true);
% toc
     
end
[~,ind] = max(rmi);
c = cl(ind,:);
rotcor = rc(ind);
MMI = mi{ind};
end
