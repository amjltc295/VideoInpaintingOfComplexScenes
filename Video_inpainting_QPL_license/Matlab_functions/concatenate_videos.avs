a=DirectShowSource("Usine_scratch_original.avi")
b=DirectShowSource("Usine_scratch_restored.avi")

clip = StackVertical(a,b)
clip = AddBorders(clip,300,0,300,0)

return(clip)
Loop(3)