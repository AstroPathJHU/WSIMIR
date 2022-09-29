function [cs,mmi,ccl,fmiDat] = getScaleCorrection(ihcim,ifim)
[ihch,ihcw,~] = size(ihcim);
ifscale = 1.9981018;   %% pixels/micron scale for MIF/HPF (20x)
ihcscale = 2.1739;   %% pixels/micron for IHC Hamamtsu scanner
mm = 0.02;
scstep = 0.005;
n = mm/scstep * 2 + 1;
scm = ihcscale + [reshape(repmat(-mm:scstep:mm,n,1),[],1) reshape(repmat((-mm:scstep:mm)',1,n),[],1)];
cl = zeros(length(scm),2);
mmi = zeros(length(scm),1);
miDat = cell(length(scm),1);
for i1 = 1:length(scm)
 tic ; 
    ihcrssc = imresize(ihcim,[ihch*scm(i1,2)/ihcscale,ihcw*scm(i1,1)/ihcscale]);
    [cl(i1,:),mmi(i1),miDat{i1}] = getNDJHRegistration(ihcrssc,ifim,[1 1],0.1);
 toc;
end

[~,mind] = max(mmi);
%cs = scm(mind,:);
ccl = cl(mind,:);
fmiDat = miDat{mind};

[X,Y] = meshgrid(1:n,1:n,1);
[Xq,Yq] = meshgrid(1:0.1:n,1:0.1:n,1);
Vq = interp2(X,Y,reshape(mmi,n,n),Xq,Yq,'spline');
[~,msc] = max(Vq(:));
[i1,i2] = ind2sub(size(Vq),msc);
[i3,i4] = ind2sub([n n],mind);
cs = scm(mind,:) + [(i2-i4*10) (i1-i3*10)]*scstep*0.1; %why *10*0.1??