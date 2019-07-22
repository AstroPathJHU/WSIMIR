function cropandwriteihc(rd,ihcf,ihcdir)

if ~exist('ihcdir','dir')
    mkdir(ihcdir);
end


for i1 = 1:length(rd.filename)
   
   S = strsplit(rd.filename{i1}, '_');
   fid = strjoin(S(1:end-2),'_');
   fid = [fid,'_','IHC'];
   
   ihcr = ihcf(rd.regLoc(i1,2):rd.regLoc(i1,2)+rd.h-1,...
               rd.regLoc(i1,1):rd.regLoc(i1,1)+rd.w-1,:);
   
   imwrite(ihcr,[ihcdir,'\',fid,'.tif']);
    
end