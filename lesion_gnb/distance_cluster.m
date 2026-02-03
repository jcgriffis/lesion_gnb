%% distance_cluster.m 
% This function takes inputs my_vol and con_n, and outputs variables
% my_clust and L. My_vol is intended to be a 3D image volume. con_n
% indicates the neighborhood used to define clusters. my_clust is a vector
% containing the number of voxels in each cluster identified. L is is an
% image volume where each voxel's value is equal to the number of voxels in
% its cluster. 

% Copyright Joseph C. Griffis, 2015, University of Alabama at Birmingham
% Department of Psychology. 
% Use at own risk. 

function [my_clust L] = distance_cluster(my_vol, con_n)

if max(my_vol(:) ~= 0)
        
    [D ~] = bwdist(my_vol);
    my_mask = zeros(size(my_vol));
    my_mask(D==0) = 1;
    [L NUM] = bwlabeln(my_mask, con_n);
    if NUM ~= 0
        my_clust = zeros(NUM,1);
        for j = 1:NUM
            my_clust(j) = numel(L(L==j));
            L(L == j) = numel(L(L==j));
        end
    end
else
    my_clust = 0;
    vol_size = size(my_vol);
    L  = zeros(vol_size);
end

end