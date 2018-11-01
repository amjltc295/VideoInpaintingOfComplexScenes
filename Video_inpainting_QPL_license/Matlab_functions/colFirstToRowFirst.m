%this function converts indexing from column first to row first

function[indsOut] = colFirstToRowFirst(sizeImg,linearInds)

    rows = ceil( (linearInds) /sizeImg(2));
    
    cols = linearInds -(rows-1)*sizeImg(2);

    indsOut = sub2ind(sizeImg,rows,cols);
end