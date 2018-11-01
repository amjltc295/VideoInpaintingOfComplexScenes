%make file for the spatio-temporal patch-match

function[] = make_reconstruct_video(debugOn)

    if (nargin ==1)
        if (debugOn == 0)
            mex reconstruct_video_mex.cpp
        else
            mex -g reconstruct_video_mex.cpp
        end
    else
        mex reconstruct_video_mex.cpp
    end
end