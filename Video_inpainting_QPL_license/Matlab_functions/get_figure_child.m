%this function returns a certain object contained within a figure

function[handleOut] = get_figure_child(fh,nameChild)

    fhChildren = get(fh,'children');
    fhChildrenNames = get(fhChildren,'tag');
    handleOut = fhChildren(find(strcmp(nameChild,fhChildrenNames)));
end