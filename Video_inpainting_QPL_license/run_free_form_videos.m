function[outputPath] = run_free_form_videos(start_i, end_i)
    %video_dirs = dir(fullfile('./free_form_test_data/test_20181109/JPEGImages/*'));
    video_dirs = dir(fullfile('./free_form_test_data/img_align_celeba_subset_test/*'));
    video_dirs = video_dirs(3:end);

    %mask_dirs = dir(fullfile('./free_form_test_data/random_masks_vl20_ns5_object_like_test/*'));
    mask_dirs = dir(fullfile('./free_form_test_data/random_masks_ns5_object_like_image176_216_test/*'));
    mask_dirs = mask_dirs(3:end);

    for i = start_i : end_i
        video_name = sprintf('%s', video_dirs(i).name)
        mask_name = sprintf('%s', mask_dirs(i).name)

        video_dir = fullfile(video_dirs(i).folder, video_name);
        mask_dir = fullfile(mask_dirs(i).folder, mask_name);

        lv = length(dir(fullfile(video_dir, '*')));
        lm = length(dir(fullfile(mask_dir, '*')));
        if lv ~= lm
            disp(sprintf('Video %s has different video length (%d) and mask length (%d)', video_name, lv, lm))
            %disp('Insufficient part will be padded with previous frame/mask')
            %continue
        end

        out_name = sprintf('%s_%s', video_name, mask_name)
        if exist(fullfile('.', 'free_form_test_out', 'face', out_name))
            disp(sprintf('Video %s done before, skip', out_name))
            continue
        end

        imgVolOut = start_inpaint_video_mod(video_dir, mask_dir, -1, -1, 1);

        cd free_form_test_out
        cd face
        mkdir(out_name)
        cd(out_name)
        write_image_volume(imgVolOut, '');
        cd ..
        cd ..
        cd ..
    end
end
