%% Estimate_MI
%% Description
% determine the mutual information of two images, reshaped_image_a (a
% single column vector image) and a single column vector image of the same
% size in the mi_vars.sampled_image_b variable created in prepare_mi_vars
%
%% Input
% reshaped_image_a: a single column vector image the same size of
% mi_vars.sampled_image_b
% mi_vars: created by prepare_mi_vars with scale and subsampling structure
% input
%% Output
% the mutual information measurement
%% ------------------------------------
function mutualInformation = estimate_mi(reshaped_image_a, mi_vars)
%
% the image stack where n x m = pixels x colors and the two
% images to be registered are stacked in the m direction.
%
image_stack = [reshaped_image_a, mi_vars.sampled_image_b];
%
% get the unique combinations of pixel values across the dimensions
%
mincol = min(image_stack,[],1);
maxcol = max(image_stack,[],1);
image_stack = image_stack - mincol + 1;
histogram_sizes = cast(maxcol - mincol + 1, 'uint64');
dimIndex = [1, cumprod(histogram_sizes(1:end-1))]';
%
image_stack(:, 2:end) = image_stack(:, 2:end) - 1;
%
joint_histogram_idx = uint64(image_stack * double(dimIndex));
joint_histogram_idx(joint_histogram_idx < 1) = 1;
%
joint_histogram = zeros(cast(prod(histogram_sizes),'uint64'),1,'uint32');
%
for x = 1:length(image_stack(:,1))
    joint_histogram(joint_histogram_idx(x)) = ...
        joint_histogram(joint_histogram_idx(x)) + 1;
end
%
% divide by the total combinations (prob) and put into an array
% corresponding to the combination positions in the histogram
%
jointProb = reshape(cast(joint_histogram, 'single')'...
    /(mi_vars.np), histogram_sizes(1:end));
%
marginalProbF2 = jointProb;
marginalProbR2 = jointProb;
%
for i1 = 1:mi_vars.levels_a
    marginalProbF2 = sum(marginalProbF2, i1);
end
%
for i1 = mi_vars.levels_a + 1 : mi_vars.ndim
    marginalProbR2 = sum(marginalProbR2, i1);
end
%
marginalProbF2 = reshape(marginalProbF2,1,[]);
marginalProbR2 = reshape(marginalProbR2,[],1);
%
marginalProd = reshape(marginalProbR2 * marginalProbF2, histogram_sizes);
%
ratio = jointProb ./ marginalProd;
mI = jointProb .* log(ratio) / log(mi_vars.np);
mutualInformation = sum(mI(~isnan(mI)))/(mi_vars.np);
%
end