function[outputPath] = run_free_form_videos(start_i, end_i)
    % VOS data with random object-like masks
    %video_dirs = dir(fullfile('./free_form_test_data/test_20181109/JPEGImages/*'));
    %mask_dirs = dir(fullfile('./free_form_test_data/random_masks_vl20_ns5_object_like_test/*'));

    % VOS data with originall object mask
    video_dirs = dir(fullfile('./free_form_test_data/test_20181109/JPEGImages/*'));
    mask_dirs = dir(fullfile('./free_form_test_data/test_20181109/Annotations/*'));

    % Faces with random object-like masks
    %video_dirs = dir(fullfile('./free_form_test_data/img_align_celeba_subset_test/*'));
    %mask_dirs = dir(fullfile('./free_form_test_data/random_masks_ns5_object_like_image176_216_test/*'));

    video_dirs = video_dirs(3:end);
    mask_dirs = mask_dirs(3:end);
    root_out_dir = fullfile('.', 'free_form_test_out', 'VOS_original_mask');
    mkdir(root_out_dir);

    for i = start_i : end_i
        video_name = sprintf('%s', video_dirs(i).name)
        mask_name = sprintf('%s', mask_dirs(i).name)

        video_dir = fullfile(video_dirs(i).folder, video_name);
        mask_dir = fullfile(mask_dirs(i).folder, mask_name);

        lv = length(dir(fullfile(video_dir, '*')));
        lm = length(dir(fullfile(mask_dir, '*')));
        if lv ~= lm
            disp(sprintf('Video %s has different video length (%d) and mask length (%d)', video_name, lv, lm))
        end

        out_name = sprintf('%s_%s', video_name, mask_name);
        out_dir = fullfile(root_out_dir, out_name)
        if exist(out_dir)
            disp(sprintf('Video %s done before, skip', out_name))
            continue
        end

        invert = 0;
        preprocess_vos_mask = 1;
        imgVolOut = start_inpaint_video_mod(video_dir, mask_dir, -1, -1, invert, preprocess_vos_mask);

        mkdir(out_dir);
        write_image_volume(imgVolOut, strcat(out_dir, '/'));
    end
end
