%make file for the spatio-temporal patch-match
% varargin :
%   1/ debug
%   2/ parallelisation
function[] = make_spatio_temporal_patch_match(debugOn)

	if (nargin == 1)
		if (debugOn == 0)
            mex spatio_temporal_patch_match_mex.cpp
		else
			mex -g spatio_temporal_patch_match_mex.cpp
        end
    else    %0 parameters
        mex spatio_temporal_patch_match_mex.cpp;
    end

end