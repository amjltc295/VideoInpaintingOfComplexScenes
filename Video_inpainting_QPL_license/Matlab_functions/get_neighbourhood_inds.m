%this function retrievs the linear index/indices of the neighbourhood of a pixel p (linear
%index), or a list of pixels p

function[nbhoodIndsOut,pInds] = get_neighbourhood_inds(img,p,nbhood,indexing)

    nbhoodIndsOut = [];
    pInds = [];
    
    if (nargin<=3)
        indexing = 'row';
    end

    if(strcmp(indexing,'column'))
        nbhoodInds = rowFirstToColFirst([size(nbhood,1) size(nbhood,2)],find(nbhood == 1));
        nbhoodInds = sort(nbhoodInds);
        nbhoodInds = colFirstToRowFirst([size(nbhood,1) size(nbhood,2)],nbhoodInds);
    else
        nbhoodInds = find(nbhood == 1);
    end
    [nbhoodY,nbhoodX] = ind2sub(size(nbhood),nbhoodInds);
    nbhoodY = nbhoodY - ceil(size(nbhood,1)/2); nbhoodX = nbhoodX - ceil(size(nbhood,2)/2);
    
    for ii=1:length(p)
        [pY,pX] = ind2sub(size(img),p(ii));
        qY = pY*ones(length(nbhoodY),1) + nbhoodY;
        qX = pX*ones(length(nbhoodY),1) + nbhoodX;
        nbhoodIndsOut = [nbhoodIndsOut;sub2ind(size(img),qY,qX)];
        pInds = [pInds;p(ii)*ones(length(nbhoodY),1)];  %indicate from which pixel the neighbours come from
    end
end