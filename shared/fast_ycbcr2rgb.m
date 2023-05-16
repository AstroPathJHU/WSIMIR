%% fast_ycbcr2rgb
% code adopted from MATLAB ycbcr2rgb
%%
function rgb = fast_ycbcr2rgb(ycbcr)
%
T = [65.481 128.553 24.966;...
    -37.797 -74.203 112; ...
    112 -93.786 -18.214];
Tinv = T^-1;
offset = [16;128;128];
%
scaleFactor.T = 255;        % scale output so it is in range [0 255].
scaleFactor.offset = 255;   % scale output so it is in range [0 255].
T = scaleFactor.T * Tinv;
offset = scaleFactor.offset * Tinv * offset;
% Initialize the output
rgb = zeros(size(ycbcr), 'like', ycbcr);
%
rgb(:, 1) = imlincomb(T(1, 1), ycbcr(:, 1), T(1, 3), ycbcr(:,3), -offset(1));
rgb(:, 2) = imlincomb(T(1, 1), ycbcr(:, 1), T(2, 2), ycbcr(:, 2), T(2, 3), ycbcr(:, 3), -offset(2));
rgb(:, 3) = imlincomb(T(1, 1), ycbcr(:, 1), T(3, 2), ycbcr(:, 2), -offset(3));
%
end


