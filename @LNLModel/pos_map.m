function [posgrid, bins] = pos_map(self)

    % take the histogram
    pos = [self.posx_c self.posy_c];

    bins = self.box_size/self.bins.position/2:self.box_size/self.bins.position:self.box_size-self.box_size/self.bins.position/2;

    % store grid
    posgrid = zeros(length(pos), self.bins.position^2);

    % loop over positions
    for idx = 1:length(pos)

        % figure out the position index
        [~, xcoor] = min(abs(pos(idx,1)-bins));
        [~, ycoor] = min(abs(pos(idx,2)-bins));

        bin_idx = sub2ind([self.bins.position, self.bins.position], self.bins.position - ycoor + 1, xcoor);

        posgrid(idx, bin_idx) = 1;

    end

end % function
