%this function normalises a vector/matrix so that its 

function[arrayOut] = normalise(arrayIn)

    minVal = min(arrayIn(:));

    arrayIn = arrayIn + (sign(minVal))*min(minVal,0);
    
    maxVal = max(arrayIn(:));
    
    arrayIn = arrayIn./maxVal;
    
    arrayOut = arrayIn;
end