

%this function erodes an image volume, while taking into account
%a modified image domain

function[occVolErode] = imerode_custom_image_domain(occVolIter,occVol,structElCube,imgDomainVol)

    occVolIter(imgDomainVol>0) = 1;
    occVolErode = imerode(occVolIter,structElCube);
    occVolErode(occVol==0) = 0;

end