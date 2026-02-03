% READ ME
% 
% The lesion_gnb toolbox is a MATLAB toolbox intended for use with the
% Statistical Parametric Mapping (SPM) software package. The lesion_gnb
% toolbox utilizes functions contained in MATLAB version R2014 Statistics
% Toolbox, as well as functions contained in the SPM12 software package and
% functions contained in the matlab_nifti toolbox. 
% 
% The lesion_gnb toolbox can be utilized either in single patient or batch
% mode. A basic user interface can be called by typing "lesion_gnb_ui" into
% the MATLAB command window while the lesion_gnb folder is in your MATLAB
% path, and can be used to perform the SPM12 New Segmentation routine and
% create/post-process lesion class label volumes for individual patient
% scans. For users who wish to run batch scripts, an example is included in
% the file "example_batch_script.m". 
%
% To install the lesion_gnb toolbox, simply place the lesion_gnb folder
% into the toolbox folder contained within spm12. 
% 
% The lesion_gnb toolbox has not been tested with MATLAB versions other than R2014b or with SPM versions 
% other than SPM12. 
%
% For more information regarding details about the method such as the rationale and/or process
% for feature map creation, GNB classifier training, cross-validation, or
% post-processing steps, please see our publication in the Journal of
% Neuroscience Methods entitled Voxel-based Gaussian naive Bayes classification of ischemic stroke
% lesions in individual T1-weighted MRI scans (Griffis et al., 2015.
% doi:10.1016/j.jneumeth.2015.09.019). Please cite this publication if you
% utilize the lesion_gnb toolbox in your research.
%
% Development supported in part by NIH grants R01 NS048281 and R01 HD068488 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% Use this program at your own risk. 
% Developed and implemented by Joseph C. Griffis, September 2015, University of Alabama at Birmingham, Department of Psychology.
