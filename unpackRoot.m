% unpackRoot.m
% takes in a root object
% and unpacks the variables needed for the Hardcastle model
% this makes root objects able to be analyzed with the linear-nonlinear model
%
% Arguments:
%   root: a root object created bythe CMBHOME package
%   cel: index of cell number and tetrode number as a 1x2 matrix
% Outputs:
%   boxSize           => length (in cm) of one side of the square box
%   post              => vector of time (seconds) at every 20 ms time bin
%   spiketrain        => vector of the # of spikes in each 20 ms time bin
%   posx              => x-position of left LED every 20 ms
%   posx2             => x-position of right LED every 20 ms
%   posx_c            => x-position in middle of LEDs
%   posy              => y-position of left LED every 20 ms
%   posy2             => y-posiiton of right LED every 20 ms
%   posy_c            => y-position in middle of LEDs
%   filt_eeg          => local field potential, filtered for theta frequency (4-12 Hz)
%   eeg_sample_rate   => sample rate of filt_eeg (250 Hz)
%   sampleRate        => sampling rate of neural data and behavioral variable (50Hz)

function [boxSize, post, spiketrain, postx, posx2, posx_c, posy, posy2, posy_c, filt_eeg, eeg_sample_rate, sample_rate] = unpackRoot(root, cel)

  post      = root.ts; % time steps
  posx_c    = root.sx; % central x-position
  posy_c    = root.sy; % central y-position
  % let the position points start at (x, y) = (0, 0)
  posx_c    = posx_c - min(posx_c);
  posy_c    = posy_c - min(posy_c);

  % spike times
  spktimes  = get_spktimes_of_cel(root, cel)
  % number of spikes
  nmbr_spikes = length(spktimes);

  if length(spktimes) < nmbr_spikes
    error('number of spikes and length of spike times don''t agree')
  end

  % shuffle the spikes
  p = randperm(length(spktimes), nmbr_spikes);
  spikes    = sort(spktimes(p));

  % get the spike train (125-ms Gaussian filter)
  [real_fr, ~] = get_InstFR(spktimes, post, root.fs_video, 'filter_length', 125, 'filter_type', 'Gauss');
  [smooth_fr,spiketrain] = get_InstFR(spikes,post,root.fs_video,'filter_length',125,'filter_type','Gauss');

  % get the EEG recording
  boxSize = 100;
  eeg_sample_rate = 600;
  theta_freq_range = [6, 10];

  % get the theta-filtered EEG recording
  root.active_lfp   = active_lfp;
  eeg_4800          = root.b_lfp(root.active_lfp).signal;
  eeg_600           = resample(eeg_4800, 600, 4800);
  filt_eeg          = CMBHOME.LFP.BandpassFilter(eeg_600, eeg_sample_rate, theta_freq_range);

end % function
