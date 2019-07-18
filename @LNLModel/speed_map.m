function [speed_grid,speedVec,speed] = speed_map(self, nbins)

    %compute velocity
    sampleRate = 50;
    velx = diff([self.posx(1); self.posx]); vely = diff([self.posy(1); self.posy]); % add the extra just to make the vectors the same size
    speed = sqrt(velx.^2+vely.^2)*sampleRate;
    maxSpeed = 50; speed(speed>maxSpeed) = maxSpeed; %send everything over 50 cm/s to 50 cm/s

    speedVec = maxSpeed/nbins/2:maxSpeed/nbins:maxSpeed-maxSpeed/nbins/2;
    speed_grid = zeros(numel(self.posx),numel(speedVec));

    for i = 1:numel(self.posx)

        % figure out the speed index
        [~, idx] = min(abs(speed(i)-speedVec));
        speed_grid(i,idx) = 1;


    end

end % function
