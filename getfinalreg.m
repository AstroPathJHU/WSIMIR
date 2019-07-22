function [rloc,tcl,fmiDat] = getfinalreg(ihcrs2,tcl,myDir,mf,sb)
rloc = zeros(size(tcl));
fmiDat = cell(size(tcl,1),1);
for i1 = 1:length(mf)
    baseFileName = mf{i1};
    fullFileName = fullfile(myDir, baseFileName);
    tobj = Tiff(fullFileName);
    img = makeTifIm(tobj,8);
    %cl = [1 1];
    %[h,w,~] = size(img);
    tsb = [sb sb];%[w/2 h/2];
    [tss(2),tss(1),~] = size(img);

    tcr = uint32([tcl(i1,2)-tsb(2),tcl(i1,2)+tss(2)+tsb(2)-1,...
        tcl(i1,1)-tsb(1),tcl(i1,1)+tss(1)+tsb(1)-1]);
    tcr(tcr<=0) = 1;
    if tcr(2) > size(ihcrs2,1)
        tcr(2) = size(ihcrs2,1);
    end
    if tcr(4) > size(ihcrs2,2)
        tcr(4) = size(ihcrs2,2);
    end
    %cr
    ihcrs3 = ihcrs2(tcr(1):tcr(2),tcr(3):tcr(4),:);
    
    imrs = img;
    [rloc(i1,1:2),~,fmiDat{i1}] = getNDJHRegistration(ihcrs3(:,:,1),imrs(:,:,[1 8]),[1 1],0.1);
    %miTot = miTot + max(fmiDat(:));
    %     toc;
    
    % tic;
    tcl(i1,1) = double(rloc(i1,1)) + tcr(3);% - tsb(1);
    tcl(i1,2) = double(rloc(i1,2)) + tcr(1);% - tsb(2);
    
end
end
