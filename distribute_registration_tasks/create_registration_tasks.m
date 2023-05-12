%% create_registration_tasks   
%
%%
function meta = create_registration_tasks(...
    meta, image_group, moving_image_clip, input_reg_data, opt, jobnumber)
%
if ~isempty(image_group.bb)
    %
    meta.(opt).task{jobnumber} = createTask(meta.(opt).job, ...
        @get_transformation_on_regions, 1, ...
        {image_group, moving_image_clip, input_reg_data});
    %
else
    %
    meta.(opt).task{jobnumber} = ...
        createTask(meta.(opt).job, @empty_task, 0, {jobnumber});
    %
end
%
end