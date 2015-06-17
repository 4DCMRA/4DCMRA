
# For Quality Analysis use
# Cross Validation after Leave-one-out registration and label fusion test
# Should be called after batchVoting
# Yuhua Chen 5/30/2015
ATLASSIZE=6
OUTPUTPATH='/home/yuhuachen/WorkingData/Atlas6wM/'
mkdir $OUTPUTPATH

./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p voting -s $ATLASSIZE
echo 'MajorityVoting done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p joint -s $ATLASSIZE
echo 'Joint3d done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p joint2d -s $ATLASSIZE
echo 'Joint2d done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p STAPLE -s $ATLASSIZE
echo 'STAPLE done'
./crossValidation.sh -o "${OUTPUTPATH}/SyN2" -p Spatial -s $ATLASSIZE
echo 'Spatial done'

./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p voting -s $ATLASSIZE
echo 'Voting done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p joint -s $ATLASSIZE
echo 'Joint3d done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p joint2d -s $ATLASSIZE
echo 'Joint2d done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p STAPLE -s $ATLASSIZE
echo 'STAPLE done'
./crossValidation.sh -o "${OUTPUTPATH}/Affine" -p Spatial -s $ATLASSIZE
echo 'Spatial done'