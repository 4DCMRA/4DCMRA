DATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_684' 
RAWIMG=$DATAPATH/Raw/manualLabel.nii
OUTPUTPATH=$DATAPATH/refineLabel
RADIUS1=3
RADIUS2=5
mkdir $OUTPUTPATH

#Step 1 Smooth Label 2 endo
ImageMath 3 $OUTPUTPATH/endo.nii ReplaceVoxelValue $RAWIMG 1 1 0
ImageMath 3 $OUTPUTPATH/endo.nii MD $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii ME $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii ME $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii MD $OUTPUTPATH/endo.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo.nii ReplaceVoxelValue $OUTPUTPATH/endo.nii 1 1 2


#Step 1 Smooth Label 1 whole lv
ImageMath 3 $OUTPUTPATH/lv.nii ReplaceVoxelValue $RAWIMG 2 2 1
ImageMath 3 $OUTPUTPATH/lv.nii MD $OUTPUTPATH/lv.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv.nii ME $OUTPUTPATH/lv.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv.nii ME $OUTPUTPATH/lv.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv.nii MD $OUTPUTPATH/lv.nii $RADIUS2

#Combine labels
ImageMath 3 $DATAPATH/segLV.nii overadd $OUTPUTPATH/lv.nii $OUTPUTPATH/endo.nii