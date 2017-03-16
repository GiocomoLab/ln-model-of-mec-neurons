function [hd_mean] = computeHdMap(dir,numBin,fr)

%bin it
hdVec = linspace(0,2*pi,numBin+1);
hd_mean = nan(numBin,1);

% compute mean fr for each direction bin
for n = 1:numBin
    start = hdVec(n); stop = hdVec(n+1);
    hd_mean(n) = nanmean(fr(dir >= start & dir < stop));
    if n == numBin
        hd_mean(n) = nanmean(fr(dir >= start & dir <= stop));
    end
end


return