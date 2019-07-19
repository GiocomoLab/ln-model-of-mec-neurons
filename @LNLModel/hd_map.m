function [hd_grid,dirVec,direction] = hd_map(self)

  %compute head direction
  direction = deg2rad(self.sheaddir) + pi; % go from 0 to 2*pi, without any negative numbers

  hd_grid = zeros(length(self.sheaddir),self.bins.head_direction);
  dirVec = 2*pi/self.bins.head_direction/2:2*pi/self.bins.head_direction:2*pi-2*pi/self.bins.head_direction/2;

  for i = 1:numel(self.sheaddir)

      % figure out the hd index
      [~, idx] = min(abs(direction(i)-dirVec));
      hd_grid(i,idx) = 1;

  end

end % function
