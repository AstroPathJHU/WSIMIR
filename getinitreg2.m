function [rloc,tcl,fmiDat,cs,mmi] = getinitreg2(ihcrs2,tcl,img,sb)

%tcl = [1 1];
[h,w,~] = size(img);
tsb = sb;%tcl;%[w h];
[tss(2),tss(1),~] = size(img);
nits = 10;                                   % Number of iterations to calculate registration
scst = 0.1;%0.75/(nits-1);                        % Step for resizing images. Starts at
%st = [10 5 1];
fmiDat = cell(nits,1);
rloc = cell(nits,1);
tic;
% cb(:,1) = selfInfo(ihcrs2,2)
% cb(:,2) = selfInfo(img,2)
% for i2 = 1:nits
i2 = 1;
done = false;
checked = false;
while ~done
    tic;
    % miTot = 0;
    sc = 0.1+scst*(i2-1);
    %     tic;
    tcr = uint32([tcl(2)-tsb(2),tcl(2)+tss(2)+tsb(2),...
        tcl(1)-tsb(1),tcl(1)+tss(1)+tsb(1)]);
    
    if tcr(2) > size(ihcrs2,1)
        tcr(2) = size(ihcrs2,1);
    end
    if tcr(4) > size(ihcrs2,2)
        tcr(4) = size(ihcrs2,2);
    end
    tcr(tcr<=0) = 1;
    %cr
    
    %     ihcrs3 = imresize(imgaussfilt(ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:),...
    %                                   (2/sc-1)/4),sc);
    ihcrs3 = imresize(ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:),sc);
    %     imrs = imresize(imgaussfilt(img,(2/sc-1)/4),sc);
    imrs = imresize(img,sc);
%     imtest = ihcrs3(1:size(imrs,1),1:size(imrs,2),:);
%     
%     cb = micomp(imtest,imrs,2)
    cb(:,1) = selfInfo(double(ihcrs3),2);
    cb(:,2) = selfInfo(imrs(:,:,1:7),2);
    [rloc{i2}(1:2),~,fmiDat{i2}] = getNDJHRegistration(ihcrs3(:,:,cb(:,1)),imrs(:,:,cb(:,2)),[1 1],1);
    %[rloc{i2}(1:2),~,fmiDat{i2}] = getNDJHRegistration(ihcrs3,imrs,[1 1],1,true);
    
    %     toc;
    if size(fmiDat{i2}) > 1
    [X,Y] = meshgrid(1:size(fmiDat{i2},2),1:size(fmiDat{i2},1));
    [Xq,Yq] = meshgrid(1:sc:size(fmiDat{i2},2),1:sc:size(fmiDat{i2},1)); % can go to sub pixel
    Vq = interp2(X,Y,fmiDat{i2},Xq,Yq,'spline');
    [~,mind] = max(Vq(:));
    [iy,ix] = ind2sub(size(Vq),mind);
    %cl = double(cl)/sc + [bb(1) bb(2)];
    tcl(3:4) = uint32([ix iy]) + [tcr(3) tcr(1)];%;[bb(1) bb(2)] - ss;
    else
              tcl(3) = double(rloc{i2}(1))/sc + tcr(3);
        tcl(4) = double(rloc{i2}(2))/sc + tcr(1);
    end
    toc;
    % tic;
    %     tcl(3) = double(rloc{i2}(1))/sc + tcr(3);% - tsb(1);
    %     tcl(4) = double(rloc{i2}(2))/sc + tcr(1);% - tsb(2);
    
    %     tsb(1) = round(abs(tcl(3) - tcl(1)) + 10)%; %% search border for next registration
    %     tsb(2) = round(abs(tcl(4) - tcl(2)) + 10)%;
    %
    conf = miconf(fmiDat{i2});
    
    if conf >= 0.9
        checked = true;
        if i2 == 10
            tcl(1) = tcl(3);
            tcl(2) = tcl(4);
            done = true;
        end
        if i2 == 5
            i2 = 10;
            tsb(1:2) = [5 5];%ceil(abs(tcl(3) - tcl(1)) + 1/sc)*2; %% search border for next registration
            %             tsb(2) = ceil(abs(tcl(4) - tcl(2)) + 1/sc)*2;
            tcl(1:2) = tcl(3:4);
            %             tcl(2) = tcl(4);
        end
        if i2 == 1
            i2 = 5;
            tsb(1:2) = [20 20];%ceil(abs(tcl(3) - tcl(1)) + 1/sc)*2; %% search border for next registration
            %             tsb(2) = ceil(abs(tcl(4) - tcl(2)) + 1/sc)*2;
            tcl(1:2) = tcl(3:4);
            %             tcl(2) = tcl(4);
        end
    end
    if conf < 0.9
        if ~checked
%             i2 = 1;
            tsb = [w h];
%             tcl(1) = tcl(3);
%             tcl(2) = tcl(4);
            %             i2 = 1;
        end
        if checked
            if i2 == 10
                tcl(1) = tcl(3);
                tcl(2) = tcl(4);
                done = true;
            end
            if i2 == 5
                tsb(1:2) = [5 5];
                %                 tsb(2) = 10;
                tcl(1) = tcl(3);
                tcl(2) = tcl(4);
                i2 = 10;
            end
            if i2 == 1
                tsb(1:2) = [20 20];
                %                 tsb(2) = 10;
                tcl(1) = tcl(3);
                tcl(2) = tcl(4);
                i2 = 5;
            end
        end
        checked = true;
    end
    
    % end
    
    %     tcl(1) = tcl(3);
    %     tcl(2) = tcl(4);
    % toc;
    %     [X,Y] = meshgrid(1:size(fmiDat{i2},2),1:size(fmiDat{i2},1));
    %     [Xq,Yq] = meshgrid(1:sc:size(fmiDat{i2},2),1:sc:size(fmiDat{i2},1)); % can go to sub pixel
    %     Vq = interp2(X,Y,fmiDat{i2},Xq,Yq,'spline');
    %     [ma,mind] = max(Vq(:));
    %     [iy,ix] = ind2sub(size(Vq),mind);
    %     %cl = double(cl)/sc + [bb(1) bb(2)];
    %     tcl(5:6) = uint32([ix iy]) + [tcr(3) tcr(1)];%;[bb(1) bb(2)] - ss;
    toc;
end
toc;
%
%
% i2 = nits + 1;
% fsb = 10;
% sc = 1;
%
% tcr = uint32([tcl(2)-fsb,tcl(2)+tss(2)+fsb-1,...
%     tcl(1)-fsb,tcl(1)+tss(1)+fsb-1]);
% tcr(tcr<=0) = 1;
% if tcr(2) > size(ihcrs2,1)
%     tcr(2) = size(ihcrs2,1);
% end
%
% if tcr(4) > size(ihcrs2,2)
%     tcr(4) = size(ihcrs2,2);
% end
%
% ihcrs3 = ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:);
%
% imrs = img;%imresize(img,sc);
%
% [cs,mmi,rloc{i2}(1:2),fmiDat{i2}] = getScaleCorrection(ihcrs3(:,:,[1]),imrs(:,:,[8]));
%
% tcl(1) = double(rloc{i2}(1))/sc + tcr(3);% - fsb;
% tcl(2) = double(rloc{i2}(2))/sc + tcr(1);% - fsb;
cs = [2.17,2.17];%ihcscale,ihcscale];
mmi = [];
end