function [rloc,tcl,fmiDat,cs,mmi] = getinitreg(ihcrs2,tcl,myDir,myFiles,np,i1)
baseFileName = myFiles{np(i1)};%.name;
fullFileName = fullfile(myDir, baseFileName);
tobj = Tiff(fullFileName);
img = makeTifIm(tobj,8);
%tcl = [1 1];
[h,w,~] = size(img);
tsb = tcl;%[w h];
[tss(2),tss(1),~] = size(img);
nits = 3;                                   % Number of iterations to calculate registration
scst = 0.5/(nits-1);                        % Step for resizing images. Starts at
st = [10 5 1];
fmiDat = cell(nits,1);
rloc = cell(nits,1);
for i2 = 1%:nits
    % miTot = 0;
    sc = 0.1+scst*(i2-1);
    %     tic;
    tcr = uint32([tcl(2)-tsb(2),tcl(2)+tss(2)+tsb(2)-1,...
        tcl(1)-tsb(1),tcl(1)+tss(1)+tsb(1)-1]);
    
    if tcr(2) > size(ihcrs2,1)
        tcr(2) = size(ihcrs2,1);
    end
%     if tcr(1) > size(ihcrs2,1) - size(img,1) + 1
%         tcr(1) = size(ihcrs2,1) - size(img,1) + 1;
%     end
    if tcr(4) > size(ihcrs2,2)
        tcr(4) = size(ihcrs2,2);
    end
%     if tcr(3) > size(ihcrs2,2) - size(img,2) + 1
%         tcr(3) = size(ihcrs2,2) - size(img,2) + 1;
%     end
    tcr(tcr<=0) = 1;
    %cr
    ihcrs3 = imresize(ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:),sc);
    
    imrs = imresize(img,sc);
    [rloc{i2}(1:2),~,fmiDat{i2}] = getNDJHRegistration(ihcrs3(:,:,[1]),imrs(:,:,[1]),[1 1],0.1/sc);
    %miTot = miTot + max(fmiDat(:));
    %     toc;
    
    % tic;
    tcl(3) = double(rloc{i2}(1))/sc + tcr(3);% - tsb(1);
    tcl(4) = double(rloc{i2}(2))/sc + tcr(1);% - tsb(2);
    
    tsb(1) = round(abs(tcl(3) - tcl(1)) + 1/sc); %% search border for next registration
    tsb(2) = round(abs(tcl(4) - tcl(2)) + 1/sc);
    
    tcl(1) = tcl(3);
    tcl(2) = tcl(4);
    % toc;
    [X,Y] = meshgrid(1:size(fmiDat{i2},2),1:size(fmiDat{i2},1));
    [Xq,Yq] = meshgrid(1:sc:size(fmiDat{i2},2),1:sc:size(fmiDat{i2},1));
    Vq = interp2(X,Y,fmiDat{i2},Xq,Yq,'spline');
    [ma,mind] = max(Vq(:));
    [iy,ix] = ind2sub(size(Vq),mind);
    %cl = double(cl)/sc + [bb(1) bb(2)];
    tcl(5:6) = uint32([ix iy]) + [tcr(3) tcr(1)];%;[bb(1) bb(2)] - ss;
end
% toc;
%
i2 = nits + 1;
fsb = 10;
sc = 1;
%size(sb)
%     tic;
tcr = uint32([tcl(2)-fsb,tcl(2)+tss(2)+fsb-1,...
    tcl(1)-fsb,tcl(1)+tss(1)+fsb-1]);
tcr(tcr<=0) = 1;
if tcr(2) > size(ihcrs2,1)
    tcr(2) = size(ihcrs2,1);
end
% if tcr(2)-tcr(1)+1 < size(img,1)
%     tcr(2) = tcr(1)+size(img,2);
% end
if tcr(4) > size(ihcrs2,2)
    tcr(4) = size(ihcrs2,2);
end
% if tcr(4)-tcr(3)+1 < size(img,2)
%     tcr(4) = tcr(3)+size(img,2);
% end
ihcrs3 = ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:);
%
% ihcrs3 = imresize(ihcrs2(uint32(tcl(2)-fsb):...
%     uint32(tcl(2)+tss(2)+fsb),...
%     uint32(tcl(1)-fsb):...
%     uint32(tcl(1)+tss(1)+fsb-1),:),sc);

imrs = img;%imresize(img,sc);
%[rloc{i2}(1:2),~,fmiDat{i2}] = getNDJHRegistration(ihcrs3(:,:,[1]),imrs(:,:,[1]),[1 1],0.1);
[cs,mmi,rloc{i2}(1:2),fmiDat{i2}] = getScaleCorrection(ihcrs3(:,:,1),imrs(:,:,1));
%miTot = miTot + max(fmiDat(:));
tcl(1) = double(rloc{i2}(1))/sc + tcr(3);% - fsb;
tcl(2) = double(rloc{i2}(2))/sc + tcr(1);% - fsb;
% [X,Y] = meshgrid(1:size(fmiDat{i2},2),1:size(fmiDat{i2},1));
% [Xq,Yq] = meshgrid(1:sc:size(fmiDat{i2},2),1:sc:size(fmiDat{i2},1));
% Vq = interp2(X,Y,fmiDat{i2},Xq,Yq,'spline');
% [ma,mind] = max(Vq(:));
% [iy,ix] = ind2sub(size(Vq),mind);
% %cl = double(cl)/sc + [bb(1) bb(2)];
% tcl(5:6) = uint32([ix iy]) + [tcr(3) tcr(1)];%[bb(1) bb(2)] - ss;
end