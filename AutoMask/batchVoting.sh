# For Quality Analysis use
# Leave-one-out registration and label fusion
# Should be called before batchVoting
# Yuhua Chen 5/30/2015

ATLASSIZE=6
OUTPUTPATH='/home/yuhuachen/WorkingData/Atlas6wM/'
mkdir $OUTPUTPATH

./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 1 -t s  -l Registration -s $ATLASSIZE
echo 'Registration done'

./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 1 -t s -l MajorityVoting -s $ATLASSIZE
echo 'Voting done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l JointFusion -s $ATLASSIZE
echo 'Joint3d done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l JointFusion2D -s $ATLASSIZE
echo 'Joint2d done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l STAPLE -s $ATLASSIZE
echo 'STAPLE done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l Spatial -s $ATLASSIZE
echo 'Spatial done'

./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l MajorityVoting -s $ATLASSIZE
echo 'Voting done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l JointFusion -s $ATLASSIZE
echo 'Joint3d done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l JointFusion2D -s $ATLASSIZE
echo 'Joint2d done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l STAPLE -s $ATLASSIZE
echo 'STAPLE done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l Spatial -s $ATLASSIZE
echo 'Spatial done'