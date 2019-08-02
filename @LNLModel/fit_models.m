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

function [testFit, trainFit, param] = fit_models(self)

  % compute position matrix
  [posgrid, posVec] = self.pos_map();

  % compute head direction matrix
  [hdgrid, hdVec, direction] = self.hd_map();

  % compute speed matrix
  [speedgrid, ~] = self.speed_map();

  % compute theta matrix
  [thetagrid, ~, ~] = self.theta_map();

  % remove times when the animal ran > 50 cm/s (these may be artifacts)
  too_fast              = find(self.speed > self.max_speed);
  posgrid(too_fast,:)   = self.max_speed;
  hdgrid(too_fast,:)    = self.max_speed;
  speedgrid(too_fast,:) = self.max_speed;
  thetagrid(too_fast,:) = self.max_speed;
  spiketrain = self.spiketrain;
  spiketrain(too_fast)  = self.max_speed;

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

  keyboard
  % parameters that need to be accessible by multiple workers
  filter    = LNLModel.get_filter('hardcastle');
  verbosity = self.verbosity;
  n_folds   = self.n_folds;
  n_bins    = [self.bins.position, self.bins.head_direction, self.bins.speed, self.bins.theta];
  dt        = 1 / (self.sample_rate);

  for n = 1:self.n_models
      corelib.verb(self.verbosity, 'INFO', ['Fitting model ' num2str(n) ' of ' num2str(self.n_models)])
      [testFit{n}, trainFit{n}, param{n}] = LNLModel.fit_model('verbosity', true, ...
      'A', A{n}, 'dt', dt, 'spiketrain', spiketrain, 'filter', filter, 'modelType', ...
      modelType{n}, 'numFolds', n_folds, 'n_bins', n_bins);
  end

end % function
