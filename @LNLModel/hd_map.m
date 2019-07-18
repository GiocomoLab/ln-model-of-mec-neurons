function [hd_grid,dirVec,direction] = hd_map(self, nbins)

  %compute head direction
  direction = atan2(self.posy2-self.posy,self.posx2-self.posx)+pi/2;
  direction(direction < 0) = direction(direction<0)+2*pi; % go from 0 to 2*pi, without any negative numbers

  hd_grid = zeros(length(self.posx),nbins);
  dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

  for i = 1:numel(self.posx)

      % figure out the hd index
      [~, idx] = min(abs(direction(i)-dirVec));
      hd_grid(i,idx) = 1;

  end

end % function
