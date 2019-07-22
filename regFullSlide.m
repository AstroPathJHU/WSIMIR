function regFullSlide(ihc,ifdir)


[rd,ihcf] = fullParReg(ihc,ifdir);

% IHC directory adjacent to ComponentTIFF
S = strsplit(ifdir,'\');
ihcdir = ['\',strjoin(S(1:end-2),'\'),'\IHC\HPFs\'];

% crop IHC image to HPFs corresponding to MIF HPFs. Each IHC image is saved
% as <specimen ID>_<Vectra coordinates>_IHC identical to the corresponding
% MIF HPF.
cropandwriteihc(rd,ihcf,ihcdir);                 



end