function [posgrid, bins] = pos_map(pos, nbins, boxSize)

% take the histogram

bins = boxSize/nbins/2:boxSize/nbins:boxSize-boxSize/nbins/2;

% store grid
posgrid = zeros(length(pos), nbins^2);

% loop over positions
for idx = 1:length(pos)
    
    % figure out the position index
    [~, xcoor] = min(abs(pos(idx,1)-bins));
    [~, ycoor] = min(abs(pos(idx,2)-bins));
    
    bin_idx = sub2ind([nbins, nbins], nbins - ycoor + 1, xcoor);
    
    posgrid(idx, bin_idx) = 1;
    
end

end