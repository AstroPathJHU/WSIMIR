%% read_component_images
%% Description
% read in a component image
%% Input
% filename: filename to read in 
% levels: number of relevant components in the image
% nbands: number of bands to read in (optional with default to read in all
% bands)
%% -------------------------------
function img = read_component_images(filename, levels, nbands, h, w)
%
% if no band number is specified read in all bands
%
if nbands == 0
    nbands = 0;
    %
    if nargin > 3
       img = zeros(h, w, levels); 
    else 
        img = [];
    end
    %
    for i2 = 1:levels
        img(:,:,i2) = imread(filename, i2);
    end
end
%
% if a band number is specified read to that band
%
if nbands >= 1
    %
    if nargin > 3
       img = zeros(h, w, nbands); 
    else
        img = [];
    end
    %
    for i2 = 1:nbands
        img(:, :, i2) = imread(filename, i2);
    end
end
%
end