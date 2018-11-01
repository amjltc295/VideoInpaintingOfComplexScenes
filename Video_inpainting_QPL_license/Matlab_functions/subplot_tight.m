%this function subplots wimages with no border

function[hOut] = subplot_tight(m,n,i)
    
    [c,r] = ind2sub([m n], i);
    hOut = subplot('Position', [(c-1)/m, 1-(r)/n, 1/m, 1/n],'Units','normalized');
    axis off;
    
end