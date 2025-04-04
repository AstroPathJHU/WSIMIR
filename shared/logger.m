%% logger
% format the log messages and print them with fprintf so they can be
% forwarded to a file if running matlab from a terminal.
%%
function logger(message, log_level, meta)
%
if meta.opts.log_levels.(meta.opts.log_level) > ...
        meta.opts.log_levels.(log_level)
    return
end
%
if meta.opts.log_no_start_stop && meta.opts.log_levels.(log_level) == 2
    return
end
%
if isstruct(message)
    m_struct = message;
    message = m_struct.message;
else
    m_struct = [];
end
%
output_msg = replace(message, '\', '/');
%
if meta.opts.format_log
    time = string(datetime(...
        now,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    step_name = strcat(meta.opts.step_names(meta.opts.step+1));
    output_msg = strcat( ...
        "WSIMIR;", step_name, ";", log_level, ": ", output_msg, ";", time);
    %
end
%
if ~isempty(m_struct)
    m_struct.message = output_msg;
    output_msg = m_struct;
end
%
if strcmp(log_level, 'ERROR')
    error(output_msg)
elseif strcmp(log_level, 'WARN')
    warning(output_msg)
else
    fprintf(strcat(output_msg, "\n"))
end    
%
end