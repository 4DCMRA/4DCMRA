% MATLAB script for manual heart masking
% Jianing Pang 05/2015
ind = 6;
%%
ind = ind+1;
folder_name = uigetdir;
folder_name = [folder_name,'/'];
file_header = 'moco_cardiac';
% file_header = 'motion correction cardiac';
n_cardiac_phases = 9;
n_bins_si = 5;
if(~exist([folder_name,'ims_sum.mat'],'file'))
    fprintf('\n');
    ims = zeros(192,192,192,n_bins_si,n_cardiac_phases);
    moco_dirs = strcat(repmat(strcat(folder_name,file_header),9,1),num2str([1:9].'),repmat('/',9,1));
    tic;
    for cardiac_ind = 1:n_cardiac_phases
        for resp_ind = 1:n_bins_si
            save_fname = strcat(moco_dirs(cardiac_ind,:),'moving',num2str(resp_ind),'/');
            for n = 1:192
                if(n<10)
                    ims(:,:,n,resp_ind,cardiac_ind) = imread(strcat(save_fname,'00',num2str(n),'.jpeg'));
                elseif (n < 99)
                    ims(:,:,n,resp_ind,cardiac_ind) = imread(strcat(save_fname,'0',num2str(n),'.jpeg'));
                else
                    ims(:,:,n,resp_ind,cardiac_ind) = imread(strcat(save_fname,num2str(n),'.jpeg'));
                end
            end
        end
    end
    ims = nmlz(ims);
    ims_sum = sum(sum(ims,5),4);
    save(strcat(folder_name,'ims_sum.mat'),'ims_sum','-v7.3');
    toc;
else
    load([folder_name,'ims_sum.mat']);
end
save_nii(make_nii(uint16(nmlz(ims_sum)*1024)),['im',num2str(ind),'.nii']);
%
if(exist(strcat(folder_name,'mask_manual.mat'),'file'))
    load(strcat(folder_name,'mask_manual.mat'));
else
    %mask_manual = write_mask_192short_hull(folder_name,ims_sum);
    %save(strcat(folder_name,'mask_manual.mat'),'mask_manual','-v7.3');
end
%save_nii(make_nii(uint16(nmlz(mask_manual)*1024)),['mask',num2str(ind),'.nii']);
