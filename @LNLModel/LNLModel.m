classdef LNLModel

properties

% description of variables included:
boxSize           % => length (in cm) of one side of the square box
post              % => vector of time (seconds) at every 20 ms time bin
spiketrain        % => vector of the # of spikes in each 20 ms time bin
posx              % => x-position of left LED every 20 ms
posx2             % => x-position of right LED every 20 ms
posx_c            % => x-position in middle of LEDs
posy              % => y-position of left LED every 20 ms
posy2             % => y-posiiton of right LED every 20 ms
posy_c            % => y-position in middle of LEDs
filt_eeg          % => local field potential, filtered for theta frequency (4-12 Hz)
eeg_sample_rate   % => sample rate of filt_eeg (250 Hz)
sampleRate        % => sampling rate of neural data and behavioral variable (50Hz)

end % properties

methods

  function self = LNLModel(root, cel)
    % constructor
    % Arguments:
    %   root: a root object created by CMBHOME
    %   cel: a 1x2 vector containing the cell and tetrode indices
    [boxSize, post, spiketrain, postx, posx2, posx_c, posy, posy2, posy_c, filt_eeg, eeg_sample_rate, sample_rate] = LNLModel.unpackRoot(root, cel);

    self.boxSize = boxSize;
    self.post = post;
    self.spiketrain = spiketrain;
    self.postx = postx;
    self.posx2 = posx2;
    self.posx_c = posx_c;
    self.posy = posy;
    self.posy2 = posy2;
    self.posy_c = posy_c;
    self.filt_eeg = filt_eeg;
    self.eeg_sample_rate = eeg_sample_rate;
    self.sample_rate = sample_rate;

  end % constructor

end % methods

methods (Static)

  [boxSize, post, spiketrain, postx, posx2, posx_c, posy, posy2, posy_c, filt_eeg, eeg_sample_rate, sample_rate] = unpackRoot(root, cel);
  [posgrid, bins] = pos_map(pos, nbins, boxSize)
  [hdgrid,hdVec,direction] = hd_map(posx,posx2,posy,posy2,n_dir_bins)
  [speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins)
  [thetagrid,thetaVec,phase] = theta_map(filt_eeg,post,eeg_sample_rate,n_theta_bins)

end % static methods

end % classdef
