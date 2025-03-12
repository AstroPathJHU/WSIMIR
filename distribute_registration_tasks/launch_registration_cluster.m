%% launch_registration_cluster
%
%%
%
function meta = launch_registration_cluster(meta, opt)
%
tic
submit(meta.(opt).job);
wait(meta.(opt).job); % need to add a timer and progress
meta.(opt).output = fetchOutputs(meta.(opt).job);
delete(meta.(opt).job);
%
logger(strcat("Elapsed time: ", string(toc)), 'INFO', meta)
%
end