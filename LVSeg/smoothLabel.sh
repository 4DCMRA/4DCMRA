DATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1206' 

RADIUS1=3
RADIUS2=4
NAMEMARKER=""
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
	 -i:  INPUT PATH: path of input images
	 -r:  Manual Label Filename (default = manualLabel${NAMEMARKER}.nii)
     -o:  Output Path: path of all output files
     -p:  Prefix of the output files (default = empty)
     -a: Dilation and Erosion radius for endo (default = 3)
     -b: Dilation and Erosion radius for whole LV (default = 4)
--------------------------------------------------------------------------------------
script by Yuhua Chen 5/30/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
fi	

#Input Parms
while getopts "h:i:o:r:a:b:p:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
    r) # Registration Switch
    RAWIMG=$OPTARG
    ;;
     a) # Registration Switch
    RADIUS1=$OPTARG
    ;;
     b) # Registration Switch
    RADIUS2=$OPTARG
    ;;      
      p) # atlas size
   NAMEMARKER=$OPTARG
   ;;
      i) # Input path
   DATAPATH=$OPTARG
   ;;
   	  o) # Output path
   OUTPUTPATH=$OPTARG
   ;;
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

if [[ -z $OUTPUTPATH ]];then
	OUTPUTPATH=$DATAPATH/refineLabel
fi

if [[ -z $RAWIMG ]];then
	RAWIMG=$DATAPATH/Raw/manualLabel${NAMEMARKER}.nii
	if [[ -f RAWIMG ]];then
		RAWIMG=$DATAPATH/manualLabel${NAMEMARKER}.nii
	fi
fi

mkdir $OUTPUTPATH


#Step 1 Smooth Label 2 endo
ImageMath 3 "$OUTPUTPATH/endo${NAMEMARKER}.nii" ReplaceVoxelValue $RAWIMG 1 1 0
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii ReplaceVoxelValue $OUTPUTPATH/endo${NAMEMARKER}.nii 2 2 1
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii MD $OUTPUTPATH/endo${NAMEMARKER}.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii ME $OUTPUTPATH/endo${NAMEMARKER}.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii ME $OUTPUTPATH/endo${NAMEMARKER}.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii MD $OUTPUTPATH/endo${NAMEMARKER}.nii $RADIUS1
ImageMath 3 $OUTPUTPATH/endo${NAMEMARKER}.nii ReplaceVoxelValue $OUTPUTPATH/endo${NAMEMARKER}.nii 1 1 2


#Step 1 Smooth Label 1 whole lv
ImageMath 3 $OUTPUTPATH/lv${NAMEMARKER}.nii ReplaceVoxelValue $RAWIMG 2 2 1
ImageMath 3 $OUTPUTPATH/lv${NAMEMARKER}.nii MD $OUTPUTPATH/lv${NAMEMARKER}.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv${NAMEMARKER}.nii ME $OUTPUTPATH/lv${NAMEMARKER}.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv${NAMEMARKER}.nii ME $OUTPUTPATH/lv${NAMEMARKER}.nii $RADIUS2
ImageMath 3 $OUTPUTPATH/lv${NAMEMARKER}.nii MD $OUTPUTPATH/lv${NAMEMARKER}.nii $RADIUS2

#Combine labels
ImageMath 3 $OUTPUTPATH/seglv${NAMEMARKER}.nii overadd $OUTPUTPATH/lv${NAMEMARKER}.nii $OUTPUTPATH/endo${NAMEMARKER}.nii