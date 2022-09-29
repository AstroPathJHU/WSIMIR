%%
function regFullSlide(wsimpath,tiledir)
%
tic
wsimpath2 = replace(wsimpath,'.ndpi','.tif');
if ~exist(wsimpath2,'file')
    command = ['\\bki05\n$\bgcode2\ndpi2tiff.exe ',wsimpath];
    try
        system(command)
    catch
        error(['Error converting npdi to tif for ',wsimpath])
    end
end
%
toc
[rd,wsimf] = fullParReg2(wsimpath2,tiledir);

% IHC directory adjacent to ComponentTIFF
S = strsplit(wsimpath,'\');
wsimdir = ['\',strjoin(S(1:end-1),'\'),'\HPFs\'];
% crop IHC image to HPFs corresponding to MIF HPFs. Each IHC image is saved
% as <Specimen ID>_<Vectra coordinates>_<WSI Image Type>.tif in parallel to the corresponding
% MIF HPF.
cropandwritehpfs(rd,wsimf,wsimdir);                 
toc
end