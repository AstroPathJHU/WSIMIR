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
    tic;
    n = n+1;
    rc(n) = rotcor;
    rotim = imrotate(im1,rotcor,'crop');

    %[~,rmi(n),mi{n}] = getNDJHRegistration(im1(cor(2)-5:cor(2)+size(im2,1)+5,cor(1)-5:cor(1)+size(im2,2)+5),rotim,[1 1],0.1);
    [~,rmi(n),mi{n}] = getNDJHRegistration(rotim,im2,st,ss,true);
    %[~,rmi(n),mi{n}] = getNDJHRegistration(rotim,img(:,:,[1 8]),[1 1],1);
    %[~,rmi(n),mi{n}] = getNDJHRegistration(rotim(fcl(i1,2):fcl(i1,2)+h-1,fcl(i1,1):fcl(i1,1)+w-1,1),img(:,:,[1 8]),[1 1],0.01);
toc;
end
[~,ind] = max(rmi);
rotcor = rc(ind);
MMI = mi{ind};
%     %imshow(rotim((correctLoc(2)):(correctLoc(2)+h-1),(correctLoc(1)):(correctLoc(1)+w-1)))
%     %pause

%toc;
%end
%end