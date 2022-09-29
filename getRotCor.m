function [rotcor,MMI] = getRotCor(im1,im2,st,ss,angles,step)
if ~exist('angles','var')
    angles(1) = -180;
    angles(2) = 180;
end
if ~exist('step','var')
    step = 10;
end
n=0;
for rotcor = angles(1):step:angles(2)
%     tic;
    n = n+1;
    rc(n) = rotcor;
    rotim = imrotate(im1,rotcor,'crop');
    %
    [~,rmi(n),mi{n}] = getNDJHRegistration(rotim,im2,st,ss,true);
% toc;
end
[~,ind] = max(rmi);
rotcor = rc(ind);
MMI = mi{ind};
end
