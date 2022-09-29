function cropandwritehpfs(rd,wsimf,wsimdir)

if ~exist('wsimdir','dir')
    mkdir(wsimdir);
end
S = strsplit(wsimdir,'\');
suff = S{end-2};

for i1 = 1:length(rd.filename)
   
   S = strsplit(rd.filename{i1}, '_');
   fid = strjoin(S(1:end-2),'_');
   fid = [fid,'_',suff];
   
   imr = wsimf(rd.regLoc(i1,2):rd.regLoc(i1,2)+rd.h-1,...
               rd.regLoc(i1,1):rd.regLoc(i1,1)+rd.w-1,:);
   
   imwrite(imr,[wsimdir,'\',fid,'.tif']);
   
end
save([wsimdir,'\rd'],'rd')
end