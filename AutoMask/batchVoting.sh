# For Quality Analysis use
# Leave-one-out registration and label fusion
# Should be called before batchVoting
# Yuhua Chen 5/30/2015


OUTPUTPATH='/home/yuhuachen/WorkingData/preMask/'

./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 1 -t s -l Registration
echo 'Registration done'

./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 1 -t s -l MajorityVoting
echo 'Voting done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l JointFusion
echo 'Joint3d done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l JointFusion2D
echo 'Joint2d done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l STAPLE
echo 'STAPLE done'
./autoMask.sh -o "${OUTPUTPATH}/SyN2" -r 0 -t s -l Spatial
echo 'Spatial done'

./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l MajorityVoting
echo 'Voting done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l JointFusion
echo 'Joint3d done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l JointFusion2D
echo 'Joint2d done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l STAPLE
echo 'STAPLE done'
./autoMask.sh -o "${OUTPUTPATH}/Affine" -w "${OUTPUTPATH}/SyN2" -r 0 -t a -l Spatial
echo 'Spatial done'