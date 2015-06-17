# Produces a sum mask with dialtion
# Atlas Size must be more than 1
# Yuhua Chen 5/27/2015
INPUTPATH='/home/yuhuachen/WorkingData/LV_LOO2/'
OUTPUTPATH='/home/yuhuachen/WorkingData/LV_LOO2/'
ATLASSIZE=5
DILATERADIUS=5
ImageMath 3 $OUTPUTPATH/sumMask.nii + $INPUTPATH/mask1.nii $INPUTPATH/mask2.nii
for (( i = 3; i <=$ATLASSIZE; i++)) 
  do
  	ImageMath 3 $OUTPUTPATH/sumMask.nii + $OUTPUTPATH/sumMask.nii $INPUTPATH/mask"$i".nii
done
# Set (value >= 1) = 1
ImageMath 3 $OUTPUTPATH/sumMask.nii ReplaceVoxelValue $OUTPUTPATH/sumMask.nii 1 $ATLASSIZE 1
# Dialte with radius
ImageMath 3 $OUTPUTPATH/sumMask.nii MD $OUTPUTPATH/sumMask.nii $DILATERADIUS