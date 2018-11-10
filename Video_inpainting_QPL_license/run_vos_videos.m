function[outputPath] = run_vos_videos(start_i, end_i)

    video_dirs = dir('../../VOS_resized2/synthesized_frames/bg_*');
    
    for i = start_i : end_i
        video_name = sprintf('%s', video_dirs(i).name);
        
        video_dir = fullfile(video_dirs(i).folder, video_name);
        mask_dir = fullfile('../../VOS_resized2/fg_segm_bbox_masks', video_name);
        
        if length(dir(fullfile(video_dir, '*'))) ~= length(dir(fullfile(mask_dir, '*')))
            %disp(sprintf('Video %s has different video length and mask length', video_name))
            %continue
        end
        
        if exist(fullfile('.', 'VOS_output', video_name))
            disp(sprintf('Video %s done before, skip', video_name))
            continue
        end
        
        imgVolOut = start_inpaint_video_mod(video_dir, mask_dir, -1, -1);
        
        cd VOS_output
        mkdir(video_name)
        cd(video_name)
        write_image_volume(imgVolOut, '');
        cd ..
        cd ..
    end
end