classdef LNLModel

properties

  % description of variables included:
  boxSize           % length (in cm) of one side of the square box
  post              % vector of time (seconds) at every 20 ms time bin
  spiketrain        % vector of the # of spikes in each 20 ms time bin
  posx              % x-position of left LED every 20 ms
  posx2             % x-position of right LED every 20 ms
  posx_c            % x-position in middle of LEDs
  posy              % y-position of left LED every 20 ms
  posy2             % y-posiiton of right LED every 20 ms
  posy_c            % y-position in middle of LEDs
  filt_eeg          % local field potential, filtered for theta frequency (4-12 Hz)
  eeg_sample_rate   % sample rate of filt_eeg (250 Hz)
  sampleRate        % sampling rate of neural data and behavioral variable (50Hz)
  n_folds = 10      % the 'k' in k-fold cross-validation
  vars = 'PSTH';    % which variables to treat as the dependents?
  alpha = 0.05;     % the significance threshold for p-value tests
  verbosity = true; % how much informative text should be printed?

end % properties

properties (SetAccess = protected)

  n_models = 15     % number of models

end % properties setaccess protected

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

  function set.vars(self, value)
    assert(ischar(value), 'vars must be a character vector')
    assert(length(value) <= 4, 'vars must be a vector of length 4 or less')
    assert(isvector(value), 'vars must be a vector')
    % confirm that each character is allowed
    for ii = 1:length(value)
      if isempty(any(strfind('ptsh', lower(value(ii)))))
        error('unknown variable (legal variables are ''PTSH'')')
      end
    end
    % all tests passed, save the variable
    len = length(value);
    self.vars = value;
    % update the n_models property as well
    c = 0;
    for ii = 1:len
      c = c + nchoosek(len, ii);
    end
    self.n_models = c;
  end % set.vars

end % methods

methods (Static)

  [boxSize, post, spiketrain, postx, posx2, posx_c, posy, posy2, posy_c, filt_eeg, eeg_sample_rate, sample_rate] = unpackRoot(root, cel);
  [testFit, trainFit, param_mean] = fit_model(A, dt, spiketrain, filter, modelType, numFolds)

end % static methods

end % classdef
