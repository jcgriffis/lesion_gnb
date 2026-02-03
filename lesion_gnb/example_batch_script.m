%% This file contains an example of a batch script that could be used to perform the tissue segmentation, feature map creation, lesion classification, and post-processing for a group of patients.
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology.
% Use at own risk. 
%% SPM12 segmentation of T1w scans
clc
clear all
% set appropriate paths
my_spm_path = ('/Users/this_user/Documents/MATLAB/spm12'); 
addpath(my_spm_path);
addpath(fullfile(my_spm_path,'toolbox', 'lesion_gnb'));
% define directory containing patient folders with t1w scans
data_dir = '/Users/this_user/Documents/Patient_Files';
cd(data_dir);

my_patients = dir('Patient*'); % use wildcard to identify patient folders

for i = 1:length(my_patients) % loop through patient folders
    cfg.data = fullfile(data_dir, my_patients(i).name); % cfg field for directory containing the patient's T1w scan 
    cd(cfg.data); 
    my_t1 = dir('*.nii'); % use wildcard to identify scan volume
    cfg.t1 = my_t1(1).name; % cfg field for t1w scan file  
    util_run_segmentation(cfg); % run new segmentation with default parameters.
end
%% Create feature maps, assign voxel class labels, and apply post-processing
clc
clear all
% set appropriate paths
my_spm_path = ('/Users/this_user/Documents/MATLAB/spm12'); 
addpath(my_spm_path);
addpath(fullfile(my_spm_path,'toolbox', 'lesion_gnb'));
% define directory containing patient folders with t1w scans
data_dir = '/Users/this_user/Documents/Patient_Files';
cd(data_dir);

my_patients = dir('Patient*'); % use wildcard to identify patient folders

for i = 1:length(my_patients) % loop through patient folders
    cd(fullfile(data_dir, my_patients(i).name));
    cfg.data = fullfile(data_dir, my_patients(i).name); % cfg field for directory containing the patient's segmented T1w scan
    cfg.out = 'Lesion_Mask_TPM_L'; % cfg field specifying output directory (will be created in each patient folder)
    cfg.fwhm = 8; % cfg field specifying smoothing kernel width (FWHM) to apply to TPMs/PPMs during feature map creation
    cfg.im_mask = 0; % use implicit mask when smoothing -- default is off for feature map creation
    cfg.priors = [0.89 0.11]; % [0.5 0.5]assumes equal prior probability for each tissue class. Original priors as determined by voxel class frequencies for training dataset (across all 30 patients) are [0.8936 0.1064] for non-lesion and lesion tissue class voxels, respectively (default).
    cfg.affected = 'L'; % cfg field specifying affected hemisphere (L or R)
    cfg.ppm_only = 'N'; % cfg field specifying whether to construct feature maps using both unaffected hemisphere TPM and PPM volumes (N) or using only PPM volumes (Y)
    util_extract_features(cfg); % run feature map creation (outputs feature maps f1.nii and f2.nii, as well as predictor matrix my_features.mat and in-mask voxel index file my_ind.mat)
    util_classify_lesion(cfg); % use trained/cross-validated GNB classifier to predict class labels (outputs binary lesion class label volume lesion_labels.nii and continous posterior probability volume lesion_posterior.nii)
    cfg.fwhm = 8; % cfg field specifying smoothing kernel width (FWHM) to apply to binary lesion class labels (smoothed labels will be thresholded to retain values > 0.25)
    cfg.clust = 100; % cfg field specifying minimum cluster size to retain in final lesion mask
    cfg.im_mask = 0; % use implicit masking when smoothing -- default is off for post-processing.
    util_pproc_lesion(cfg); % run post-processing (outputs post-processed lesion mask volumes. Prefix 'sFWHM' (e.g. s8) indicates smoothing kernel used. Suffix _K (e.g _100) indicates minimum cluster size retained (example output name: s8lesion_labels_100.nii);
end
%% Re-run segmentation using smoothed lesion probability map as additional prior
                                                   
clc
clear all
set appropriate paths
my_spm_path = ('/Users/this_user/Documents/MATLAB/spm12'); 
addpath(my_spm_path);
addpath(fullfile(my_spm_path,'toolbox', 'lesion_gnb'));
define directory containing patient folders with t1w scans
data_dir = '/Users/this_user/Documents/Patient_Files';;
cd(data_dir);

my_patients = dir('Patient*'); % use wildcard to identify patient folders

for i = 1:length(my_patients) % loop through patient folders
    cd(fullfile(data_dir, my_patients(i).name));
    t1_c1 = dir('c1*.nii');
    my_t1 = t1_c1(1).name(3:length(t1_c1(1).name));
    cfg.data = fullfile(pwd); % cfg field for directory containing the patient's segmented T1w scan
    cfg.t1path = fullfile(pwd, my_t1); % cfg field with path to t1w scan file  
    cfg.t1name = my_t1;
    cd(fullfile(pwd,'Lesion_Mask_TPM_L')); % directory containing extra prior
    my_smooth_spm('s8lesion_labels_clustered_100.nii', [8 8 8]);
    cfg.lpdir = pwd; % cfg field specifying output directory from lesion mask creation 
    cfg.lp = 's8s8lesion_labels_clustered_100.nii'; %additional tissue prior (i.e. smoothed final mask or lesion probability map (final mask reccomended))
    cfg.out = 'LP_Seg'; % output directory
    util_run_segmentation_lp(cfg);
end
                                                   
%% Normalize Patient T1 scans
clc
clear all
% set appropriate paths
my_spm_path = ('/Users/this_user/Documents/MATLAB/spm12'); 
addpath(my_spm_path);
addpath(fullfile(my_spm_path,'toolbox', 'lesion_gnb'));
% define directory containing patient folders with t1w scans
data_dir = '/Users/this_user/Documents/Patient_Files';
cd(data_dir);

my_patients = dir('Patient*'); % use wildcard to identify patient folders

for i = 1:length(my_patients) % loop through patient folders
    cd(fullfile(data_dir, my_patients(i).name));
    my_dfm = dir('y*.nii'); %get deformation field file
    matlabbatch=[];
    my_norm = fullfile(pwd, t1_file(1).name);
    % run normalization
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = cellstr(my_dfm(1).name);
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = cellstr(my_norm);
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1.5 1.5 1.5];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 1;
    spm_jobman('run',matlabbatch);
end

%% Reverse normalize lesion masks back to patients' native space
clc
clear all
% set appropriate paths and intialize SPM
my_spm_path = ('/Users/this_user/Documents/MATLAB/spm12'); % define path to SPM
addpath(my_spm_path);
addpath(fullfile(my_spm_path,'toolbox', 'lesion_gnb'));
spm('Defaults','fMRI');
spm_jobman('initcfg');
data_dir = '/Users/this_user/Documents/Patient_Files';
cd(data_dir);

my_patients = dir('Patient*'); % use wildcard to identify patient folders

for i = 1:length(my_patients) % looping through patient folders
    
    scan_dir = fullfile(data_dir, my_patients(i).name); % define folder with t1 scan
    cd(scan_dir) % cd to scan folder 
    
    transform_file = dir('iy*.nii'); % use wildcard to select inverse deformation field 
    my_field = transform_file(1).name; % create deformation field variable
    mask_dir = (fullfile(scan_dir, 'Lesion_Mask')); % define lesion mask location
    cd(mask_dir);
    my_mask = 's8lesion_labels_clustered_100.nii'; % name of image volume that is being reverse normalized
    matlabbatch=[];
    matlabbatch{1}.spm.util.defs.comp{1}.def = {fullfile(scan_dir, my_field)}; % file path for inverse deformation field
    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {fullfile(mask_dir, my_mask)}; % file path for reverse normalization
    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.savepwd = 1; % save in current directory 
    matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 7; %7th degree b-spline interpolation (values 4-7 can be used for 4th to 7th degree b-spline)
    matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 0; % no implicit masking 
    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0]; % Gaussian smoothing kernel FWHM (can be applied to mask e.g. 8 8 8)
    spm_jobman('run',matlabbatch); % run job
end