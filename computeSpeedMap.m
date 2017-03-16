function [speed_fr_mean] = computeSpeedMap(speed,speedVec,fr)

% find mean firing rate across speed bins (for all positions)
binWidth = speedVec(2)-speedVec(1);
speed_fr_mean = nan(numel(speedVec),1);
speedVec_big = linspace(0,max(speedVec)+binWidth/2,numel(speedVec)+1);

for n = 1:numel(speedVec)
    
    start = speedVec_big(n);
    stop = speedVec_big(n)+binWidth;
    speed_fr_mean(n) = nanmean(fr(speed >= start & speed < stop));
    if n == numel(speedVec)
        speed_fr_mean(n) = nanmean(fr(speed >= start & speed <= stop));
    end

end


return