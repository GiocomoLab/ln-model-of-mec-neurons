% unpackRoot.m
% takes in a root object
% and unpacks the variables needed for the Hardcastle model
% this makes root objects able to be analyzed with the linear-nonlinear model
%
% Arguments:
%   root: a root object created bythe CMBHOME package
%   cel: index of cell number and tetrode number as a 1x2 matrix
%   n_spikes: the number of spikes requested (randomly deletes spikes until this many are left)
%     defaults to the total number of spikes (no shuffling/deletion)
% Outputs:
%   boxSize           => length (in cm) of one side of the square box
%   spiketrain        => vector of the # of spikes in each 20 ms time bin
%   post              => vector of time (seconds) at every 20 ms time bin
%   posx_c            => x-position in middle of LEDs
%   posy_c            => y-position in middle of LEDs
%   filt_eeg          => local field potential, filtered for theta frequency (4-12 Hz)
%   eeg_sample_rate   => sample rate of filt_eeg (250 Hz)
%   sampleRate        => sampling rate of neural data and behavioral variable (50Hz)

function [boxSize, spiketrain, post, posx_c, posy_c, filt_eeg, eeg_sample_rate, sample_rate] = unpackRoot(root, cel, n_spikes)

  root.cel = cel;

  post      = root.ts; % time steps
  posx_c    = root.sx; % central x-position
  posy_c    = root.sy; % central y-position
  % let the position points start at (x, y) = (0, 0)
  posx_c    = posx_c - min(posx_c);
  posy_c    = posy_c - min(posy_c);

  % spike times
  spiketimes  = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);

  % shuffle the spikes
  if ~exist('n_spikes', 'var')
    n_spikes = length(spiketimes);
  end

  assert(n_spikes <= length(spiketimes), 'too many spikes requested')

  if n_spikes < length(spiketimes)
    p = randperm(length(spiketimes), n_spikes);
    spiketimes = sort(spiketimes(p));
  end

  % get the spike train without filtering, but with binning
  spiketrain = BandwidthEstimator.getSpikeTrain(spiketimes, root.ts);

  % get the EEG recording
  boxSize = 100;
  eeg_sample_rate = 600; % Hz
  theta_freq_range = [6, 10]; % Hz

  % get the theta-filtered EEG recording
  root.active_lfp   = 1; % NOTE: this is some magic e-phys stuff I don't understand; just trust Holger
  eeg_4800          = root.b_lfp(root.active_lfp).signal;
  eeg_600           = resample(eeg_4800, 600, 4800);
  filt_eeg          = CMBHOME.LFP.BandpassFilter(eeg_600, eeg_sample_rate, theta_freq_range);

  % get the sample rate in seconds
  sample_rate       = mean(diff(root.ts));

end % function
