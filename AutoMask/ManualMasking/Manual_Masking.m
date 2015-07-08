subjectId = 6;
folder_name = [pwd '/output/'];
mkdir(folder_name);
mask_manual = write_mask_192short_hull(ims_sum);
ims_sum = nmlz(ims_sum)*1024;
save_nii(make_nii(uint16(mask_manual)),[folder_name sprintf('mask%d.nii',subjectId)]);
save_nii(make_nii(uint16(ims_sum)),[folder_name sprintf('img%d.nii',subjectId)]);