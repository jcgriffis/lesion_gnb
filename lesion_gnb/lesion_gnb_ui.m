%% Basic user interface for single patient tissue segmentation, feature map creation, lession classification, and post-procesing.
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology.
% Use at own risk. 
function lesion_gnb_ui
% This function provides a basic user interface for predicting lesion maps
% for individual patients, and includes options for post-processing steps
% (smoothing binarized lesion class labels and applying cluster size
% thresholds to binarized lesion class labels). 
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology. 

cfg = [];
disp(['T1 Lesion classification using Gaussian Naive Bayes: Single patient user interface'])
disp(['Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology']);
disp(['Please cite this toolbox as Griffis et al., 2015']);

run_seg = inputdlg({'Run tissue segmentation with default parameters? (Y/N)'});
if strcmp(run_seg, 'Y') == 1
    disp('Select directory containing the T1 weighted scan that you want to segment');
    cfg.data = uigetdir(pwd, 'Select scan directory (segmentations will be created within scan directory)');
    cfg.t1 = uigetfile(cfg.data, 'Select scan file');
    util_run_segmentation(cfg);
    clear cfg
end
    
disp(['Step 1: Select directory containing the normalized GM/WM/CSF tissue segmentations for this patient.']);
cfg.data = uigetdir(pwd, 'Select directory containing segmentations');
disp(['Patient directory selected']);

prompt = {'Enter name of output directory (will be created in patient directory)', 'Enter affected hemisphere (L/R)', 'Enter desired smoothing kernel FWHM for feature map creation (e.g. 8)', 'Use unaffected hemisphere for feature map creation (Y/N)' 'Prior Lesion Probabilities (default = 0.5)' 'Implicit mask for smoothing (default = 0)' };
name = 'Input for feature map creation';
numlines = 1;
default_answer = {'Lesion_Mask', '',  '8', 'Y', '0.5' '0'};
my_answers = inputdlg(prompt, name, numlines, default_answer);
if strcmp(my_answers{4}, 'Y') == 1
    cfg.ppm_only = 'N';
elseif strcmp(my_answers{4}, 'N') == 1
    cfg.ppm_only = 'Y';
end
cfg.out = my_answers{1};
cfg.affected = my_answers{2};
cfg.fwhm = str2num(my_answers{3});
cfg.priors = [1-str2num(my_answers{5}) str2num(my_answers{5})];
cfg.im_mask = str2num(my_answers{6});

util_extract_features(cfg);

disp('Obtaining predicted lesion delineation');

util_classify_lesion(cfg);

cfg.pproc = inputdlg({'Finished predicting lesion delineation. Apply post-processing (recommended)? (Y or N)'}, 'Post-processing'); 

if strcmp(cfg.pproc, 'N') == 1
    disp('No post-processing selected, process complete.');
elseif strcmp(cfg.pproc, 'Y') == 1
    pproc_smooth = inputdlg({'Enter Smoothing Kernel in FWHM (reccomended: 8). Set 0 for no smoothing'});
    pproc_smooth = cell2mat(pproc_smooth);
    pproc_smooth = str2num(pproc_smooth);
    if pproc_smooth ~= 0 
        pproc_im = inputdlg({'Use implicit masking? (1 = yes, 0 = no)'});
        cfg.im_mask = cell2mat(pproc_im);
        cfg.im_mask = str2num(cfg.im_mask);
    end
    
    if pproc_smooth == 0
        disp('Smoothing kernel not selected, no smoothing will be performed');
    else
        disp(['Smoothing lesion labels at ' num2str(pproc_smooth) ' FWHM']);
        cd(fullfile(cfg.data,cfg.out));
        my_smooth_spm(fullfile(pwd, 'lesion_labels.nii'), [pproc_smooth pproc_smooth pproc_smooth], cfg.im_mask);
        my_smoothed = load_nii(['s' num2str(pproc_smooth) 'lesion_labels.nii']);
        my_smoothed.nii(my_smoothed.img <= 0.25) = 0;
        my_smoothed.nii(my_smoothed.img > 0) = 1;
        save_nii(my_smoothed, ['s' num2str(pproc_smooth) 'lesion_labels.nii']);
    end
    
    pproc_cluster = inputdlg({'Enter minimum cluster size (recommended: 100). Set to 0 for no cluser thresholding'});
    pproc_cluster = cell2mat(pproc_cluster);
    pproc_cluster = str2num(pproc_cluster);
    
    if pproc_cluster == 0
        disp('Minimum cluster size not selected, no cluster thresholding will be performed');
    else
        disp(['Cluster thresholding lesion labels at ' num2str(pproc_cluster) ' voxels/cluster']);
        if pproc_smooth == 0
            my_lesion = load_nii('lesion_labels.nii');
        else
            my_lesion = load_nii(['s' num2str(pproc_smooth) 'lesion_labels.nii']);
        end
        [k, my_lesion.nii] = distance_cluster(my_lesion.img, 26);
        my_lesion.nii(my_lesion.img < pproc_cluster) = 0;
        my_lesion.nii(my_lesion.img > 0) = 1;
        save_nii(my_lesion, [my_lesion.fileprefix '_clustered_' num2str(pproc_cluster) '.nii']);
    end
end
disp('Finished saving lesion masks');
end
