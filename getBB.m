function [cl,ul,bb,mc,bbim,rotcor,ihcrs,rd] = getBB(b,ihcrs,h,w,scale,myFiles,myDir,rd)
% size of ihc image
bb(4) = size(ihcrs,1);
bb(3) = size(ihcrs,2);
bb(2) = 1;
bb(1) = 1;
ss = [0 0];
mc = cell(3,1);
minds = [max(b(:,1)) max(b(:,2)) min(b(:,1)) min(b(:,2))];
minds = round(minds*scale)-1;
ul = [round(scale*b(:,1))-minds(3) round(scale*b(:,2))-minds(4)];
bbim = zeros(minds(2)-minds(4)+h+1,minds(1)-minds(3)+w+1,1,'single');
fprintf('Constructing MIF WSI \n');
% tic;
for i2 = 1:size(b,1)
    bbim(ul(i2,2):ul(i2,2)+h-1,ul(i2,1):ul(i2,1) + w-1,:) = ...
        makeTifIm(Tiff([myDir,'\',myFiles(i2).name]),1);
end
fprintf('           ');
toc;
mifh = size(bbim,1);
mifw = size(bbim,2);
bb = double(bb);
rotcor = 0;
ro = 0;
rotdelta = 0;
i1 = 1;
while i1 < 4%for i1 = 1%:3
%     tic;
    sc = 0.0001*10^i1;
    % Add smoothing Gauss radius ~2x rescaling
    %bbimrs = imresize(imgaussfilt(bbim,(2/sc-1)/4),sc);
    bbimrs = imresize(uint8(zeroAndScale(bbim(:,:,1),555)),sc);
    cr = [bb(2)-ss(2) bb(4)+ss(2)-1 bb(1)-ss(1) bb(3)+ss(1)-1];
    cr(cr<1) = 1;
    if cr(2)>size(ihcrs,1)
        cr(2) = size(ihcrs,1);
    end
    if cr(4)>size(ihcrs,2)
        cr(4) = size(ihcrs,2);
    end
    ihcrs2 = imresize(ihcrs(cr(1):cr(2),cr(3):cr(4),1),sc);
    if size(ihcrs2,1) <= size(bbimrs,1)
        cr = [bb(2)-ss(2)-1/sc bb(4)+ss(2)-1+1/sc bb(1)-ss(1) bb(3)+ss(1)-1];
        cr(cr<1) = 1;
        if cr(2)>size(ihcrs,1)
            cr(2) = size(ihcrs,1);
        end
        if cr(4)>size(ihcrs,2)
            cr(4) = size(ihcrs,2);
        end
        ihcrs2 = imresize(ihcrs(cr(1):cr(2),cr(3):cr(4),1),sc);
    end
    if size(ihcrs2,2) <= size(bbimrs,2)
        cr = [bb(2)-ss(2) bb(4)+ss(2)-1 bb(1)-ss(1)-1/sc bb(3)+ss(1)-1+1/sc];
        cr(cr<1) = 1;
        if cr(2)>size(ihcrs,1)
            cr(2) = size(ihcrs,1);
        end
        if cr(4)>size(ihcrs,2)
            cr(4) = size(ihcrs,2);
        end
        ihcrs2 = imresize(ihcrs(cr(1):cr(2),cr(3):cr(4),1),sc);
    end
    %     ihcrs2 = imresize(imgaussfilt(ihcrs(cr(1):cr(2),cr(3):cr(4)),...
    %                                   (2/sc-1)/4),sc);
    stepsize = [1 1];
    %
    fprintf('Calculating initial coarse registration \n');
    fprintf(['Number of iterations: ',int2str(1/sc+1),'\n']);
    
    [cl,rotcor,mimat] = getCoarseReg(ihcrs2,bbimrs,stepsize,0.001/sc,sc,...
        rotcor+[-0.005/sc-abs(rotdelta),0.005/sc+abs(rotdelta)],...
        ((0.005/sc+abs(rotdelta))*2+1)/(1/sc));%0.001/sc*max(1,abs(rotdelta)));
    rotdelta = rotcor - ro;
    ro = rotcor;
    mc{i1} = mimat;
    if size(mimat) > 1
    [X,Y] = meshgrid(1:size(mimat,2),1:size(mimat,1));
    [Xq,Yq] = meshgrid(1:sc:size(mimat,2),1:sc:size(mimat,1));
    Vq = interp2(X,Y,mimat,Xq,Yq,'spline');
    [ma,mind] = max(Vq(:));
    [iy,ix] = ind2sub(size(Vq),mind);
    
    cl = [ix iy] + [bb(1) bb(2)] - ss;
    else
        cl = cl/sc + cr([3,1]);
    end
    i1 = i1 + 1;
    ss = round(abs((cl-bb(1:2))));
    bb = [cl(1) cl(2) cl(1)+mifw cl(2)+mifh];
    %
    % It is assumed  that the IHC image
    % is larger than the IF image, however, occasionally there may be one
    % edge of the IHC image that appears cropped. If the correct location
    % is at the edge of the slide, we pad that edge and continue
    % registration.
    if cl(1) <= 1
        xq = -Xq(iy,end):Xq(iy,end)/size(Xq,1):Xq(iy,end);
        F = griddedInterpolant(Xq(iy,:),Vq(iy,:),'pchip','pchip');
        vq = F(xq);
        [~,mvq] = max(vq);
        p = abs(round(xq(mvq)/sc) * 2);
        ihcrs = padarray(ihcrs,[0,p],0,'pre');
        cl(1) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding ={[0,p],0,'pre'};
        i1 = 1;
        ss = [0 0];
        bb(4) = size(ihcrs,1);
        bb(3) = size(ihcrs,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(1) >= size(ihcrs,2) - mifw + 1
        xq = 1:Xq(iy,end)/size(Xq,1):2*Xq(iy,end);
        F = griddedInterpolant(Xq(iy,:),Vq(iy,:),'pchip','pchip');
        vq = F(xq);
        [~,mvq] = max(vq);
        p = abs(round(xq(mvq)/sc) * 2);
        ihcrs = padarray(ihcrs,[0,p],0,'post');
        cl(1) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[0,p],0,'post'};
        i1 = 1;
        ss = [0 0];
        bb(4) = size(ihcrs,1);
        bb(3) = size(ihcrs,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(2) <= 1
        yq = -Yq(end,ix):Yq(end,ix)/size(Yq,1):Yq(end,ix);
        F = griddedInterpolant(Yq(:,ix),Vq(:,ix),'pchip','pchip');
        vq = F(yq);
        [~,mvq] = max(vq);
        p = abs(round(yq(mvq)/sc) * 2);
        ihcrs = padarray(ihcrs,p,0,'pre');
        cl(2) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[p,0],0,'pre'};
        i1 = 1;
        ss = [0 0];
        bb(4) = size(ihcrs,1);
        bb(3) = size(ihcrs,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    if cl(2) >= size(ihcrs,1) - mifh + 1
        yq = 1:Yq(end,ix)/size(Yq,1):2*Yq(end,ix);
        F = griddedInterpolant(Yq(:,ix),Vq(:,ix),'pchip','pchip');
        vq = F(yq);
        [~,mvq] = max(vq);
        p = abs(round(yq(mvq)/sc) * 2);
        ihcrs = padarray(ihcrs,p,0,'post');
        cl(2) = p/2;
        warning('MIF registrered at edge of IHC image and the IHC image has been padded')
        rd.IHC_Padding = {[p,0],0,'post'};
        i1 = 1;
        ss = [0 0];
        bb(4) = size(ihcrs,1);
        bb(3) = size(ihcrs,2);
        bb(2) = 1;
        bb(1) = 1;
    end
    
    toc;
end
%{
figure,imshow(ihcrs);
hold on
plot([cl(1) cl(1)],[cl(2) cl(2)+mifh],'k');
plot([cl(1)+mifw cl(1)+mifw],[cl(2) cl(2)+mifh],'k');
plot([cl(1) cl(1)+mifw],[cl(2) cl(2)],'k');
plot([cl(1) cl(1)+mifw],[cl(2)+mifh cl(2)+mifh],'k');
scatter(cl(1)+uint32(scale*b(:,1)-minds(3)),cl(2)+uint32(scale*b(:,2)-minds(4)),5,'k');
hold off
%}
end