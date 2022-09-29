function [bbim,ul] = stitchTiles(b,scale,tiledir,tilepaths,nbands)   

if ~exist('nbands','var')
   nbands = 1; 
end
baseFileName = tilepaths(1).name;
    fullFileName = fullfile(tiledir, baseFileName);
    img = imfinfo(fullFileName);
    h = img.Height;
    w = img.Width;
%     regData.h = h; %hpf height
%     regData.w = w; %hpf width
    M = [max(b,[],1) min(b,[],1)];
    M = round(M*scale)-1;
    ul = [round(scale*b(:,1))-M(3) round(scale*b(:,2))-M(4)];
    bbim = zeros(M(2)-M(4)+h+1,M(1)-M(3)+w+1,nbands,'single');
    fprintf('Constructing MIF WSI \n');
    tic;
    for i2 = 1:size(b,1)
        bbim(ul(i2,2):ul(i2,2)+h-1,ul(i2,1):ul(i2,1)+w-1,:) = ...
            makeTifIm(Tiff([tiledir,'\',tilepaths(i2).name]),nbands);
    end
    fprintf('           ');
    toc;
end