import shutil

def makeSingleTemplate(INPUTPATH,OUTPUTPATH,ITERATION):
	cmd_single_template = "./unbiasedTemplate.sh -i "+INPUTPATH+" -o "+OUTPUTPATH+" -i "+ITERATION;
	print cmd_single_template

def segTargetImage(INPUTPATH,OUTPUTPATH,TARGETIMG,MASKIMG):
	cmd_seg_single = "./regToTarget.sh -i "+INPUTPATH+" -o "+OUTPUTPATH+" -t "+TARGETIMG+" -x "+MASKIMG
	print cmd_seg_single

def calculateLabelVolume(INPUTPATH):
	cmd_label_volume = "./labelVolume.sh -i "+INPUTPATH
	print cmd_label_volume

def inverseTransSingleTemplate(WARPPATH,OUTPUTPATH,TEMPLABELIMG):
	cmd_inverse_trans_single = "./inverseTrans.sh -w "+WARPPATH+" -o "+OUTPUTPATH+" -l "+TEMPLABELIMG
	print cmd_inverse_trans_single

def makeDualTemplate(in_volume_file,in_source_path,out_warp_path,out_template_path):	
	cmd_dualTemplate = "python WeightedDualTemplate.py -v "+in_volume_file+" -i "+in_source_path+" -w "+out_warp_path+" -o "+out_template_path
	print cmd_dualTemplate

def inverserTransDualTemplates(in_groups_file,in_template_path,in_warp_path,out_seg_path):
	cmd_inverse_trans_dual = "python DualInverseTransform.py -g "+in_groups_file+" -i "+in_template_path+" -w "+in_warp_path+" -o "+out_seg_path
	print cmd_inverse_trans_dual;

def copyDualLabelFiles(dual_seg_path1,dual_seg_path2,dual_temp_path):
	shutil.copyfile(dual_seg_path1+"/Label.nii.gz",dual_temp_path+"/Label1.nii.gz");
	shutil.copyfile(dual_seg_path2+"/Label.nii.gz",dual_temp_path+"/Label2.nii.gz");

def waitForInput():
	try:
		input("Press enter to continue process")
	except SyntaxError:
		print " Continue process"

def main():
	global in_target_phases_path,in_atlas_path,out_interm_path,out_seg_path,iter1,iter2
	
	# Single Template
	single_atlas_path = in_atlas_path+"/Single/"
	single_maskImg = single_atlas_path+"/sumMask.nii";
	single_temp_path = out_interm_path+"/SingleTemplate/" 
	single_seg_path = out_interm_path+"/SingleSeg/"
	single_out_path = out_interm_path+"/SingleOut/"
	single_temp_img = single_temp_path+"/avg"+str(iter1)+".nii"

	
	makeSingleTemplate(in_target_phases_path,single_temp_path,iter1);
	
	segTargetImage(single_atlas_path,single_seg_path,single_temp_img,single_maskImg);
	
	single_temple_labelImg = single_seg_path+"/Label.nii.gz"
	inverseTransSingleTemplate(single_temp_path,single_out_path,single_temple_labelImg);
	calculateLabelVolume(single_out_path);

	single_template_volume_files = single_out_path+"/Volumes/LV_volume.csv"
	
	# Dual templates
	dual_atlas_path1 = in_atlas_path+"/Systolic/"
	dual_atlas_path2 = in_atlas_path+"/Diastolic/"
	dual_maskImg1 = dual_atlas_path1+"/sumMask.nii";
	dual_maskImg1 = dual_atlas_path2+"/sumMask.nii";
	dual_temp_path = out_interm_path+"/DualTemplates/"
	dual_temp_img1 = dual_temp_path+"/Template1.nii.gz"
	dual_temp_img2 = dual_temp_path+"/Template2.nii.gz"
	dual_seg_path1 = out_interm_path+"/DualSeg1/"
	dual_seg_path2 = out_interm_path+"/DualSeg2/"
	dual_out_path = out_interm_path+"/Output/"
	
	dual_temp_img1 = dual_temp_path+"/Template1.nii.gz"
	dual_temp_img2 = dual_temp_path+"/Template2.nii.gz"
	makeDualTemplate(single_template_volume_files,in_target_phases_path,dual_temp_path,dual_temp_path)
	
	# Systolic
	segTargetImage(dual_atlas_path1,dual_seg_path1,dual_temp_img1,dual_maskImg1);
	# Dialostic
	segTargetImage(dual_atlas_path2,dual_seg_path2,dual_temp_img2,dual_maskImg2);
	
	inverserTransDualTemplates();
	calculateLabelVolume();


if __name__ == '__main__':
	main()