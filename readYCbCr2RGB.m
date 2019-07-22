function img = readYCbCr2RGB(tobj)
[Y,Cb,Cr] = read(tobj);
img = ycbcr2rgb(cat(3,Y,Cb,Cr));
%img = cat(3,Y,Cb,Cr);

end