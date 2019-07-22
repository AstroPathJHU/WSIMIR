function [cl,ul,bb,mc,bbim,rotcor] = getBB(b,ihcrs,h,w,scale,myFiles,myDir)
tic
bb(4) = size(ihcrs,1);
bb(3) = size(ihcrs,2);
bb(2) = 1;
bb(1) = 1;
ss = [0 0];
mc = cell(3,1);
%[h,w,bands] = size(img);
%tic;
minds = [max(b(:,1)) max(b(:,2)) min(b(:,1)) min(b(:,2))];
minds = round(minds*scale)-1;
ul = [round(scale*b(:,1))-minds(3) round(scale*b(:,2))-minds(4)];
bbim = zeros(minds(2)-minds(4)+h+1,minds(1)-minds(3)+w+1,'single');
%bbim = zeros(minds(2)-minds(4)+h+1,minds(1)-minds(3)+w+1,3,'uint8');

%p = zeros(size(b,1),2);
fprintf('Constructing MIF WSI');
tic;
for i2 = 1:size(b,1)
    %tic
%     bbim(ul(i2,2):ul(i2,2)+h-1,ul(i2,1):ul(i2,1) + w-1,:) = 1;
bbim(ul(i2,2):ul(i2,2)+h-1,ul(i2,1):ul(i2,1) + w-1,:) = ...
    makeTifIm(Tiff([myDir,'\',myFiles(i2).name]),1);%[],1)*mixmat,h,w,[]),555));
% toc
end
toc;
mifh = size(bbim,1);
mifw = size(bbim,2);
bb = double(bb);

rotcor = 0;
for i1 = 1:3
    tic;
    sc = 0.0001*10^i1;
    bbimrs = imresize(bbim,sc);
%toc;
cr = [bb(2)-ss(2) bb(4)+ss(2)-1 bb(1)-ss(1) bb(3)+ss(1)-1];
cr(cr<1) = 1;
% if cr(2) > size(ihcrs,1)
%     cr(2) = size(ihcrs,1);
% end
% if cr(2)-cr(1)+1 < size(bbim,1)
%     cr(2) = cr(1)+size(bbim,1)-1;
% end
% if cr(4) > size(ihcrs,2)
%     cr(4) = size(ihcrs,2);
% end
% if cr(4)-cr(3)+1 < size(bbim,2)
%     cr(4) = cr(3)+size(bbim,2)-1;
% end

ihcrs2 = imresize(ihcrs(cr(1):cr(2),cr(3):cr(4)),sc);
%ihcrs2 = imresize(ihcrs(bb(2)-ss(2):bb(4)+ss(2)-1,bb(1)-ss(1):bb(3)+ss(1)-1,1),sc);
% ihcrs2 = imbinarize(imgaussfilt(rgb2gray(imresize(ihcrs(...
%    bb(2)-ss(2):bb(4)+ss(2)-1,bb(1)-ss(1):bb(3)+ss(1)-1,:),sc)),2000*sc),'global');
stepsize = [1 1];

fprintf('Calculating initial coarse registration');
% [cl,~,mimat] = getNDJHRegistration(ihcrs2,imbinarize(imgaussfilt(double(bbimrs),500*sc)),stepsize,0.001/sc);
%[cl,~,mimat] = getNDJHRegistration(ihcrs2,bbimrs,stepsize,0.001/sc);
[cl,rotcor,mimat] = getCoarseReg(ihcrs2,bbimrs,stepsize,0.001/sc,sc,rotcor+[-0.005/sc,0.005/sc],0.001/sc);
mc{i1} = mimat;
%toc;
[X,Y] = meshgrid(1:size(mimat,2),1:size(mimat,1));
[Xq,Yq] = meshgrid(1:sc:size(mimat,2),1:sc:size(mimat,1));
Vq = interp2(X,Y,mimat,Xq,Yq,'spline');
[ma,mind] = max(Vq(:));
[iy,ix] = ind2sub(size(Vq),mind);
%cl = double(cl)/sc + [bb(1) bb(2)];
cl = [ix iy] + [bb(1) bb(2)] - ss;


ss = round(abs((cl-bb(1:2))/2));
bb = [cl(1) cl(2) cl(1)+mifw cl(2)+mifh];
% ss = [1/sc 1/sc];
toc;
end
figure,imshow(ihcrs);
hold on
plot([cl(1) cl(1)],[cl(2) cl(2)+mifh],'k');
plot([cl(1)+mifw cl(1)+mifw],[cl(2) cl(2)+mifh],'k');
plot([cl(1) cl(1)+mifw],[cl(2) cl(2)],'k');
plot([cl(1) cl(1)+mifw],[cl(2)+mifh cl(2)+mifh],'k');
scatter(cl(1)+uint32(scale*b(:,1)-minds(3)),cl(2)+uint32(scale*b(:,2)-minds(4)),5,'k');
hold off
%end