%this file creates a matrix with leading zeros before numbers
%arguments :
%1/ maximum number to be put into the matrix
%2/ the number of leading zeros in front of the number

function[strOut] = number_leading_zeros(number,nLeadingZeros)

    nDigits = ceil(log10(number+1));
    nZeros = nLeadingZeros-nDigits;
    
    strOut = '';
    for ii=1:nZeros
        strOut = strcat(strOut,'0');
    end
    strOut = strcat(strOut,num2str(number));
end