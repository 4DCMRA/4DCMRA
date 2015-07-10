import sys,os
templateId = sys.argv[1];
imgId = sys.argv[2];
ms_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Atlas/Template"+str(templateId)
as_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Template"+str(templateId)
output_path = "/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Correction/Template"+str(templateId)
#ms_path ="../../Data/LV/CorretiveLearning/Atlas/Template"+str(templateId)
#as_path="../../Data/LV/CorretiveLearning/Test1/Template"+str(templateId)
#output_path = "../../Data/LV/CorretiveLearning/Test1/Correction/Template"+str(templateId)
#for i in xrange(5):
#	imgId = i+1;
os.system("python batchCL.py -ms "+ms_path+" -as "+as_path+" -o "+output_path+" -t "+str(imgId))
