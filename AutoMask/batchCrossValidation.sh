# For Quality Analysis use
# Cross Validation after Leave-one-out registration and label fusion test
# Should be called after batchVoting
# Yuhua Chen 5/30/2015

OUTPUTPATH='/home/yuhuachen/WorkingData/preMask/'
mkdir "${OUTPUTPATH}/Affine"
mkdir "${OUTPUTPATH}/SyN2"

./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p voting
echo 'MajorityVoting done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p joint
echo 'Joint3d done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p joint2d
echo 'Joint2d done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p STAPLE
echo 'STAPLE done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p Spatial
echo 'Spatial done'

./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p voting
echo 'Voting done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p joint
echo 'Joint3d done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p joint2d
echo 'Joint2d done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p STAPLE
echo 'STAPLE done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p Spatial
echo 'Spatial done'