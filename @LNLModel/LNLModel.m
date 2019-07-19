classdef LNLModel

properties

  % description of variables included:
  n_folds = 10      % the 'k' in k-fold cross-validation
  vars = 'PSTH';    % which variables to treat as the dependents?
  alpha = 0.05;     % the significance threshold for p-value tests
  verbosity = true; % how much informative text should be printed?
  baseline = 0;     % use median "baseline" of 0 unless otherwise noted, determines significance

end % properties

properties (SetAccess = protected)

  n_models = 15     % number of models
  box_size           % length (in cm) of one side of the square box
  spiketrain        % vector of the # of spikes in each 20 ms time bin
  sheaddir          % head direction angles in degrees from -180 to 180
  post              % vector of time (seconds) at every 20 ms time bin
  posx_c            % x-position in middle of LEDs
  posy_c            % y-position in middle of LEDs
  filt_eeg          % local field potential, filtered for theta frequency (4-12 Hz)
  eeg_sample_rate   % sample rate of filt_eeg (250 Hz)
  sample_rate       % sampling rate of neural data and behavioral variable (50Hz)

end % properties setaccess protected

methods

  function self = LNLModel(root, cel, n_spikes)
    % constructor
    % Arguments:
    %   root: a root object created by CMBHOME
    %   cel: a 1x2 vector containing the cell and tetrode indices
    %   n_spikes: optional argument; how many spikes to find as a 1x1 positive integer

    if exist('n_spikes', 'var')
      [outputs] = LNLModel.unpackRoot(root, cel, n_spikes);
    else
      [outputs] = LNLModel.unpackRoot(root, cel);
    end

    output_list = fieldnames(outputs);

    for ii = 1:length(output_list)
      self.(output_list{ii}) = outputs.(output_list{ii});
    end
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

  [testFit, trainFit, param_mean] = fit_model(A, dt, spiketrain, filter, modelType, numFolds)
  [f, df, hessian] = ln_poisson_model(param,data,modelType)
  [outputs] = unpackRoot(root, cel, n_spikes)
  [selected_model] = select_model(self, testFit)

end % static methods

end % classdef
