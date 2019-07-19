% filter a spike train
% set several properties
%
% Arguments:
%   self: the LNLModel object
%   spiketrain: the spike train (or peristimulus time histogram)
%   filter: a normalized vector that is convolved with the spiketrain
% Outputs:
%   smooth_firing_rate: the firing rate smoothed by the filter
%   firing_rate: the firing rate (spike train divided by dt)

function [smooth_firing_rate, firing_rate] = get_filtered_firing_rate(self, spiketrain, filter)

  if ~exist('filter', 'var')
    filter = LNLModel.get_filter();
  end

  firing_rate = spiketrain * self.sample_rate;

  smooth_firing_rate = conv(firing_rate, filter, 'same');

end % function
