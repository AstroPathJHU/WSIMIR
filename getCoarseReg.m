function [wscor,rotcor,mcmi] = getCoarseReg(im1,im2,st,ss,sc,a,as)
if ~exist('a','var')
    a(1) = -180;
    a(2) = 180;
end
if ~exist('as','var')
    as = 10;
end
%[cor,cmi,mcmi] = getNDJHRegistration(im1,im2,st,ss);
[rotcor,mcmi] = getRotCor(im1,im2,st,ss,a,as);
[X,Y] = meshgrid(1:size(mcmi,2),1:size(mcmi,1));
[Xq,Yq] = meshgrid(1:sc:size(mcmi,2),1:sc:size(mcmi,1));
Vq = interp2(X,Y,mcmi,Xq,Yq,'spline');
[ma,mind] = max(Vq(:));
[iy,ix] = ind2sub(size(Vq),mind);
cl = [ix iy];%

%
wscor = cl;
%
end