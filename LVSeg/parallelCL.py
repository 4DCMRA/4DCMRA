import sys,os
templateId = sys.argv[1];
imgId = sys.argv[2];
root_path="/hpc/home/pangjx/4DCMRA/Data/LV/CorretiveLearning/"
#ms_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Atlas/Template"+str(templateId)
#as_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Template"+str(templateId)
#output_path = "/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Correction/Template"+str(templateId)
ms_path =root_path+"Atlas/Template"+str(templateId)
as_path=root_path+"Test1/Template"+str(templateId)
output_path = root_path+"Test1/Correction/Template"+str(templateId)
os.system("export ANTSPATH='/hpc/apps/ants/2.1.0-devel/bin/'")
os.system("module load ants/2.1.0-devel");
os.system("python batchCL.py -ms "+ms_path+" -as "+as_path+" -o "+output_path+" -t "+str(imgId))
