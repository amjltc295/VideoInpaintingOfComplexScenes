function[outputPath] = run_vos_videos(start_i, end_i)
    
    root_dir = '../../VideoObjectRemoval/VOS_origin';
    video_dirs = dir(fullfile(root_dir, 'synthesized_frames/bg_*'));

    for i = start_i : end_i
        video_name = sprintf('%s', video_dirs(i).name);
        
        video_dir = fullfile(video_dirs(i).folder, video_name);
        mask_dir = fullfile(root_dir, 'fg_segm_bbox_masks', video_name);
        
        if length(dir(fullfile(video_dir, '*'))) ~= length(dir(fullfile(mask_dir, '*')))
            disp(sprintf('Video %s has different video length and mask length', video_name))
            disp('Insufficient part will be padded with previous frame/mask')
            %continue
        end
        
        if exist(fullfile('.', 'VOS_origin_output_patch_3', video_name))
            disp(sprintf('Video %s done before, skip', video_name))
            continue
        end
        
        imgVolOut = start_inpaint_video_mod(video_dir, mask_dir, -1, -1);
        
        cd VOS_origin_output_patch_3
        mkdir(video_name)
        cd(video_name)
        write_image_volume(imgVolOut, '');
        cd ..
        cd ..
    end
end
