%% startpar
%% Description
% start a parallel pool
%% ---------------------------
function meta = startpar(meta)
%
if isempty(gcp('nocreate'))
    try
        numcores = feature('numcores');
        %
        if numcores > meta.opts.numcores
            numcores = meta.opts.numcores; %#ok<NASGU>
        end
        evalc('parpool("local",numcores)');
    catch
    end
end
%
end