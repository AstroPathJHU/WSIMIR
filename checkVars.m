%% checkVars
%% Created by: Joshua Doyle 
%% Edited by: Benjamin Green
%% -----------------------------------------------------------
%% Description
% part of the registration protocol for slides from different microscopes
% reads in the images to memory and gets image parameters
% -- Possible Improvement in readYCBCr2RGB for parloop reading in subset of
% main IHC image to improve read time -- use imread 'Region Property'
%% -----------------------------------------------------------
function [regData,ihcrs,ifpaths,b,h,w,scale,ihcscale] ...
    = checkVars(ihc,ifdir)
%
% pixels/u - Vectra scale (mft provided)
%
scale = 1.9981018;
%
% Number of bands in IF images
%
ncomponents = 8;
%
% pixels/u - Hamamatsu scale (mft provided)
%
ihcscale = 2.173913;
%
% get if image names
%
ifpaths = dir(fullfile(ifdir, '*component_data.tif'));
if isempty(ifpaths)
    msg = ['Error: could not find IF images in - ',ifpaths];
    error(msg)
end
%
regData = struct('filename', {{}}, 'micronLoc', {{}}, 'regLoc', {{}});
for i1 = 1:length(ifpaths)
    baseFileName = ifpaths(i1).name;
    regData.filename{i1} = baseFileName;
    C = strsplit(baseFileName,{'[',',',']'});
    regData.micronLoc{i1} = [str2double(C{2}) str2double(C{3})];
end
%
% variable for registered locations
%
b = cast(reshape(cell2mat(regData.micronLoc),2,[]),'uint32')';
%
% get IHC image and size params
%
if ~exist(ihc,'file')
    msg = ['Error: could not find IHC image - ',ihc];
    error(msg)
end
%
fprintf(1, 'Reading %s\n', ihc);
%
tic
imf = imfinfo(ihc);
level = find(ismember({imf(:).ImageDescription}, 'x20 z0'));
origh = imf(level).Height;
origw = imf(level).Width;
%
img = imread(ihc,level);
ihcrs = imresize(img,...
    [origh*scale/ihcscale,origw*scale/ihcscale]);
clear img
fprintf('           ');
toc
%
% get IF size params
%
baseFileName = ifpaths(1).name;
fullFileName = fullfile(ifdir, baseFileName);
img = imfinfo(fullFileName);
h = img.Height;
w = img.Width;
regData.h = h; %hpf height
regData.w = w; %hpf width
%
end