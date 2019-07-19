function [posgrid, bins] = pos_map(self, nbins)

    % take the histogram
    pos = [self.posx_c self.posy_c];

    bins = self.box_size/nbins/2:self.box_size/nbins:self.box_size-self.box_size/nbins/2;

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

end % function
