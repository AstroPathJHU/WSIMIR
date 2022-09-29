function [cl,bb,mc,rotcor,imr,rd] = getBB2(im1,im2,rd)
% size of ihc image
bb(4) = size(im1,1);
bb(3) = size(im1,2);
bb(2) = 1;
bb(1) = 1;
% sb = [0 0];
mc = cell(3,1);
mifh = size(im2,1);
mifw = size(im2,2);
bb = double(bb);
rotcor = 0;
% % n = 0.01:0.1:10;
% % sca = 0.1*tanh(n);
% % figure,plot(sca)
% % sca = exp(9.*n)./(exp(9.*n)+1)-0.9;
s = [0,2000,400,200,100,40];%250,62.5,41.67,31.25,15.625,7.8125];%100,];
a =    [180,5,1,0.2,0.08,0];%,0.2,0.08,0.06,0];
nits = [361,21,15,11,7,1];%,7,5,3,1];
sca =  [0.001,0.005,0.01,0.02,0.05,0.1];%0.004,0.016,0.024,0.032,0.064,0.128,0.256];
subs = [1,1,1,1,0.5,0.1];
i1 = 1;
imr = im1;
while i1 <= length(sca) %4%for i1 = 1%:3
    tic;
    sb = [s(i1) s(i1)];
    sc = sca(i1);%0.0001*10^i1;
    % Add smoothing Gauss radius ~2x rescaling
    %bbimrs = imresize(imgaussfilt(bbim,(2/sc-1)/4),sc);
    bbimrs = imresize(im2(:,:,1),sc);
    cr = [bb(2)-sb(2) bb(4)+sb(2)-1 bb(1)-sb(1) bb(3)+sb(1)-1];
    cr(cr<1) = 1;
    if cr(2)>size(imr,1)
        cr(2) = size(imr,1);
    end
    if cr(4)>size(imr,2)
        cr(4) = size(imr,2);
    end
    ihcrs2 = imresize(imr(cr(1):cr(2),cr(3):cr(4),1),sc);
    if size(ihcrs2,1) <= size(bbimrs,1)
        cr = [bb(2)-sb(2)-1/sc bb(4)+sb(2)-1+1/sc bb(1)-sb(1) bb(3)+sb(1)-1];
        cr(cr<1) = 1;
        if cr(2)>size(imr,1)
            cr(2) = size(imr,1);
        end
        if cr(4)>size(imr,2)
            cr(4) = size(imr,2);
        end
        ihcrs2 = imresize(imr(cr(1):cr(2),cr(3):cr(4),1),sc);
    end
    if size(ihcrs2,2) <= size(bbimrs,2)
        cr = [bb(2)-sb(2) bb(4)+sb(2)-1 bb(1)-sb(1)-1/sc bb(3)+sb(1)-1+1/sc];
        cr(cr<1) = 1;
        if cr(2)>size(imr,1)
            cr(2) = size(imr,1);
        end
        if cr(4)>size(imr,2)
            cr(4) = size(imr,2);
        end
        ihcrs2 = imresize(imr(cr(1):cr(2),cr(3):cr(4),1),sc);
    end
    %     ihcrs2 = imresize(imgaussfilt(ihcrs(cr(1):cr(2),cr(3):cr(4)),...
    %                                   (2/sc-1)/4),sc);
    st = [1 1];
    %
    fprintf('Calculating initial coarse registration \n');
    fprintf(['Number of iterations: ',int2str(nits(i1)),'\n']);
    
    %     as = ((a/sc)*2+1)/(1/sc);
    rc = linspace(-a(i1),a(i1),nits(i1));
    %     ar = rotcor+[-a/sc,a/sc];%-abs(rotdelta)+abs(rotdelta)
%     sub = 0.001/sc * i1;
    sub = subs(i1);
    
    [cl,rotdelta,mimat] = getRigidReg(ihcrs2,bbimrs,st,sub,rc);
    rotcor = rotcor + rotdelta;
    imr = imrotate(imr,rotdelta);
    mc{i1} = mimat;

    if size(mimat) > 1
        [X,Y] = meshgrid(1:size(mimat,2),1:size(mimat,1));
        [Xq,Yq] = meshgrid(1:sc:size(mimat,2),1:sc:size(mimat,1));
        Vq = interp2(X,Y,mimat,Xq,Yq,'spline');
        [~,mind] = max(Vq(:));
        [iy,ix] = ind2sub(size(Vq),mind);
        
        cl = [ix iy] + cr([3,1]);%[bb(1) bb(2)] - ss;
    else
        cl = cl/sc + cr([3,1]);
    end
   
%     if i1 > 1
%     if rotdelta > 0
%         cl(2) = cl(2) - (cr(4)-cr(3))*sind(abs(rotdelta));
%     end
%     if rotdelta < 0
%         cl(1) = cl(1) - (cr(2)-cr(1))*sind(abs(rotdelta));
%     end
%     end
    %round(abs((cl-bb(1:2))));
    bb = [cl(1) cl(2) cl(1)+mifw cl(2)+mifh];
    %
     i1 = i1 + 1;
    % It is assumed  that the IHC image
    % is larger than the IF image, however, occasionally there may be one
    % edge of the IHC image that appears cropped. If the correct location
    % is at the edge of the slide, we pad that edge and continue
    % registration.
    if cl(1) <= 1
%         xq = -Xq(iy,end):Xq(iy,end)/size(Xq,1):Xq(iy,end);
%         F = griddedInterpolant(Xq(iy,:),Vq(iy,:),'pchip','pchip');
%         vq = F(xq);
%         [~,mvq] = max(vq);
        p = 1/sc;%abs(round(xq(mvq)/sc) * 2);
        im1 = padarray(im1,[0,p],0,'pre');
        cl(1) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding ={[0,p],0,'pre'};
        i1 = 1;
        sb = [0 0];
        bb(4) = size(im1,1);
        bb(3) = size(im1,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(1) >= size(imr,2) - mifw + 1
%         xq = 1:Xq(iy,end)/size(Xq,1):2*Xq(iy,end);
%         F = griddedInterpolant(Xq(iy,:),Vq(iy,:),'pchip','pchip');
%         vq = F(xq);
%         [~,mvq] = max(vq);
        p = 1/sc;%abs(round(xq(mvq)/sc) * 2);
        im1 = padarray(im1,[0,p],0,'post');
        cl(1) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[0,p],0,'post'};
        i1 = 1;
        sb = [0 0];
        bb(4) = size(im1,1);
        bb(3) = size(im1,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(2) <= 1
%         yq = -Yq(end,ix):Yq(end,ix)/size(Yq,1):Yq(end,ix);
%         F = griddedInterpolant(Yq(:,ix),Vq(:,ix),'pchip','pchip');
%         vq = F(yq);
%         [~,mvq] = max(vq);
        p = 1/sc;%abs(round(yq(mvq)/sc) * 2);
        im1 = padarray(im1,p,0,'pre');
        cl(2) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[p,0],0,'pre'};
        i1 = 1;
        sb = [0 0];
        bb(4) = size(im1,1);
        bb(3) = size(im1,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(2) >= size(imr,1) - mifh + 1
%         yq = 1:Yq(end,ix)/size(Yq,1):2*Yq(end,ix);
%         F = griddedInterpolant(Yq(:,ix),Vq(:,ix),'pchip','pchip');
%         vq = F(yq);
%         [~,mvq] = max(vq);
        p = 1/sc;%abs(round(yq(mvq)/sc) * 2);
        im1 = padarray(im1,p,0,'post');
        cl(2) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[p,0],0,'post'};
        i1 = 1;
        sb = [0 0];
        bb(4) = size(im1,1);
        bb(3) = size(im1,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    
    toc;
end
%{
% figure,imshow(ihcrs);lear im1
hold on
plot([cl(1) cl(1)],[cl(2) cl(2)+mifh],'k');
plot([cl(1)+mifw cl(1)+mifw],[cl(2) cl(2)+mifh],'k');
plot([cl(1) cl(1)+mifw],[cl(2) cl(2)],'k');
plot([cl(1) cl(1)+mifw],[cl(2)+mifh cl(2)+mifh],'k');
scatter(cl(1)+uint32(scale*b(:,1)-minds(3)),cl(2)+uint32(scale*b(:,2)-minds(4)),5,'k');
hold off
%}
end