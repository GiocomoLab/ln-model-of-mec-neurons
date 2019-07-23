function [hd_grid,dirVec,direction] = hd_map_root(sheaddir,nbins)
% headdir = head direction angles in degree from -180 to +180 (as in
% root.sheaddir)

%compute head direction
direction = deg2rad(sheaddir) + pi; % go from 0 to 2*pi, without any negative numbers

hd_grid = zeros(length(sheaddir),nbins);
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = 1:numel(sheaddir)
    
    % figure out the hd index
    [~, idx] = min(abs(direction(i)-dirVec));
    hd_grid(i,idx) = 1;
  
end

return