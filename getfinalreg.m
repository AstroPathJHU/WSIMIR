function [rloc,tcl,fmiDat] = getfinalreg(ihcrs2,tcl,ifdir,mf,sb)
rloc = zeros(size(tcl));
fmiDat = cell(size(tcl,1),1);
for i1 = 1:length(mf)
    tic;
    baseFileName = mf{i1};
    fullFileName = fullfile(ifdir, baseFileName);
    tobj = Tiff(fullFileName);
    img = makeTifIm(tobj,8);
    %cl = [1 1];
    %[h,w,~] = size(img);
    tsb = sb;%[sb sb];%[w/2 h/2];
    [tss(2),tss(1),~] = size(img);
    
    sctep = 0.1;
    %     for i2 = 1:10
    done = false;
    checked = false;
    i2 = 1;
    while ~done
        % for i2 = [1 5 10]
        tic;
        sc = 0.1 + (i2-1)*sctep;
        tcr = uint32([tcl(i1,2)-tsb(2),tcl(i1,2)+tss(2)+tsb(2)-1,...
            tcl(i1,1)-tsb(1),tcl(i1,1)+tss(1)+tsb(1)-1]);
        tcr(tcr<=0) = 1;
        %     if tcr(1) <= 0
        %         tcr(1) = 1;
        %         tcl(i1,2) = tcl(i1,2) - (tcl(i1,2)-tsb(2))
        if tcr(1) > size(ihcrs2,1) - size(img,1) + 1
           tcr(1) =  size(ihcrs2,1) - size(img,1) + 1;
        end
        if tcr(2) > size(ihcrs2,1)
            tcr(2) = size(ihcrs2,1);
        end
        if tcr(3) > size(ihcrs2,2) - size(img,2) + 1
           tcr(3) =  size(ihcrs2,2) - size(img,2) + 1;
        end
        if tcr(4) > size(ihcrs2,2)
            tcr(4) = size(ihcrs2,2);
        end
        %cr
        ihcrs3 = imresize(ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:),sc);        
        imrs = imresize(img,sc);
        
%         imtest = imresize(ihcrs3(tcl(i1,2)-tcr(1)+1:tcl(i1,2)-tcr(1)+tss(2) ...
%                                 ,tcl(i1,1)-tcr(3)+1:tcl(i1,1)-tcr(3)+tss(1),:),sc);
% %         imtest = ihcrs3(1:size(imrs,1),1:size(imrs,2),:);
%         cb = micomp(imtest,imrs(:,:,1:7),2);
        cb(:,1) = selfInfo(double(ihcrs3),2);
        cb(:,2) = selfInfo(imrs(:,:,1:7),2);
        [rloc(i1,1:2),~,fmiDat{i1}{i2}] = getNDJHRegistration(ihcrs3(:,:,cb(:,1)),imrs(:,:,cb(:,2)),[1 1],1);
        %miTot = miTot + max(fmiDat(:));
        %     toc;
        
        % tic;
        if size(fmiDat{i1}{i2}) > 1
        [X,Y] = meshgrid(1:size(fmiDat{i1}{i2},2),1:size(fmiDat{i1}{i2},1));
        [Xq,Yq] = meshgrid(1:sc:size(fmiDat{i1}{i2},2),1:sc:size(fmiDat{i1}{i2},1)); % can go to sub pixel
        Vq = interp2(X,Y,fmiDat{i1}{i2},Xq,Yq,'spline');
        [~,mind] = max(Vq(:));
        [iy,ix] = ind2sub(size(Vq),mind);
        %cl = double(cl)/sc + [bb(1) bb(2)];
        tcl(i1,3:4) = uint32([ix iy]) + [tcr(3) tcr(1)];
        else
                tcl(i1,3) = double(rloc(i1,1)/sc) + tcr(3);% - tsb(1);
                tcl(i1,4) = double(rloc(i1,2)/sc) + tcr(1);% - tsb(2);
        end
        
        conf = miconf(fmiDat{i1}{i2});
        
        if conf >= 0.9
            checked = true;
            if i2 == 10
                tcl(i1,1:2) = tcl(i1,3:4);
                done = true;
            end
            if i2 == 5
                i2 = 10;%i2 + 1;
                tsb = [2 2];%ceil(abs(tcl(i1,3:4) - tcl(i1,1:2)) + 1/sc);
                tcl(i1,1:2) = tcl(i1,3:4);
            end
            if i2 == 1
                i2 = 5;%i2 + 1;
                tsb = [10 10];%ceil(abs(tcl(i1,3:4) - tcl(i1,1:2)) + 1/sc);
                tcl(i1,1:2) = tcl(i1,3:4);
            end
        end
        if conf < 0.9
            if ~checked
                tsb(:) = tsb(:)*2;
                tcl(i1,1:2) = tcl(i1,3:4);
                %             i2 = 1;
            end
            if checked
                if i2 == 10
                    tcl(i1,1:2) = tcl(i1,3:4);
                    done = true;
                end
                if i2 == 5
                    i2 = 10;
                    tsb = [2 2];
                    %                     tsb = 2*round(abs(tcl(i1,3:4) - tcl(i1,1:2)) + 1/sc);
                    tcl(i1,1:2) = tcl(i1,3:4);
                end
                if i2 == 1
                    i2 = 5;
                    tsb = [10 10];
                    %                     tsb = 2*round(abs(tcl(i1,3:4) - tcl(i1,1:2)) + 1/sc);
                    tcl(i1,1:2) = tcl(i1,3:4);
                end
            end
            checked = true;
        end
        
        
        %         tsb = round(abs(tcl(i1,3:4) - tcl(i1,1:2)) + 1/sc + 1);
        %         tcl(i1,1:2) = tcl(i1,3:4);
        toc;
    end
end
end
