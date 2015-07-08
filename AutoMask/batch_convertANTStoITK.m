function batch_convertANTStoITK(ANTsOutFoldername,textOutputFolder,cardiacNums,respiratoyNums)
% Batch Conver all Registration result to Jianing' program input format
% Usage:
%  batch_convertANTStoITK('/Affine/','/Output/',[1:9],[1:5])
%  batch_convertANTStoITK('/Affine/','/Output/',[4],[1:5])
%  
% Yuhua Chen
% 6/2/2015

for cardiacPhase = cardiacNums
    for respiratoryPhase = respiratoyNums
        inputFolername = [ANTsOutFoldername];
        inputFileName = sprintf('%s/regc%dr%d0GenericAffine.mat',inputFolername,cardiacPhase,respiratoryPhase);
        outputFolderName = sprintf('%s/moco_cardiac%d',textOutputFolder,cardiacPhase);
        outputFileName = sprintf('%s/affine_output_mask%d.txt',outputFolderName,respiratoryPhase);
        mkdir(outputFolderName);
        convertANTSToITK(inputFileName,outputFileName);
    end
end