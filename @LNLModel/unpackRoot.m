% unpackRoot.m
% takes in a root object
% and unpacks the variables needed for the Hardcastle model
% this makes root objects able to be analyzed with the linear-nonlinear model
%
% Examples:
%
%   outputs = LNLModel.unpackRoot(root, cel)
%   outputs = LNLModel.unpackRoot(root, cel, 'OptionName', OptionValue, ...)
%
% Arguments:
%   root: a root object created bythe CMBHOME package
%   cel: index of cell number and tetrode number as a 1x2 matrix
%   varargin: options as name-value arguments
%
% Outputs:
%   box_size          => length (in cm) of one side of the square box
%   spiketrain        => vector of the # of spikes in each 20 ms time bin
%   sheaddir          => vector of the head direction (degrees)
%   speed             => magnitude of the animal speed (cm/s)
%   post              => vector of time (seconds) at every 20 ms time bin
%   posx_c            => x-position in middle of LEDs
%   posy_c            => y-position in middle of LEDs
%   filt_eeg          => local field potential, filtered for theta frequency (4-12 Hz)
%   eeg_sample_rate   => sample rate of filt_eeg (250 Hz)
%   sample_rate       => sampling rate of neural data and behavioral variable (50Hz)

function [outputs] = unpackRoot(root, cel, varargin)
  % options can be changed from defaults by calling the function with name-value arguments
  options.n_spikes  = []; % all spikes

  options = corelib.parseNameValueArguments(options, varargin{:});

  outputs = struct;
  root.cel = cel;

  outputs.post      = root.ts; % time steps
  outputs.posx_c    = root.sx; % central x-position
  outputs.posy_c    = root.sy; % central y-position
  % let the position points start at (x, y) = (0, 0)
  outputs.posx_c    = outputs.posx_c - min(outputs.posx_c);
  outputs.posy_c    = outputs.posy_c - min(outputs.posy_c);

  % spike times
  spiketimes  = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);

  % shuffle the spikes
  if isempty(options.n_spikes)
    options.n_spikes = length(spiketimes);
  end

  assert(options.n_spikes <= length(spiketimes), 'too many spikes requested')

  if options.n_spikes < length(spiketimes)
    p = randperm(length(spiketimes), options.n_spikes);
    spiketimes = sort(spiketimes(p));
  end

  % get the spike train without filtering, but with binning
  % outputs.spiketrain = BandwidthEstimator.getSpikeTrain(spiketimes, root.ts);
  % get the spike train by filtering
  [~, spiketrain] = LNLModel.get_InstFR(spiketimes, outputs.post, root.fs_video, 'filter_length', 125, 'filter_type', 'Gauss');

  % head direction
  outputs.sheaddir  = root.sheaddir;

  % speed
  outputs.speed     = root.svel;

  % get the EEG recording
  outputs.box_size = 100; % cm
  outputs.eeg_sample_rate = 600; % Hz
  theta_freq_range = [6, 10]; % Hz

  % get the theta-filtered EEG recording
  root.active_lfp   = 1; % NOTE: this is some magic e-phys stuff I don't understand; just trust Holger
  eeg_4800          = root.b_lfp(root.active_lfp).signal;
  eeg_600           = resample(eeg_4800, 600, 4800);
  outputs.filt_eeg  = CMBHOME.LFP.BandpassFilter(eeg_600, outputs.eeg_sample_rate, theta_freq_range);

  % compute the theta phase
  hilb_eeg          = hilbert(outputs.filt_eeg);
  outputs.phase     = atan2(imag(hilb_eeg), real(hilb_eeg));
  outputs.phase(outputs.phase < 0)  = outputs.phase(outputs.phase < 0) + 2*pi;

  % get the sample rate in seconds
  outputs.sample_rate = 1/mean(diff(root.ts));

end % function
