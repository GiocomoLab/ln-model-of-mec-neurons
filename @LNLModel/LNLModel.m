classdef LNLModel < Hashable

properties
  % description of variables included:
  bins = struct('position', 20, 'head_direction', 10, 'speed', 10, 'theta', 18)
  max_speed = 50;   % cm/s, speeds above this value will be truncated to this value
  n_folds = 10      % the 'k' in k-fold cross-validation
  vars = 'PSTH';    % which variables to treat as the dependents?
  alpha = 0.05;     % the significance threshold for p-value tests
  verbosity = true; % how much informative text should be printed?
  baseline = 0;     % use median "baseline" of 0 unless otherwise noted, determines significance

end % properties

properties (SetAccess = protected)
  n_models = 15     % number of models
  box_size          % length (in cm) of one side of the square box
  spiketrain        % vector of the # of spikes in each 20 ms time bin
  sheaddir          % head direction angles in degrees from -180 to 180
  speed             % animal speed in cm/s
  phase             % radians, theta phase in [0, 2pi]
  post              % vector of time (seconds) at every 20 ms time bin
  posx_c            % x-position in middle of LEDs
  posy_c            % y-position in middle of LEDs
  filt_eeg          % local field potential, filtered for theta frequency (4-12 Hz)
  eeg_sample_rate   % sample rate of filt_eeg (250 Hz)
  sample_rate       % sampling rate of neural data and behavioral variable (50Hz)

end % properties setaccess protected

methods

  function self = LNLModel(root, cel, varargin)
    % constructor
    % Arguments:
    %   root: a root object created by CMBHOME
    %     if it's not, assume it's a mat file and load it, and hope it works
    %   cel: a 1x2 vector containing the cell and tetrode indices
    %   varargin: name-value arguments into LNLModel.unpackRoot()

    if exist('root', 'var') & strcmp(class(root), 'CMBHOME.Session')
      [outputs] = LNLModel.unpackRoot(root, cel, varargin{:});
      output_list = fieldnames(outputs);

      for ii = 1:length(output_list)
        self.(output_list{ii}) = outputs.(output_list{ii});
      end
    else
      % expect root to be the path to a mat file
      data = load(root);
      output_list = fieldnames(data);
      for ii = 1:length(output_list)
        if isprop(self, output_list{ii})
          self.(output_list{ii}) = data.(output_list{ii});
        end
      end
      self.sample_rate = data.sampleRate;
      self.speed = data.sampleRate * (data.posx_c.^2 + data.posy_c.^2);
      self.box_size = data.boxSize;
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

  [testFit,trainFit,param_mean] = fit_model(varargin)
  [f, df, hessian] = ln_poisson_model(param, data, modelType, n_bins)
  [outputs] = unpackRoot(root, cel, varargin)
  [selected_model] = select_model(self, testFit)
  [filter] = get_filter(filter_name)
  [tuning_curve] = compute_1d_tuning_curve(variable,fr,numBin,minVal,maxVal)
  [tuning_curve] = compute_2d_tuning_curve(variable_x,variable_y,fr,numBin,minVal,maxVal)
  [frFilt,spkTrain] = get_InstFR(spktimes, time, sampling_rate_of_time, varargin)

end % static methods

end % classdef
