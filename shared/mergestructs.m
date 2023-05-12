%% mergestructs
% merge two data structs
% https://www.mathworks.com/matlabcentral/answers/96973-how-can-i-concatenate-or-merge-two-structures#answer_401067
%%
function mergedstruct = mergestructs(x, y)
%
mergedstruct = cell2struct(...
    [struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
%
end