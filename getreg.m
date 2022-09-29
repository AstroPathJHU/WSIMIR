function [rloc,ttcl,fmiDat] = getreg(ihcrs2,tcl,ifdir,mf,sb)
rloc = cell(length(mf),1);
ttcl = cell(length(mf),1);
fmiDat = cell(length(mf),1);
for i1 = 1:length(mf)
    baseFileName = mf{i1};%.name;
    fullFileName = fullfile(ifdir, baseFileName);
    tobj = Tiff(fullFileName);
    ifim = makeTifIm(tobj,8);

    
    [rloc{i1},ttcl{i1},fmiDat{i1}] = getinitreg2(ihcrs2,tcl(i1,:),ifim,sb);
end

end