#!/bin/bash
ROOT_PATH="/hpc/home/pangjx/4DCMRA/4DCMRA/LVSeg"
module load ants/2.1.0-devel  
python "${ROOT_PATH}/batchCL.py"  -ms ${1} -as ${2} -o ${3} -t ${4}
