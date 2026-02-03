%% Apply trained/cross-validated GNB classifier to assign lesion class labels.
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology.
% Use at own risk. 
function util_classify_lesion(cfg)
% This function inputs feature maps created by util_extract_features.m 
% to a trained and validated gaussian naive bayes (GNB) classifer object 
% to classify voxels corresponding to stroke lesions. 
%
% Input: cfg structure variable containing fields shown below (input and
% output directories). 
%
% Output: binary nifti files containing binary lesion class labels (lesion = 1; lesion_labels.nii) and continuous posterior
% probability maps (lesion_posterior.nii).

data_dir = cfg.data; % path to directory containing feature maps.
out_dir = cfg.out;
% set appropriate directories
util_dir = fileparts(which('spm'));
addpath(util_dir);

mn_dir = fullfile(util_dir,'toolbox','lesion_gnb', 'matlab_nifti');
addpath(mn_dir);
tpm_dir = fullfile(util_dir,'toolbox', 'lesion_gnb', 'volume_files');
addpath(tpm_dir);
gnbc_path = fullfile(util_dir,'toolbox', 'lesion_gnb', 'trained_gnbc');
load(fullfile(gnbc_path, 'predict_lesion.mat'));
predict_lesion.Prior = cfg.priors; %[0.8936    0.1064] original priors

% classify lesion voxels
disp(['Determining voxel class labels']);
cd(fullfile(data_dir,out_dir));
load('my_features.mat');
load('my_ind.mat');

[labels posterior] = predict(predict_lesion, my_features);
temp = load_nii(fullfile(data_dir, out_dir, 'f1.nii'));
temp.img(:,:,:) = 0;
temp.img(my_ind) = posterior(:,2);
save_nii(temp, 'lesion_posterior.nii');

temp.img(:,:,:) = 0;
temp.img(my_ind) = labels;
save_nii(temp, 'lesion_labels.nii');

end
