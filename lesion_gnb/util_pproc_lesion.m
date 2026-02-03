%% Run post-processing on lesion class label volumes
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham
% Department of Psychology. 
% Use at own risk. 
function util_pproc_lesion(cfg)

spm_jobman('initcfg');
data_dir = cfg.data; % path to directory containing subject folders with normalized segmentations obtained from the New Segment tool in SPM12.
out_dir = cfg.out; % path to directory where feature maps will be saved
fwhm = cfg.fwhm; % smoothing kernel width (applied to both the prior probability maps and the normalized segmentations)

% set appropriate directories
util_dir = fileparts(which('spm'));
addpath(util_dir);
if isempty(util_dir) == 1
    disp('ERROR: SPM directory not found. Add SPM directory to path');
end
mn_dir = fullfile(util_dir,'toolbox','lesion_gnb', 'matlab_nifti');
addpath(mn_dir);
tpm_dir = fullfile(util_dir, 'toolbox', 'lesion_gnb', 'volume_files');
addpath(tpm_dir);

lesion_dir = fullfile(data_dir, out_dir);
cd(lesion_dir);
% If smoothing is selected
if isempty(cfg.fwhm) == 0 && cfg.fwhm > 0
    pproc_smooth = fwhm;
    disp(['Smoothing lesion labels at ' num2str(pproc_smooth) ' FWHM']);
    my_smooth_spm(fullfile(pwd, 'lesion_labels.nii'), [pproc_smooth pproc_smooth pproc_smooth], cfg.im_mask); % smooth lesion label volume
    my_smoothed = load_nii(['s' num2str(pproc_smooth) 'lesion_labels.nii']); % load smoothed volume
    my_smoothed.img(my_smoothed.img <= 0.25) = 0;
    my_smoothed.img(my_smoothed.img > 0) = 1; % threshold to retain voxels with values > 0.25
    save_nii(my_smoothed, ['s' num2str(pproc_smooth) 'lesion_labels.nii']); % save smoothed/binarized class labels
else
    disp('Smoothing kernel width not selected: lesion class labels will not be smoothed');
end
% If cluster threshold is selected
if isempty(cfg.clust) == 0 && cfg.clust > 0
    pproc_cluster = cfg.clust;
    disp(['Cluster thresholding lesion labels at ' num2str(pproc_cluster) ' voxels/cluster']);
    if pproc_smooth == 0 % load lesion labels 
        my_lesion = load_nii('lesion_labels.nii');
    else
        my_lesion = load_nii(['s' num2str(pproc_smooth) 'lesion_labels.nii']);
    end
    [k, my_lesion.img] = distance_cluster(my_lesion.img, 26); % define clusters based on 26-voxel neighborhoods
    my_lesion.img(my_lesion.img < pproc_cluster) = 0; % remove all clusters smaller than the cluster theshold
    my_lesion.img(my_lesion.img > 0) = 1; % binarize remaining voxels.
    save_nii(my_lesion, [my_lesion.fileprefix '_clustered_' num2str(pproc_cluster) '.nii']); % save final lesion mask
else
    disp('Minimum cluster size not selected, no cluster thresholding will be performed');
end

disp('Lesion creation complete. It is recommended that the final lesion masks be visually inspected to ensure accuracy.');

end