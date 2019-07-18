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

function [testFit, trainFit, param] = fit_models(self, varargin)

  % optional arguments
  options.n_pos_bins    = 20;
  options.n_dir_bins    = 10;
  options.n_speed_bins  = 10;
  options.n_theta_bins  = 18;
  options.n_folds       = 10;

  corelib.parseNameValueArguments(options, varargin{:});

  % compute position matrix
  [posgrid, posVec]           = self.pos_map(options.n_pos_bins);

  % compute head direction matrix
  [hdgrid,hdVec,direction]    = self.hd_map(options.n_dir_bins);

  % compute speed matrix
  [speedgrid,speedVec,speed]  = self.speed_map(options.n_speed_bins);

  % compute theta matrix
  [thetagrid,thetaVec,phase]  = self.theta_map(options.n_theta_bins);

  % remove times when the animal ran > 50 cm/s (these may be artifacts)
  too_fast              = find(speed >= 50);
  posgrid(too_fast,:)   = []; hdgrid(too_fast,:) = [];
  speedgrid(too_fast,:) = []; thetagrid(too_fast,:) = [];
  spiketrain(too_fast)  = [];

  % fit all 15 linear-nonlinear models

  numModels = 15;
  testFit = cell(numModels,1);
  trainFit = cell(numModels,1);
  param = cell(numModels,1);
  A = cell(numModels,1);
  modelType = cell(numModels,1);

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
  filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter);
  dt = post(3)-post(2); fr = spiketrain/dt;
  smooth_fr = conv(fr,filter,'same');

  for n = 1:numModels
      fprintf('\t- Fitting model %d of %d\n', n, numModels);
      [testFit{n}, trainFit{n}, param{n}] = fit_model(A{n}, dt, spiketrain, filter, modelType{n}, options.n_folds);
  end
