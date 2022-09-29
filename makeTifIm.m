function img = makeTifIm(tobj,bands)
%
if ~exist('bands','var')
    bands = 0;
    while ~lastDirectory(tobj)
        bands = bands + 1;
        nextDirectory(tobj);
    end
end
%
if length(bands) == 1
    img = zeros(getTag(tobj,'ImageLength'),getTag(tobj,'ImageWidth'),bands,'single');
    for i1 = 1:bands
        setDirectory(tobj,i1);
        img(:,:,i1) = read(tobj);
    end
end
%
if length(bands) > 1
    img = zeros(getTag(tobj,'ImageLength'),getTag(tobj,'ImageWidth'),length(bands),'single');
    for i1 = 1:length(bands)
        setDirectory(tobj,bands(i1));
        img(:,:,i1) = read(tobj);
    end
%   
end