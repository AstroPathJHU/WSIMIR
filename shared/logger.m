%% logger
%
function logger(message, log_level, meta)
%
if meta.opts.log_levels.(meta.opts.log_level) > ...
        meta.opts.log_levels.(log_level)
    return
end
%
time = string(datetime(now,'ConvertFrom','datenum'));
%
message = replace(message, '\', '/');
%
output_msg = strcat("WSIMIR;Step: ", num2str(meta.opts.step), ";", ...
    log_level, ":", message, ";", time, "; \n");
%
if strcmp(log_level, 'ERROR')
    error(output_msg)
elseif strcmp(log_level, 'WARN')
    warning(output_msg)
else
    fprintf(output_msg)
end    
%
end