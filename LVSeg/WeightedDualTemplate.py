import sys,csv,argparse,os,time,shutil

CONST_WEIGHT_THRESHOLD = 0.0001

def init():
	global in_volume_file,in_source_path,out_warp_path,out_template_path,phase_number,numberOfThread,transformTypes,iterNumber;
	in_volume_file="/home/yuhuachen/WorkingData/InverseTrans/1253/Test1/Volumes/LV_volume.csv";
	in_source_path='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253'
	out_warp_path='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/';
	out_template_path='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253/Test2/Template';
	phase_number=16
	numberOfThread = 8;
	transformTypes = 's';
	iterNumber = 5;
	inputParser();
	checkInput();
	makeOutputDirs();

def inputParser():
	global in_volume_file,in_source_path,out_warp_path,out_template_path,phase_number,numberOfThread,transformTypes,iterNumber;
	# Parse the input parameters
	parser = argparse.ArgumentParser(description='Calculate the weights for each phases based on the LV volumes'
	 +'in different caridac phases and make dual weighted templates for systolic phase and diastolic phase.');
	parser.add_argument("-v", "--in_volume_file", type=str, help="CSV file contains volume infomation");
	parser.add_argument("-i", "--in_source_path", type=str, help="The source phases image data");
	parser.add_argument("-w", "--out_warp_path", type=str, help="Path of intermediate files of warping image and transform data");
	parser.add_argument("-o", "--out_template_path", type=str, help="Path of final output tepmlate path");
	parser.add_argument("-t", "--transformTypes", type=str, help="transform type (default = 's') | "+
        "t: translation | "+
        "r: rigid | "+
        "a: rigid + affine | "+
        "s: rigid + affine + deformable syn | "+
        "sr: rigid + deformable syn | "+
        "b: rigid + affine + deformable b-spline syn | "+
        "br: rigid + deformable b-spline syn")
	parser.add_argument("-s", "--phase_number", type=int, help="The source phases image data, deault = 16");
	parser.add_argument("-e", "--iterNumber", type=int, help="Iteration to make templates, default = 5");
	parser.add_argument("-n", "--numberOfThread", type=int, help="The threads used, default = 8")	
	
	args = parser.parse_args()
	
	if args.in_volume_file != None:
		in_volume_file = args.in_volume_file;
	if args.in_source_path != None:
		in_source_path = args.in_source_path;
	if args.out_warp_path != None:
		out_warp_path = args.out_warp_path;
	if  args.out_template_path != None:
		out_template_path = args.out_template_path;
	if args.phase_number != None:
		phase_number = args.phase_number;
	if args.numberOfThread != None:
		numberOfThread = args.numberOfThread;
	if args.iterNumber != None:
		iterNumber = args.iterNumber;

def checkInput():
	global in_volume_file,in_source_path,out_warp_path,out_template_path,phase_number;	
	print "Command line is ok:"
	print "================ parameters ======================="
	print "Volume File:	",in_volume_file
	print "Subject Image:	",in_source_path
	print "Warped Path:	",out_warp_path
	print "Output Path:	",out_template_path
	print "Phase Number:	",phase_number


def ensure_dir(r):
	d = os.path.dirname(r);
	if not os.path.exists(d):
		os.makedirs(d);

def makeOutputDirs():
	global out_warp_path,out_template_path
	ensure_dir(out_warp_path+"/Template1/");
	ensure_dir(out_warp_path+"/Template2/");
	ensure_dir(out_template_path+"/");

def dirTempPath(groupId):
	global out_warp_path
	return out_warp_path+"/Template"+str(groupId)+"/";

def writeGroupingCSV(id_sys,wt_sys,id_dia,wt_dia):
	global out_warp_path;
	with open(out_warp_path+'/LV_phase_groups.csv','wb') as csvfile:
		writer = csv.writer(csvfile, delimiter=' ')
		writer.writerow(id_sys);
		writer.writerow(wt_sys);
		writer.writerow(id_dia);
		writer.writerow(wt_dia);

def readVolumenSCV(filename):
	# Read the volume info csv files
	# line 1 is a list of phase ids
	# line 2 is a list of volumes
	with open(filename,'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=' ')
		lst_read = list(reader);
		lst1 = [int(x) for x in lst_read[0]]
		lst2 = [float(x) for x in lst_read[1]]
	return (lst1,lst2)

def getTemplatesWeightsHelper(volumes,groupId,normOnly):
	max_volume_value = max(volumes);
	min_volume_value = min(volumes);
	max_min_range = max_volume_value - min_volume_value;
	if groupId == 1:
		if normOnly == 0:
			wt_raw =[ float(pow(max_volume_value-x,2)) for x in volumes];
		else:
			wt_raw = volumes;
		wt_norm = [ float(x) / sum(wt_raw) for x in wt_raw];
	else:
		if normOnly == 0:
			wt_raw =[ float(pow(x-min_volume_value,2)) for x in volumes];
		else:
			wt_raw = volumes;
		wt_norm = [ float(x) / sum(wt_raw) for x in wt_raw];		
	return wt_norm;

def getTemplatesWeights(volumes):
	# Compute the weights of the systolic template
	# return two lists of weights (systolic, diastolic)

	max_volume_value = max(volumes);
	min_volume_value = min(volumes);
	max_min_range = max_volume_value - min_volume_value;
	
	wt_sys = getTemplatesWeightsHelper(volumes,1,0);
	
	wt_dia = getTemplatesWeightsHelper(volumes,2,0);	
	
	return  (wt_sys,wt_dia);

def computeAvgImage(iterId,groupId,weights,phaseArray):
	# Weighted average up all the images in the group
	global in_source_path,out_warp_path
	print "Averaging weighted images"
	
	out_img = dirTempPath(groupId)+"/avg"+str(iterId)+".nii.gz"

	cmd_make_zeroSum = "CreateImage 3 "+in_source_path+"/phase1.nii "+out_img+" 0 "
	os.system(cmd_make_zeroSum);

	#Sum up weighted images
	for i in xrange(len(phaseArray)):
		print "Phase:		***	"+str(i+1)+" / "+str(len(phaseArray))+"	***"
		p = phaseArray[i];
		w = weights[i];
		if iterId == 0:
			in_img = in_source_path+"/phase"+str(p)+".nii"
		else:
			in_img = dirTempPath(groupId)+"/reg"+str(p)+"Warped.nii.gz"

		weighted_img = dirTempPath(groupId)+"/weighted.nii.gz"
		cmd_make_weighted = "ImageMath 3 "+weighted_img+" m "+in_img+" "+str(w);
		os.system(cmd_make_weighted);
		
		cmd_sum_up = "ImageMath 3  "+out_img+" + "+out_img+" "+weighted_img
		os.system(cmd_sum_up)

	# Sharpen Image
	print "Sharpening Image"
	cmd_sharpen = "ImageMath 3 "+out_img+" Sharpen "+out_img
	os.system(cmd_sharpen)
	

def registrationImage(fixedImage,movingImage,phaseId,outPath,iterId,numberOfThread,transformTypes):
	# Register source image to target image
	global iterNumber
	prefix=outPath+"/reg"+str(phaseId);
	regCommand=" -d 3 -t "+transformTypes+" -f "+fixedImage+" -m "+movingImage+" -o "+prefix+" -n "+str(numberOfThread)
	if iterId == iterNumber:
		os.system("antsRegistrationSyNPlus.sh "+regCommand)
	else:
		os.system("antsRegistrationSyNQuick.sh "+regCommand)

def batchRegistration(iterId,groupId,phase_array):
	# Register all images in the group the the average mean template
	global in_source_path,out_warp_path, numberOfThread,transformTypes
	fixedImage = dirTempPath(groupId)+"/avg"+str(iterId)+".nii.gz"

	for p in phase_array:
		movingImage = in_source_path+"/phase"+str(p)+".nii"
		registrationImage(fixedImage,movingImage,p,dirTempPath(groupId),iterId,numberOfThread,transformTypes)

def dualPhaseArrays(ids,wt_sys,wt_dia):
	# Remove phases in list whose weights is less than a threshold
	global CONST_WEIGHT_THRESHOLD
	print "Phases weights threshold "+str(CONST_WEIGHT_THRESHOLD)
	wt_sys_cut = [];
	wt_dia_cut = [];
	id_sys_cut = [];
	id_dia_cut = [];
	for i in xrange(len(ids)):
		if (wt_sys[i] > CONST_WEIGHT_THRESHOLD):
			wt_sys_cut.append(wt_sys[i]);
			id_sys_cut.append(ids[i]);
		if (wt_dia[i] > CONST_WEIGHT_THRESHOLD):
			wt_dia_cut.append(wt_dia[i]);
			id_dia_cut.append(ids[i]);

	# Normalize
	wt_sys_cut = getTemplatesWeightsHelper(wt_sys_cut,1,1);
	wt_dia_cut = getTemplatesWeightsHelper(wt_dia_cut,2,1);

	# Remove duplicate phases
	duplicate_ids = [x for x in id_sys_cut if x in id_dia_cut];
	for p in duplicate_ids:
		index_in_sys_list = id_sys_cut.index(p)
		index_in_dia_list = id_dia_cut.index(p)
		if (wt_sys_cut[index_in_sys_list] > wt_dia_cut[index_in_dia_list]):
			del wt_dia_cut[index_in_dia_list];
			del id_dia_cut[index_in_dia_list];
		else:
			del wt_sys_cut[index_in_sys_list];
			del id_sys_cut[index_in_sys_list];
	wt_sys_cut = getTemplatesWeightsHelper(wt_sys_cut,1,1);
	wt_dia_cut = getTemplatesWeightsHelper(wt_dia_cut,2,1);

	return (id_sys_cut,wt_sys_cut,id_dia_cut,wt_dia_cut);

def listFormat(list):
	return [float("{0:.5f}".format(x)) for x in list]

def copyTemplates():
	global out_warp_path, out_template_path,iterNumber;
	for i in xrange(2):
		temp_warp_path = dirTempPath(i+1);
		shutil.copyfile(temp_warp_path+"/avg"+str(iterNumber)+".nii.gz", out_template_path+"/Template"+str(i+1)+".nii.gz");


def main():
	global iterNumber,phase_number,in_volume_file,out_warp_path
	start_time = time.time();
	init();

	#Read in volumes
	(ids,volumes) = readVolumenSCV(in_volume_file);

	print "Left Ventricle volumes reading finished."
	print "Phases:	", ids
	print "Volumes:	", listFormat(volumes)

	# Weights computation
	(wt_sys, wt_dia) = getTemplatesWeights(volumes);
	(id_sys,wt_sys,id_dia,wt_dia) = dualPhaseArrays(ids,wt_sys,wt_dia);
	writeGroupingCSV(id_sys,wt_sys,id_dia,wt_dia);

	print "Weights computing finished."
	print "Systolic:	"
	print "Phases Id:	", id_sys
	print "Weights:	", listFormat(wt_sys)
	print "Diastolic:	"
	print "Phases Id:	", id_dia
	print "Weights:	", listFormat(wt_dia)

	#Registration towards unbiased template
	#	Systolic
	print "Processing systolic cardiac phases"	
	for i in xrange(iterNumber):
		print "Iteration: #"+str(i)
		computeAvgImage(i,1,wt_sys,id_sys);
		batchRegistration(i,1,id_sys);
	computeAvgImage(iterNumber,1,wt_sys,id_sys);

	# 	Diastolic
	print "Processing diastolic cardiac phases"	
	for i in xrange(iterNumber):
		print "Iteration: #"+str(i)
		computeAvgImage(i,2, wt_dia,id_dia);
		batchRegistration(i,2,id_dia);
	computeAvgImage(iterNumber,2,wt_dia,id_dia);	

	end_time = time.time();
	print "Total Elapsed Time: "+str(end_time - start_time)+"s"
	with open(out_warp_path+"/timing.txt","w") as timing_file:
		timing_file.write("Elapsed time: "+str(end_time - start_time)+"s")

	print "Copying file to ouput directory"
	copyTemplates()
	print "Finished."

if __name__ == '__main__':
    main();