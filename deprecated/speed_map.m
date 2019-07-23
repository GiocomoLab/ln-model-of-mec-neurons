function [speed_grid,speedVec,speed] = speed_map(posx,posy,nbins)

%compute velocity
sampleRate = 50;
velx = diff([posx(1); posx]); vely = diff([posy(1); posy]); % add the extra just to make the vectors the same size
speed = sqrt(velx.^2+vely.^2)*sampleRate; 
maxSpeed = 50; speed(speed>maxSpeed) = maxSpeed; %send everything over 50 cm/s to 50 cm/s

speedVec = maxSpeed/nbins/2:maxSpeed/nbins:maxSpeed-maxSpeed/nbins/2;
speed_grid = zeros(numel(posx),numel(speedVec));

for i = 1:numel(posx)

    % figure out the speed index
    [~, idx] = min(abs(speed(i)-speedVec));
    speed_grid(i,idx) = 1;
    

end

return