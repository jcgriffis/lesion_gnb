%% Run SPM New Segment Routine 
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham Department of Psychology.
% Use at own risk. 
function util_run_segmentation_lp(cfg)

spm_jobman('initcfg');
data_dir = cfg.data; % path to directory containing subject folders with normalized segmentations obtained from the New Segment tool in SPM12.
t1_file = cfg.t1path;
lp_file = fullfile(pwd, [cfg.lp]);
mkdir(cfg.out);
copyfile(lp_file, fullfile(pwd,cfg.out));
copyfile(t1_file, fullfile(pwd,cfg.out));
cd(fullfile(pwd, cfg.out));
lp_file = fullfile(pwd, [cfg.lp]);
t1_file = fullfile(pwd, [cfg.t1name]);
lp = load_nii([cfg.lp]);
lp.img = flipdim(lp.img, 1);
lp.hdr.dime.pixdim = [1 -1.5 1.5 1.5 0 0 0 0];%lp.img = flipdim(lp.img, 1);
save_nii(lp, [cfg.lp]);
% set appropriate directories
util_dir = fileparts(which('spm'));

if isempty(util_dir) == 1
    disp('ERROR: SPM directory not found. Add SPM directory to path');
end
addpath(genpath(util_dir));
cd(data_dir);  
matlabbatch=[];
matlabbatch{1}.spm.spatial.preproc.channel.vols = {t1_file};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[util_dir, '/tpm/TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[util_dir, '/tpm/TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[util_dir, '/tpm/TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[util_dir, '/tpm/TPM.nii,4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[util_dir, '/tpm/TPM.nii,5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[util_dir, '/tpm/TPM.nii,6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(7).tpm = {[lp_file]};
matlabbatch{1}.spm.spatial.preproc.tissue(7).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(7).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(7).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
spm_jobman('run',matlabbatch);
    
end
