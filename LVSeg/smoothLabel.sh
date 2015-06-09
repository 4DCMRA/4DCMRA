DATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253' 
OUTPUTPATH=$DATAPATH/refineLabel
RADIUS1=3
RADIUS2=5
mkdir $OUTPUTPATH

#Step 1 Smooth Label 1 endo
ImageMath 3 $OUTPUTPATH/endo.nii ReplaceVoxelValue $DATAPATH/label.nii 2 2 0
ImageMath 3 $OUTPUTPATH/endo.nii MD $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii ME $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii ME $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii MD $OUTPUTPATH/endo.nii $RADIUS1+1
ImageMath 3 $OUTPUTPATH/endo.nii ReplaceVoxelValue $OUTPUTPATH/endo.nii 1 1 2


#Step 1 Smooth Label 2 whole lv
ImageMath 3 $OUTPUTPATH/lv.nii ReplaceVoxelValue $DATAPATH/label.nii 2 2 1
ImageMath 3 $OUTPUTPATH/lv.nii MD $OUTPUTPATH/lv.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv.nii ME $OUTPUTPATH/lv.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv.nii ME $OUTPUTPATH/lv.nii $RADIUS2+1
ImageMath 3 $OUTPUTPATH/lv.nii MD $OUTPUTPATH/lv.nii $RADIUS2

#Combine labels
ImageMath 3 $DATAPATH/segLV.nii overadd $OUTPUTPATH/lv.nii $OUTPUTPATH/endo.nii