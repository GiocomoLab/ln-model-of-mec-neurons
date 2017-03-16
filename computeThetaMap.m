function [theta_mean] = computeThetaMap(phase,thetaVec,fr)

%bin it
numBin = numel(thetaVec)+1; 
thetaVec_big = linspace(0,2*pi,numBin);
theta_mean = nan(numBin-1,1);

% compute mean fr for each direction bin
for n = 1:numBin-1
    start = thetaVec_big(n); stop = thetaVec_big(n+1);
    theta_mean(n) = nanmean(fr(phase >= start & phase <= stop));
end



return