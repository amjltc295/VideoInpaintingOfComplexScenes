%this function converts indexing from row first to column first

function[indsOut] = rowFirstToColFirst(sizeImg,linearInds)

    [rows,cols] = ind2sub(sizeImg,linearInds);
    
    indsOut = cols + (rows-1)*sizeImg(2);

end