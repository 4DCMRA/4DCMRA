# Produces a sum mask with dialtion
# Atlas Size must be more than 1
# Yuhua Chen 5/27/2015
INPUTPATH='/media/yuhuachen/Document/WorkingData/Yibin/Atlas'
OUTPUTPATH='/media/yuhuachen/Document/WorkingData/Yibin/Atlas' 
ATLASSIZE=10
DILATERADIUS=15
for (( j = 1; j <= $ATLASSIZE; j++ ))
do
	maskImg=$OUTPUTPATH/mask${j}.nii.gz
	if [[ $j -eq 1 ]]; then
		ImageMath 3 ${maskImg} + $INPUTPATH/label2.nii $INPUTPATH/label3.nii
		for (( i = 4; i <=$ATLASSIZE; i++)) 
	    do
		  	ImageMath 3 ${maskImg} + ${maskImg} $INPUTPATH/label${i}.nii
		done		
	fi

	if [[ $j -eq 2 ]]; then
		ImageMath 3 ${maskImg} + $INPUTPATH/label1.nii $INPUTPATH/label3.nii
		for (( i = 4; i <=$ATLASSIZE; i++)) 
		do
		  	ImageMath 3 ${maskImg} + ${maskImg} $INPUTPATH/label${i}.nii
		done				
	fi

	if [[ $j -ge 3 ]]; then
		ImageMath 3 ${maskImg} + $INPUTPATH/label1.nii $INPUTPATH/label2.nii
		for (( i = 3; i <=$ATLASSIZE; i++)) 
		do
			if [[ $i -eq $j ]]; then
				continue
			fi
		  	ImageMath 3 ${maskImg} + ${maskImg} $INPUTPATH/label${i}.nii
		done
	fi
	# Set (value >= 1) = 1
	ImageMath 3 ${maskImg} ReplaceVoxelValue ${maskImg} 1 9999 1
	# Dialte with radius
	ImageMath 3 ${maskImg} MD ${maskImg} $DILATERADIUS
done