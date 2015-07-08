function convertANTSToITK(ANTSFilename,ITKFilename)
% Convert ANTS affine output .mat file to Jianing' Program order
% Usage:
%   convertANTSToITK('regc4r10GenericAffine.mat','affine_output_mask1.txt');
% Yuhua Chen
    load(ANTSFilename);
    txtStr = '';
    fid = fopen(ITKFilename,'w');
    for i = 1:3
        txtStr = [txtStr ' ' num2str(fixed(i))];
    end
    for i = 10:12
        txtStr = [txtStr ' ' num2str(AffineTransform_double_3_3(i))];
    end        
    for i = 1:9
        txtStr = [txtStr ' ' num2str(AffineTransform_double_3_3(i))];
    end
    fprintf(fid,txtStr);
end