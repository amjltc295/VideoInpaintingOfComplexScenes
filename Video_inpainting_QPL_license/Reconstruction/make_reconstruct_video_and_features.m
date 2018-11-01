
function[] = make_reconstruct_video_and_features(debugOn)

    if (nargin ==1)
        if (debugOn == 0)
            mex reconstruct_video_and_features_mex.cpp
        else
            mex -g reconstruct_video_and_features_mex.cpp
        end
    else
        mex reconstruct_video_and_features_mex.cpp
    end

end