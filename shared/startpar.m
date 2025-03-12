%% startpar
%% Description
% start a parallel pool
%% ---------------------------
function startpar(meta)
%
if isempty(gcp('nocreate'))
    %
    logger('Starting parallel pool', 'INFO', meta)
    %
    try
        numcores = feature('numcores');
        %
        if numcores > meta.opts.numcores
            numcores = meta.opts.numcores;
        end
        evalc('parpool("local",numcores)');
        %
        msg = strcat("Parallel pool started with ", string(numcores), ...
            " cores");
        logger(msg, 'INFO', meta)
        %
    catch
        logger('Parallel pool could not be started', 'WARN', meta)
    end
end
%
end