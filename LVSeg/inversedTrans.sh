WARPPATH='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/Templates/Template1266'
OUTPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1266/Test1' 
PHASENUMBER=16
TEMPLABELIMG="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253/segLV.nii"

function Help {
    cat <<HELP
Usage:
`basename $0` -w WARPPATH -o OUTPUTPATH -l TEMPLABELIMG -s PHASENUMBER
`basename $0` -w '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/Templates/Template1266' -o '/home/yuhuachen/WorkingData/InverseTrans/1266/Test1' -l "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253/segLV.nii"
Compulsory arguments:
	 -w:  Path of the template transform info files
     -o:  Output Path: path of all output files
     -l:  Label of the unbiased template
     -s:  Phase Number: total number of phase (default = 16)
--------------------------------------------------------------------------------------
script by Yuhua Chen 6/25/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "t:h:w:o:l:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      w) # transform type
   WARPPATH=$OPTARG
   ;;
      o) # Registration Switch
    OUTPUTPATH=$OPTARG
    ;;
      l) # Phase Number
   TEMPLABELIMG=$OPTARG
   ;;
      s) # Phase Number
   PHASENUMBER=$OPTARG
   ;;   
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

mkdir $OUTPUTPATH -p

for (( p = 1; p <= $PHASENUMBER; p++))
do
	echo "${p}/${PHASENUMBER}....."
	prefix=$WARPPATH/reg${p}
	outputImage="${OUTPUTPATH}/seg${p}.nii.gz"
    movingImage=$TEMPLABELIMG
    refImage=$TEMPLABELIMG
	antsApplyTransforms -d 3 --float -f 0 -i $movingImage -o $outputImage -r $refImage -t "${prefix}1InverseWarp.nii.gz" -t "[${prefix}0GenericAffine.mat,1]" -n NearestNeighbor
done