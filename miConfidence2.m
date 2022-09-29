function [Sc,C] = miConfidence2(miData,range)
C = zeros(length(miData),1);
if ~exist('range','var')
range = 1.25:0.25:2;
end
% n = 0;
% mitot = 0;
% for i1 = 1:length(miData)
%    mitot = mitot + sum(miData{i1}{1}(:));
%    n = n + numel(miData{i1}{1});
% end
% metot = mitot/n;
% Sc2 = zeros(length(miData),1);

for i1 = 1:length(miData)
    D = [];
    [ih,iw]=size(miData{i1}{1});
    [ma,mind] = max(miData{i1}{1}(:));
    [iy,ix] = ind2sub(size(miData{i1}{1}),mind);
    me = mean(miData{i1}{1}(:));
%     Sc2(i1) = ma-metot;
%     range = linspace(ma-me,ma,10);
    if iy > 1 && ih-iy > 0 && ...%size(miData{i1}{1},1)/10 && ih-iy > size(miData{i1}{1},1)/10 && ...
       ix > 1 && iw-ix > 0 %size(miData{i1}{1},2)/10 && iw-ix > size(miData{i1}{1},2)/10
         
        for i2 = 1:length(range)
            I = find(miData{i1}{1}(:)>1/range(i2)*(ma-me)+me);
            [Iy,Ix] = ind2sub(size(miData{i1}{1}),I);
            D = [D;((Iy-iy).^2+(Ix-ix).^2).^0.5];
%             C(i1) = C(i1) + sum(D);%std(D);
%              C(i1) = C(i1) + std(D);
        end
        C(i1) = std(D);
%         end
    else
        C(i1) = NaN;
    end
    
end
[Iy,Ix] = ind2sub(size(miData{i1}{1}),1:numel(miData{i1}{1}));
[iy,ix] = size(miData{i1}{1});
iy = iy/2;
ix = ix/2;
% C(i1+1) = length(range)*sum(((Iy-iy).^2+(Ix-ix).^2).^0.5); % true max sum(D)
% C(i1+1) = length(range)*std(((Iy-iy).^2+(Ix-ix).^2).^0.5); % true max sum(D)
C(i1+1) = std(repmat((((Iy-iy).^2+(Ix-ix).^2).^0.5),1,length(range)));
C(isnan(C)) = max(C);
C(end+1) = 0; % true minimum sum(D)
Sc = 1-zeroAndScale(C,1);
Sc(end-1:end) = [];% = Sc(1:end-1);
% Sc2 = zeroAndScale(Sc2,1);