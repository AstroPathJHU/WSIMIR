%% create_registration_cluster
%
%%
%
function meta = create_registration_cluster(meta, opt)
%
profileName = parallel.defaultClusterProfile();
meta.(opt).clust = parcluster(profileName);
meta.(opt).clust.NumWorkers = meta.opts.numcores;
meta.(opt).clust.NumThreads = meta.opts.numthreads;
meta.(opt).job = createJob(meta.(opt).clust);
%
end