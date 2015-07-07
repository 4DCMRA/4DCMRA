# ./unbiasedTemplate.sh -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1206" -o "/home/yuhuachen/WorkingData/Template1206/" -r 1 -t s
# cp "/home/yuhuachen/WorkingData/Template1206/avg5.nii" "/home/yuhuachen/WorkingData/LV_LOO2/img4.nii"
# ./unbiasedTemplate.sh -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1241" -o "/home/yuhuachen/WorkingData/Template1241/" -r 1 -t s
# cp "/home/yuhuachen/WorkingData/Template1241/avg5.nii" "/home/yuhuachen/WorkingData/LV_LOO2/img5.nii"

# ../AutoMask/autoMask.sh -i "/home/yuhuachen/WorkingData/LV_LOO2/" -o "/home/yuhuachen/WorkingData/LV_LOO2/output" -l "Registration" -s 7 -r 1 -t s
# ../AutoMask/autoMask.sh -i "/home/yuhuachen/WorkingData/LV_LOO2/" -o "/home/yuhuachen/WorkingData/LV_LOO2/output" -l "MajorityVoting" -s 7 -r 0
# ../AutoMask/autoMask.sh -i "/home/yuhuachen/WorkingData/LV_LOO2/" -o "/home/yuhuachen/WorkingData/LV_LOO2/output" -l "JointFusion" -s 7 -r 0
# ../AutoMask/crossValidation.sh -i "/home/yuhuachen/WorkingData/LV_LOO2/" -o "/home/yuhuachen/WorkingData/LV_LOO2/output" -p "voting" -s 7
# ../AutoMask/crossValidation.sh -i "/home/yuhuachen/WorkingData/LV_LOO2/" -o "/home/yuhuachen/WorkingData/LV_LOO2/output" -p "joint" -s 7

# ./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253' 
# ./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_684" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_684' 
# ./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_696" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_696' 
./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1206" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1206' 
./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1241" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1241' 
./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1265" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1265' 
./unbiasedDualTemplate.sh  -t s -i "/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1266" -o '/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1266' 