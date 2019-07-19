function [speed_grid, speed_vec] = speed_map(self, nbins)

    %compute velocity
    max_speed = 50; % cm/s
    speed_vec = (max_speed / nbins / 2):(max_speed / nbins):(max_speed - max_speed / nbins / 2);
    speed_grid = zeros(length(self.posx_c), length(speed_vec));

    for ii = 1:numel(self.posx_c)
        % figure out the speed index
        [~, idx] = min(abs(self.speed(ii) - speed_vec));
        speed_grid(ii,idx) = 1;
    end

end % function
