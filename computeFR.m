function [spikes] = computeFR(cellTS,time)

spikes = zeros(size(time));

for s = 1:length(cellTS)
    [~, idx] = min(abs(cellTS(s)-time));
    spikes(idx) = spikes(idx) + 1;
end

return 