import time,sys,csv,argparse,os

def init():
	global in_groups_file,in_template_path,in_warp_path,out_seg_path,phase_number;
	in_groups_file="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/LV_phase_groups.csv";
	in_template_path='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/Template/'
	in_warp_path='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/';
	out_seg_path='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/Seg/';
	phase_number=16
	inputParser();
	checkInput();
	makeOutputDirs();

def inputParser():
	global in_groups_file,in_template_path,in_warp_path,out_seg_path,phase_number;
	# Parse the input parameters
	parser = argparse.ArgumentParser(description='Calculate the weights for each phases based on the LV volumes'
	 +'in different caridac phases and make dual weighted templates for systolic phase and diastolic phase.');
	parser.add_argument("-g", "--in_groups_file", type=str, help="CSV file contains grouping infomation");
	parser.add_argument("-i", "--in_template_path", type=str, help="The folder has two template images");
	parser.add_argument("-w", "--in_warp_path", type=str, help="Path of intermediate files of warping image and transform data");
	parser.add_argument("-o", "--out_seg_path", type=str, help="Path of final output segmentation path");
	parser.add_argument("-s", "--phase_number", type=int, help="The source phases image data, deault = 16");
	
	args = parser.parse_args()
	
	if args.in_groups_file != None:
		in_groups_file = args.in_groups_file;
	if args.in_template_path != None:
		in_template_path = args.in_template_path;
	if args.in_warp_path != None:
		in_warp_path = args.in_warp_path;
	if  args.out_seg_path != None:
		out_seg_path = args.out_seg_path;
	if args.phase_number != None:
		phase_number = args.phase_number;

def checkInput():
	global in_groups_file,in_template_path,in_warp_path,out_seg_path,phase_number;	
	print "Command line is ok:"
	print "================ parameters ======================="
	print "Grouping File:	",in_groups_file
	print "Template:	",in_template_path
	print "Warped Path:	",in_warp_path
	print "Output Path:	",out_seg_path
	print "Phase Number:	",phase_number

def listFormat(list):
	return [float("{0:.5f}".format(x)) for x in list]

def ensure_dir(r):
	d = os.path.dirname(r);
	if not os.path.exists(d):
		os.makedirs(d);

def makeOutputDirs():
	global out_seg_path
	ensure_dir(out_seg_path+"/");

def dirTempPath(groupId):
	global in_warp_path
	return in_warp_path+"/Template"+str(groupId)+"/";

def readGroupingCSV(filename):
	# Read the volume info csv files
	# line 1 is a list of phase ids
	# line 2 is a list of volumes
	with open(filename,'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=' ')
		lst_read = list(reader);
		id_sys = [int(x) for x in lst_read[0]]
		wt_sys = [float(x) for x in lst_read[1]]
		id_dia = [int(x) for x in lst_read[2]]
		wt_dia = [float(x) for x in lst_read[3]]
	return (id_sys,wt_sys,id_dia,wt_dia)

def inverseTransforms(groupId,ids):
	global in_warp_path,iterNumber, out_seg_path
	movingImage = in_template_path+"/Label"+str(groupId)+".nii.gz"

	for p in ids:
		print "Phase:		***	"+str(p)+" in "+str(ids)+"	***"
		prefix=dirTempPath(groupId)+"/reg"+str(p);
		refImage = prefix+"InverseWarped.nii.gz"
		outputImage= out_seg_path+"/seg"+str(p)+".nii.gz"
		cmd_trans = "antsApplyTransforms -d 3 --float -f 0 -i "+movingImage+" -o "+outputImage+" -r "+refImage+" -t "+prefix+"1InverseWarp.nii.gz -t ["+prefix+"0GenericAffine.mat,1] -n NearestNeighbor"
		os.system(cmd_trans);


def main():
	global iterNumber,phase_number,in_groups_file,out_seg_path
	start_time = time.time();
	init();

	#Read in volumes
	(id_sys,wt_sys,id_dia,wt_dia) = readGroupingCSV(in_groups_file);

	print "Systolic:	"
	print "Phases Id:	", id_sys
	print "Weights:	", listFormat(wt_sys)
	print "Diastolic:	"
	print "Phases Id:	", id_dia
	print "Weights:	", listFormat(wt_dia)

	# Inverse Transform
	# 	Systolic
	print "Inverse transform for systolic cardiac phases"	
	inverseTransforms(1,id_sys)

	# 	Diastolic
	print "Inverse transform diastolic cardiac phases"	
	inverseTransforms(2,id_dia)

	end_time = time.time();
	print "Total Elapsed Time: "+str(end_time - start_time)+"s"
	with open(out_seg_path+"/timing.txt","w") as timing_file:
		timing_file.write("Elapsed time: "+str(end_time - start_time)+"s")

	print "Finished."	

if __name__ == '__main__':
    main();