function save_bin_nii(ims,foldername)
% Usage
% save_bin_nii(ims,foldername)
% ims:              ims from Pixel_Masking
% foldername:       name of the output folder
%
% Yuhua Chen
% 5/31/2015
resBins = size(ims,4);
carBins = size(ims,5);
for res = 1:resBins
    for car = 1:carBins
        img = make_nii(uint16(ims(:,:,:,res,car)*1024));
        save_nii(img,[foldername,'/','imgc',num2str(car),'r',num2str(res),'.nii']);
    end
end
