import sys, argparse,os,time,shutil

def init():
	global ms_path,as_path,rd,iteration,rate,rf,output_path, atlas_size ,target_id
	ms_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Atlas/Template1"
	as_path="/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Template1"
	target_id = 1;
	atlas_size = 5
	rd = 5
	iteration = 1000;
	rate  = 0.2
	rf = "2x2x2"
	output_path = "/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DTLOO/Test1/Correction/Template1"

	inputParser();
	makeOutputDirs();


def inputParser():
	global ms_path,as_path,rd,iteration,rate,rf,target_id,output_path
	parser = argparse.ArgumentParser(description='Corrective learning and applying classifiers')
	parser.add_argument("-t", "--target_id", type=int, help="Leave One Out test target image number.");
	parser.add_argument("-ms","--ms_path",type=str,help="Manual segmentation path");
	parser.add_argument("-as","--as_path",type=str,help="Automatical segmentation path");
	parser.add_argument("-o", "--output_path",type=str, help="Output Path");

	args = parser.parse_args()

	if args.target_id != None:
		target_id = args.target_id;
	if args.ms_path != None:
		ms_path = args.ms_path;
	if args.as_path != None:
		as_path = args.as_path;
	if args.output_path != None:
		output_path = args.output_path;

def ensure_dir(r):
	d = os.path.dirname(r);
	if not os.path.exists(d):
		os.makedirs(d);

def makeOutputDirs():
	global output_path
	ensure_dir(output_path+"/");

def makeStr(path, prefix, suffix, atlas_size,target_id):
	imgs_str = "";
	for index in xrange(atlas_size):
		i  = index + 1;
		if i == target_id:
			continue;
		imgs_str = imgs_str + " " + path + "/" + prefix + str(i) + suffix + ".nii.gz"
	return imgs_str;

def makeFeatureStr(ms_path,as_path,labelId):
	f_str = "";
	for index in xrange(atlas_size):
		i  = index + 1;
		if i == target_id:
			continue;
		f_str = f_str + " "+makeFeautrePair(ms_path,as_path,"000"+str(labelId),i);
	return f_str;

def makeFeautrePair(ms_path,as_path,labelStr,i):
	return ms_path+"/img"+str(i)+".nii.gz"+" "+as_path+"/joint"+str(i)+"_p"+labelStr+".nii.gz"

def BL():
	global ms_path,as_path,rd,iteration,rate,rf,output_path,target_id
	ms_imgs = makeStr(ms_path,"label","",atlas_size,target_id);
	as_imgs = makeStr(as_path,"joint","",atlas_size,target_id);	
	output_prefix = output_path+"/joint_bl_img"+str(target_id);
	for l in xrange(3):
		f_str = makeFeatureStr(ms_path,as_path,l);
		cmd_str = "bl 3 -ms "+ms_imgs+" -as "+as_imgs+" -tl "+str(l)+" -rd "+str(rd)+" -i "+str(iteration)+" -rate "+str(rate)+" -rf "+rf+" -c 2 -f "+f_str+" "+output_prefix

		os.system(cmd_str);

def SA():
	global ms_path,as_path,rd,iteration,rate,rf,output_path,target_id
	as_img = as_path+"/joint"+str(target_id)+".nii.gz";
	BL_prefix = output_path+"/joint_bl_img"+str(target_id);
	output_img = output_path+"/joint_cl"+str(target_id)+".nii.gz"
	f_str = makeFeautrePair(ms_path,as_path,"\\%04d",target_id);

	cmd_str = "sa "+as_img+" "+BL_prefix+" "+output_img+" -f "+f_str
	os.system(cmd_str)

def main():
	global output_path;
	start_time = time.time();
	init();

	BL();
	SA();

	end_time = time.time();
	print "Total Elapsed Time: "+str(end_time - start_time)+"s"
	with open(output_path+"/timing"+str(target_id)+".txt","w") as timing_file:
		timing_file.write("Elapsed time: "+str(end_time - start_time)+"s")

if __name__ == '__main__':
    main();
