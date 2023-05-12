%% distribute_registration_tasks
%% Description
% create and launch parallel registration tasks for the initial or affine
% transformations. In doing so, work is dividied for parallelization and we
% isolate regions of the moving image and the corresponding fixed image so
% that we don't have to send the entire image to all workers. 
%
% note that we define two types of transformations: the initial and affine.
% For the initial transformation we use a search boarder of 1/2 the grid
% size and control points from the grids for registration both defined by 
% get_search_grids. For the affine transformation we use all grids (or
% tiles) for registration. 
%
%% Input
% moving_image: moving_image struct output from @get_rough_registration
% fixed_image: fixed_image struct output from @get_rough_registration
% meta: the metadata object output updated from either @get_search_grids
% function or @initial_affine_transformation_parameters for the initial or
% affine transformation steps respectively. 
% opt: initial_transformation or affine_transformation
%% ----------------------------------
function [fixed_image, meta] = ...
    distribute_registration_tasks(moving_image, fixed_image, meta, opt)
%
input_reg_data = mergestructs(...
    meta.(opt).input_reg_data, meta.input_reg_data);
input_reg_data.opt = opt;
%
number_of_worker_images = sort(histcounts(...
    input_reg_data.control_point_idx, meta.opts.numcores), 'desc')';
unassigned_images_ii = true(length(input_reg_data.control_point_idx), 1);
%
profileName = parallel.defaultClusterProfile();
meta.(opt).clust = parcluster(profileName);
meta.(opt).clust.NumWorkers = meta.opts.numcores;
meta.(opt).clust.NumThreads = 2;
meta.(opt).job = createJob(meta.(opt).clust);
%
meta.(opt).image_groups = cell(meta.opts.numcores, 1);
%
for jobnumber = 1:meta.opts.numcores
    %
    [unassigned_images_ii, image_group] = find_nearest_images(...
        fixed_image, unassigned_images_ii, ...
        number_of_worker_images(jobnumber), input_reg_data);
    %
    [image_group, moving_image_clip] = create_cluster_regions(...
        moving_image, fixed_image, input_reg_data, image_group, opt);
    %
    meta = create_registration_tasks(...
        meta, image_group, moving_image_clip,...
        input_reg_data, opt, jobnumber);
    %
    meta.(opt).image_groups{jobnumber} = image_group;
    %
end
%
meta.(opt).image_groups = [meta.(opt).image_groups{:}];
meta.(opt).number_of_worker_images = number_of_worker_images;
%
poolobj = gcp('nocreate');
delete(poolobj);
%
fprintf(['Calculating ', replace(opt, '_', ' '), ' with ',...
    int2str(length(input_reg_data.control_point_idx)),' sample images \n'])
%
tic
submit(meta.(opt).job);
wait(meta.(opt).job); % need to add a timer and progress
meta.(opt).output = fetchOutputs(meta.(opt).job);
delete(meta.(opt).job);
fprintf('           ');
toc;
%
end