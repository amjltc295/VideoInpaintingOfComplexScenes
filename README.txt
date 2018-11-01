
This code implements the video inpainting algorithm of the following paper :

Video Inpainting of Complex Scenes
Alasdair Newson, Andres Almansa, Matthieu Fradet, Yann Gousseau, Patrick Perez
SIAM Journal of Imaging Science 2014 7:4, 1993-2019 

The code is issued in two versions with different licenses :
- BSD license (only handles static cameras)
- QPL license (can deal with moving cameras)

The QPL licensed version includes the 'Motion2D' code of the work of Odobez et al. :

J.-M. Odobez, P. Bouthemy, Robust multiresolution estimation of parametric motion models. Journal of Visual Communication and Image Representation, 6(4):348-365, December 1995.

This motion estimation code has a QPL license, and thus the inpainting code which uses it must be distributed with a QPL license, which means that the code cannot be modified.

The BSD licensed version of the code cannot deal with moving cameras, but modifications of the code are allowed by the license. 