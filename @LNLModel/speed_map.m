function [speed_grid, speed_vec] = speed_map(self)

    %compute velocity
    self.max_speed = 50; % cm/s
    speed_vec = (self.max_speed / self.bins.speed / 2):(self.max_speed / self.bins.speed):(self.max_speed - self.max_speed / self.bins.speed / 2);
    speed_grid = zeros(length(self.posx_c), length(speed_vec));

    for ii = 1:numel(self.posx_c)
        % figure out the speed index
        [~, idx] = min(abs(self.speed(ii) - speed_vec));
        speed_grid(ii,idx) = 1;
    end

end % function
