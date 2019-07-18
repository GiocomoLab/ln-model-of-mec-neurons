% filter a spike train
% set several properties
%
% Arguments:
%   self: the LNLModel object
%   spiketrain: the spike train (or peristimulus time histogram)
%   filter_name: a character vector that defines which kind of filter to use
% Outputs:
%   smooth_firing_rate: the firing rate smoothed by the filter
%   firing_rate: the firing rate (spike train divided by dt)
%   dt: the time step, computed from the timestamps
%   filter: the filter as a normalized vector

function [smooth_firing_rate, firing_rate, dt, filter] = get_filtered_firing_rate(self, spiketrain, filter_name)

  if ~exist('filter_name', 'var')
    filter_name = 'hardcastle';
  end

  dt = self.post(3) - self.post(2);
  firing_rate = spiketrain / dt;

  switch filter_name
  case 'hardcastle'
    filter = gaussmf(-4:4, [2, 0]);
    filter = filter / sum(filter);
  end

  smooth_firing_rate = conv(firing_rate, filter, 'same');

end % function
