function util_extract_features(cfg)
% This function creates feature maps encoding information about missing and abnormal
% tissue that are then used to predict voxels corresponding to stroke
% lesions. 
% Input: cfg structure variable containing fields shown below. Each patient
% directory should contain the normalized tissue probablistic maps for GM/WM/CSF with
% prefixes (wc1, wc2, and wc3). 
% Output: nifti files for feature maps F1 and F2 (f1.nii and f2.nii), indices of in-mask
% voxels (my_ind), and predictor matrix (my_features) that will be used as input for classifier.
% Created by Joseph C. Griffis, 2015. 

spm_jobman('initcfg');
data_dir = cfg.data; % path to directory containing subject folders with normalized segmentations obtained from the New Segment tool in SPM12.
out_dir = cfg.out; % path to directory where feature maps will be saved
fwhm = cfg.fwhm; % smoothing kernel width (applied to both the prior probability maps and the normalized segmentations)
affected = cfg.affected; % affected hemisphere ('LH' for left hemisphere, 'RH' for right hemisphere);
ppm_only = cfg.ppm_only; % set to 0 to use only prior probability maps in feature map creation (e.g. in the case of bilateral lesions with similar locations)

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


% Start feature map creation
disp(['Creating feature maps']);
% load subject segmentation volumes
cd(tpm_dir);
% Check to see if TPM smoothed at selected kernel width already exists

my_smooth_spm('TPM.nii', [fwhm fwhm fwhm],cfg.im_mask); % if it doesn't exist, create it


my_tpm_template = load_nii(fullfile(tpm_dir, ['s' num2str(fwhm) 'TPM.nii'])); % load smoothed TPM volume

% extract GM/WM/CSF prior probability maps
gm_template = my_tpm_template.img(:,:,:,1);
wm_template = my_tpm_template.img(:,:,:,2);
csf_template = my_tpm_template.img(:,:,:,3); 
clear my_tpm_template

% go to subject directory 
cd(data_dir);

% load GM/WM/CSF tissue probability maps 
gm_file = dir('wc1*.nii');
wm_file = dir('wc2*.nii');
csf_file = dir('wc3*.nii');

my_files = [cellstr(char(gm_file(1).name)); cellstr(char(wm_file(1).name)); cellstr(char(csf_file(1).name))];
my_smooth_spm(my_files, [fwhm fwhm fwhm], cfg.im_mask);
my_gm = load_nii(['s' num2str(fwhm) gm_file(1).name]);
my_wm = load_nii(['s' num2str(fwhm) wm_file(1).name]);
my_csf = load_nii(['s' num2str(fwhm) csf_file(1).name]);
clear my_files 

gm_vol = my_gm.img;
wm_vol = my_wm.img; 
csf_vol = my_csf.img;

% get brain mask
b_mask = load_nii(fullfile(tpm_dir, 'mask_ICV.nii'));
b_mask = b_mask.img;
outside_index = find(b_mask == 0);

% smooth and clip segmentations
gm_vol(outside_index) = 0;
wm_vol(outside_index) = 0;
csf_vol(outside_index) = 0;

vol_size = size(gm_vol);
l_bound = round(0.5*vol_size(1));

if strcmp(affected, 'L') == 1
    b_mask(l_bound:vol_size(1),:,:) = 0;
    % Get mirror images of target volumes
    gm_u = flipdim(gm_vol,1);
    wm_u = flipdim(wm_vol,1);
    cv_u = flipdim(csf_vol, 1);
    
    % create LH only subject volumes
    gm_a = gm_vol; clear gm_vol
    gm_a(l_bound:vol_size(1), :,:) = 0; % lh only grey matter
    wm_a = wm_vol; clear wm_vol
    wm_a(l_bound:vol_size(1), :,:) = 0; % lh only white matter
    cv_a = csf_vol; clear csf_vol
    cv_a(l_bound:vol_size(1), :,:) = 0; % lh only csf
    gm_u(l_bound:vol_size(1), :,:) = 0; % rh only grey matter
    wm_u(l_bound:vol_size(1), :,:) = 0; % rh only white matter
    cv_u(l_bound:vol_size(1), :,:) = 0; % rh only csf
    % create LH only template volumes
    gm_t = gm_template; clear gm_template
    gm_t(l_bound:vol_size(1), :,:) = 0; % lh only grey matter template
    wm_t = wm_template; clear wm_template
    wm_t(l_bound:vol_size(1), :,:) = 0; % lh only white matter template
    cv_t = csf_template; clear csf_template
    cv_t(l_bound:vol_size(1), :,:) = 0; % lh only csf template

elseif strcmp(affected, 'R') == 1
    b_mask(1:l_bound,:,:) = 0;
    % Get mirror images of target volumes
    gm_u = flipdim(gm_vol,1);
    wm_u = flipdim(wm_vol,1);
    cv_u = flipdim(csf_vol, 1);
    
    % create RH only subject volumes
    gm_a = gm_vol; clear gm_vol
    gm_a(1:l_bound, :,:) = 0; % rh only grey matter
    wm_a = wm_vol; clear wm_vol
    wm_a(1:l_bound, :,:) = 0; % rh only white matter
    cv_a = csf_vol; clear csf_vol
    cv_a(1:l_bound, :,:) = 0; % rh only csf
    gm_u(1:l_bound, :,:) = 0; % rh only grey matter
    wm_u(1:l_bound, :,:) = 0; % rh only white matter
    cv_u(1:l_bound, :,:) = 0; % rh only csf
    % create RH only template volumes
    gm_t = gm_template; clear gm_template
    gm_t(1:l_bound, :,:) = 0; % rh only grey matter template
    wm_t = wm_template; clear wm_template
    wm_t(1:l_bound, :,:) = 0; % rh only white matter template
    cv_t = csf_template; clear csf_template
    cv_t(1:l_bound, :,:) = 0; % rh only csf templatee
end

% create output directory 
if isdir(out_dir) == 0
    mkdir(out_dir);
end
cd(fullfile(data_dir, out_dir));

%% Step 1: Create missing tissue feature map (F1)
disp('Step 1: Creating feature maps encoding missing tissue information');
if strcmp(ppm_only, 'N') == 1
    disp('Default selected: Using both the unaffected hemisphere tissue probability maps and the prior probability maps for feature map creation');
    c_t1 = (cv_a - cv_t).*((gm_t + wm_t)-(gm_a + wm_a)); % missing tissue feature map 1 
    c_m1 = (cv_a - cv_u).*((gm_u + wm_u)-(gm_a + wm_a)); % missing tissue feature map 2
    f_1 = (c_m1 + c_t1)./2; % get average of the two volumes 
    f_1 = round(f_1.*100)./100; % round result to two significant digits
    f_1(f_1<0)= 0; % set voxels with values < 0 to 0 
else
    disp('PPM_only option selected: Using only the prior probability maps for feature map creation');
    f_1 = (cv_a - cv_t).*((gm_t + wm_t)-(gm_a + wm_a)); % missing tissue feature map
    f_1 = round(f_1.*100)./100; % round result to two significant digits
    f_1(f_1<0)= 0; % set voxels with values < 0 to 0
end
%% Find missing cortex in WM TPMs
disp('Step 2: Creating feature maps encoding abnormal tissue information');

if strcmp(ppm_only, 'N') == 1
    disp('Default selected: Using both the unaffected hemisphere tissue probability maps and the prior probability maps for feature map creation');
    g_m1 = (gm_a-gm_u).*(wm_u-wm_a); % abnormal tissue feature map 1 
    g_t1 = (gm_a-gm_t).*(wm_t-wm_a); % abnormal tissue feature map 2 
    f_2 = (g_m1 + g_t1)./2; % get average volume
    f_2 = round(f_2.*100)./100; % round result to 2 significant digits 
    f_2(f_2<0) = 0; % set voxels with values < 0 to 0
else
    disp('PPM_only option selected: Using only the prior probability maps for feature map creation');
    f_2 = (gm_a-gm_t).*(wm_t-wm_a); % abnormal tissue feature map 2 
    f_2 = round(f_2.*100)./100; % round result to 2 significant digits 
    f_2(f_2<0) = 0; % set voxels with values < 0 to 0 
end
%% Save outputs
disp('Step 3: Saving feature maps and voxel indices');

my_ind = find(b_mask); % extract indices of non-zero voxels from mask
my_gm.img = f_1; 
save_nii(my_gm, 'f1.nii');
my_gm.img = f_2;
save_nii(my_gm, 'f2.nii');
my_features = [f_1(my_ind) f_2(my_ind)];
save my_features my_features
save my_ind my_ind
end