%% arrage_tiles
%% Description
% perform a reading of the component images and arrange them in a grid
% according to the x and y coodinates in the names
%% Input
% image_info: object from get_image_info
% nbands: number of component layers to read in for the stiching with
% a default of 1
%% -----------------------------
function image_data = arrange_tiles(image_data, meta)
%
if ~strcmp(image_data.meta.type, 'TILE')
    return
end
%
images = struct([]);
folders = {image_data.meta.image_names(:).folder};
names = {image_data.meta.image_names(:).name};
levels = image_data.meta.ncomponents;
nbands = meta.opts.nbands;
%
fprintf('Reading TILE image %s \n', folders{1});
tic
%
% read the images in
%
parfor i1 = 1:length(image_data.meta.image_names)
    images(i1).image = read_component_images(...
        fullfile(folders{i1}, names{i1}), levels, nbands);
    images(i1).name = names{i1};
end
%
% put the images in the right places
%
x_limits = [max([image_data.meta.image_names(:).x_coord]), ...
    min([image_data.meta.image_names(:).x_coord])];
%
y_limits = [max([image_data.meta.image_names(:).y_coord]), ...
    min([image_data.meta.image_names(:).y_coord])];
%
bb = [x_limits(1), y_limits(1), x_limits(2), y_limits(2)];
bb = round(bb * image_data.meta.scale) - 1;
%
ul = [round(image_data.meta.scale * ...
    [image_data.meta.image_names(:).x_coord]) - bb(3); ...
    round(image_data.meta.scale * ...
    [image_data.meta.image_names(:).y_coord]) - bb(4)]';
%
bbim = zeros(bb(2) - bb(4) + image_data.meta.tile_height + 1,...
    bb(1) - bb(3) + image_data.meta.tile_width + 1, nbands,'single');
%
for i2 = 1:length(image_data.meta.image_names)
   %
   ii = ismember({images(:).name}, image_data.meta.image_names(i2).name);
   %
   bbim(ul(i2,2):ul(i2,2) + image_data.meta.tile_height - 1,...
       ul(i2,1):ul(i2,1) + image_data.meta.tile_width - 1, :) = ...
       images(ii).image;
   %
end
%
image_data.image = bbim;
image_data.meta.upperleftcorners = ul;
%
ss = size(image_data.image);
image_data.meta.width = ss(2);
image_data.meta.height = ss(1);
image_data.meta.size = ss;
image_data.meta.original_boundingbox = bb;
image_data.meta.original_xcoord = [image_data.meta.image_names(:).x_coord];
image_data.meta.original_ycoord = [image_data.meta.image_names(:).y_coord];
%
fprintf('           ');
toc;
%
end