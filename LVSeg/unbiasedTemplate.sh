#!/bin/bash
ITERATION=5
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253"
OUTPUTPATH="/home/yuhuachen/WorkingData/Template1253/"

NUMBEROFTHREAD=8
TRANSFORMTYPE='s'
PHASENUMBER=16
REGISTRATIONFLAG=1
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH -e ITERATION
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp -e 5
Compulsory arguments:
	   -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all output files
     -s:  Phase Number: total number of phase (default = 16)
     -r:  Registration On/Off: 1 On, 0 Off (default = 1)    
     -e:  Iteration to form a template (default = 5)
     -t:  transform type (default = 'a')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn
--------------------------------------------------------------------------------------
script by Yuhua Chen 6/30/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:r:s:i:e:o:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      t) # transform type
   TRANSFORMTYPE=$OPTARG
   ;;
      r) # Registration Switch
    REGISTRATIONFLAG=$OPTARG
    ;;
      s) # Phase Number
   PHASENUMBER=$OPTARG
   ;;
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
      e) # Number of iteration
    ITERATION=$OPTARG
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

function ComputeAvgImage(){
	# Require Input: the number of iteration	
	# Construct Average Image
	avgImgStr=" "
	for (( p = 1; p <= $PHASENUMBER; p++))
	do
		if [[ "$1" -eq 0 ]]; then
			avgImgStr+=" ${INPUTPATH}/phase${p}.nii"
		else
			avgImgStr+=" ${OUTPUTPATH}/reg${p}Warped.nii"
		fi		
	done
	#Average the images
  AverageImages 3 ${OUTPUTPATH}/avg${1}.nii 1 ${avgImgStr}
	# echo AverageImages 3 ${OUTPUTPATH}/avg${1}.nii 1 ${avgImgStr}
}

mkdir $OUTPUTPATH

for (( i = 0; i < ITERATION; i++ ))
do	
	ComputeAvgImage ${i}
	avgImage="${OUTPUTPATH}/avg${i}.nii"
	#Registration to the average image
	for (( p = 1; p <= $PHASENUMBER; p++))
	do
		fixedImage=$avgImage
		prefix="${OUTPUTPATH}/reg${p}"
	  movingImage="${INPUTPATH}/phase${p}.nii"
		regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "		
		if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
	    	antsRegistrationSyNQuick.sh $regCommand
    fi
	done
done
ComputeAvgImage ${ITERATION}
