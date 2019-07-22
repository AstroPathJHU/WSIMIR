function [regData,ihcrs,ifpaths,b,h,w,scale,ihcscale] = checkVars(ihc,ifdir)
% pixels/u - Vectra scale (mft provided)
scale = 1.9981018;
% Number of bands in IF images
ncomponents = 8;
% pixels/u - Hamamatsu scale (mft provided)
ihcscale = 2.173913;

if ~exist('regData', 'var')
    %myDir = uigetdir('Load Componenet Tiff Directory'); %gets directory
    ifpaths = dir(fullfile(ifdir,'*component_data.tif'));
    
    regData = struct('filename',{{}},'micronLoc',{{}},'regLoc',{{}});
    for i1 = 1:length(ifpaths)
        baseFileName = ifpaths(i1).name;
%         B = strsplit(baseFileName,'_');
%         if length(B) > 3
%             if strcmp(B{4},'binary')
%                 imstr.binaryfile = baseFileName;
%             end
%             if strcmp(B{4},'composite')
%                 imstr.componentfile = baseFileName;
%             end
%             if strcmp(B{4},'phenotype')
%                 imstr.phenofile = baseFileName;
%             end
%             
%             if strcmp(B{8},'component')
%                 imstr.compositefile = baseFileName;
                regData.filename{i1} = baseFileName;
                C = strsplit(baseFileName,{'[',',',']'});
                % TODO
                % add if wholeslide || if TMA
                regData.micronLoc{i1} = [str2double(C{2}) str2double(C{3})];
                %regData.micronLoc{i1} = [str2double(C{6}) str2double(C{7})];
%             end
%         end
    end
    b = cast(reshape(cell2mat(regData.micronLoc),2,[]),'uint32')';
end

% if ~exist('miData','var')
%     load('miData');
%     mirs = reshape(miData.mmi,[],1);
%     midata2 = zeros(length(mirs),1);
%     for i1 = 1:length(mirs)
%         midata2(i1) = sum(mirs{i1}(:));
%     end
%     [ma,mind] = max(midata2);
%     [I,J] = ind2sub([9,9],mind);
% end

if ~exist('ihcrs','var')
    
    %[ihcfile,ihcpath] = uigetfile('*/*.tif','Select a full slide image for registration');
    %tobj = Tiff([ihcpath,ihcfile],'r');
    tobj = Tiff(ihc,'r');
    origh = getTag(tobj,'ImageLength');
    origw = getTag(tobj,'ImageWidth');
    ihcrs = imresize(readYCbCr2RGB(tobj),[origh*scale/ihcscale,origw*scale/ihcscale]);
    
    %ihcrs = imresize(readYCbCr2RGB(tobj),[origh*scale/miData.param.scale{I,J}(2),origw*scale/miData.param.scale{I,J}(1)]);
    
    %     tobjATP = Tiff('Z:\stitch\Hamamatsu Channel Images\M41-ATPase.tif','r');
    %     tobjHematox = Tiff('Z:\stitch\Hamamatsu Channel Images\M41-Hematoxyln.tif','r');
    %     origh = getTag(tobjATP,'ImageLength');
    %     origw = getTag(tobjATP,'ImageWidth');
    %     ihcrs(:,:,1) = imresize(read(tobjATP),[origh*scale/miData.param.scale{I,J}(2),origw*scale/miData.param.scale{I,J}(1)]);
    %     ihcrs(:,:,2) = imresize(read(tobjHematox),[origh*scale/miData.param.scale{I,J}(2),origw*scale/miData.param.scale{I,J}(1)]);
end

baseFileName = ifpaths(1).name;
fullFileName = fullfile(ifdir, baseFileName);
fprintf(1, 'Now reading %s\n', fullFileName);
tobj = Tiff(fullFileName);
img = makeTifIm(tobj,ncomponents);
[h,w,bands] = size(img);