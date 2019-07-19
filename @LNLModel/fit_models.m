% fits all linear models for the parameters (P, H, S, T)
% the model is r = exp(W * θ)
%   r => the predicted number of spikes
%   W => matrix of one-hot vectors describing variables (P, H, S, T)
%   θ => the learned vector of parameters
%
% Syntax:
%   [testFit, trainFit, param] = self.fit_models()
%   [testFit, trainFit, param] = self.fit_models('Name', Value, ...)
%
% Arguments:
%   self: an instance of the linear-nonlinear model class
%   varargin: options (see below)
% Outputs:
%   testFit
%   trainFit
%   param

% TODO: make this function respond to n dependent variables, rather than all

function [testFit, trainFit, param] = fit_models(self, varargin)

  % optional arguments
  options.n_pos_bins    = 20;
  options.n_dir_bins    = 10;
  options.n_speed_bins  = 10;
  options.n_theta_bins  = 18;
  options.n_folds       = 10;

  options = corelib.parseNameValueArguments(options, varargin{:});

  % compute position matrix
  [posgrid, posVec] = self.pos_map(options.n_pos_bins);

  % compute head direction matrix
  [hdgrid, hdVec, direction] = self.hd_map(options.n_dir_bins);

  % compute speed matrix
  [speedgrid, ~] = self.speed_map(options.n_speed_bins);

  % compute theta matrix
  [thetagrid, ~, ~] = self.theta_map(options.n_theta_bins);

  % remove times when the animal ran > 50 cm/s (these may be artifacts)
  too_fast              = find(self.speed > 50);
  posgrid(too_fast,:)   = [];
  hdgrid(too_fast,:)    = [];
  speedgrid(too_fast,:) = [];
  thetagrid(too_fast,:) = [];
  spiketrain = self.spiketrain;
  spiketrain(too_fast)  = [];

  % fit all 15 linear-nonlinear models
  testFit = cell(self.n_models,1);
  trainFit = cell(self.n_models,1);
  param = cell(self.n_models,1);
  A = cell(self.n_models,1);
  modelType = cell(self.n_models,1);

  % ALL VARIABLES
  A{1} = [ posgrid hdgrid speedgrid thetagrid]; modelType{1} = [1 1 1 1];
  % THREE VARIABLES
  A{2} = [ posgrid hdgrid speedgrid ]; modelType{2} = [1 1 1 0];
  A{3} = [ posgrid hdgrid  thetagrid]; modelType{3} = [1 1 0 1];
  A{4} = [ posgrid  speedgrid thetagrid]; modelType{4} = [1 0 1 1];
  A{5} = [  hdgrid speedgrid thetagrid]; modelType{5} = [0 1 1 1];
  % TWO VARIABLES
  A{6} = [ posgrid hdgrid]; modelType{6} = [1 1 0 0];
  A{7} = [ posgrid  speedgrid ]; modelType{7} = [1 0 1 0];
  A{8} = [ posgrid   thetagrid]; modelType{8} = [1 0 0 1];
  A{9} = [  hdgrid speedgrid ]; modelType{9} = [0 1 1 0];
  A{10} = [  hdgrid  thetagrid]; modelType{10} = [0 1 0 1];
  A{11} = [  speedgrid thetagrid]; modelType{11} = [0 0 1 1];
  % ONE VARIABLE
  A{12} = posgrid; modelType{12} = [1 0 0 0];
  A{13} = hdgrid; modelType{13} = [0 1 0 0];
  A{14} = speedgrid; modelType{14} = [0 0 1 0];
  A{15} = thetagrid; modelType{15} = [0 0 0 1];

  % compute a filter, which will be used to smooth the firing rate
  % TODO: mess with this filter
  % filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter);
  % dt = post(3)-post(2); fr = spiketrain/dt;
  % smooth_fr = conv(fr,filter,'same');

  [smooth_firing_rate, firing_rate, dt, filter] = self.get_filtered_firing_rate(spiketrain, 'hardcastle');

  % parameters that need to be accessible by multiple workers
  verbosity = self.verbosity;
  n_folds   = self.n_folds;

  for n = 1:self.n_models
      corelib.verb(self.verbosity, 'INFO', ['Fitting model ' num2str(n) ' of ' num2str(self.n_models)])
      [testFit{n}, trainFit{n}, param{n}] = LNLModel.fit_model(verbosity, A{n}, dt, spiketrain, filter, modelType{n}, n_folds);
  end

end % function
