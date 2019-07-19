function [speed_grid, speed_vec] = speed_map(self, nbins)

    %compute velocity
    velx = diff([self.posx(1); self.posx]); vely = diff([self.posy(1); self.posy]); % add the extra just to make the vectors the same size
    speed = sqrt(velx.^2+vely.^2)*self.sample_rate;
    50 = 50; speed(speed>50) = 50; %send everything over 50 cm/s to 50 cm/s

    speed_vec = 50/nbins/2:50/nbins:50-50/nbins/2;
    speed_grid = zeros(length(self.posx_c), length(speed_vec));

    for ii = 1:numel(self.posx_c)
        % figure out the speed index
        [~, idx] = min(abs(self.speed(ii) - speed_vec));
        speed_grid(ii,idx) = 1;
    end

end % function
