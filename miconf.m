function Sc = miconf(mimat,range)
C = zeros(3,1);
if ~exist('range','var')
range = 1.25:0.25:2;
end
% for i1 = 1:length(mimat)
    [ih,iw]=size(mimat);
    [ma,mind] = max(mimat(:));
    [iy,ix] = ind2sub(size(mimat),mind);
    if iy > size(mimat,1)/10 && ih-iy > size(mimat,1)/10 && ...
       ix > size(mimat,2)/10 && iw-ix > size(mimat,2)/10
        D = [];
        for i2 = 1:length(range)%1.25:0.25:2
            I = find(mimat(:)>1/range(i2)*(ma-mean(mimat(:)))+mean(mimat(:)));
            [Iy,Ix] = ind2sub(size(mimat),I);
            D = [D;((Iy-iy).^2+(Ix-ix).^2).^0.5];
%             C(1) = C(1) + sum(D);%std(D);
        end
        C = std(D);
%         end
    else
        C(1) = NaN;
    end
% end
[Iy,Ix] = ind2sub(size(mimat),1:numel(mimat));
[iy,ix] = size(mimat);
iy = iy/2;
ix = ix/2;
% C(2) = 4*sum(((Iy-iy).^2+(Ix-ix).^2).^0.5); % true max sum(D)
C(2) = std(repmat((((Iy-iy).^2+(Ix-ix).^2).^0.5),1,length(range)));
C(isnan(C)) = max(C);
C(3) = 0; % true minimum sum(D)
Sc = 1-zeroAndScale(C,1);
Sc(end-1:end) = [];% = Sc(1:end-1);