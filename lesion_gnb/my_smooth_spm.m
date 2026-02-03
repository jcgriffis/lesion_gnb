%% my_smooth_spm 
% This function takes inputs my_files, fwhm, and im, and creates smoothed
% image volumes utilizing the smoothing function implemented in SPM.
% smoothed image volumes are given a prefix 'sFWHM', where fwhm is equal to
% the chosen kernel width (e.g. s8).
% Created by Joseph C. Griffis, 2015, University of Alabama at Birmingham
% Department of Psychology. 
% Use at own risk. 
function my_smooth_spm(my_files, fwhm, im)

if nargin < 3
    im = 0;
end

clear matlabbatch
matlabbatch{1}.spm.spatial.smooth.data = cellstr(my_files);
matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = im;
matlabbatch{1}.spm.spatial.smooth.prefix = ['s' num2str(fwhm(1))];
spm_jobman('run',matlabbatch);

end