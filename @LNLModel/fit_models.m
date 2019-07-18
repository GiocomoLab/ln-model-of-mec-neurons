% fits all linear models for the parameters (P, H, S, T)
% the model is r = exp(W * θ)
%   r => the predicted number of spikes
%   W => matrix of one-hot vectors describing variables (P, H, S, T)
%   θ => the learned vector of parameters
%
% Arguments:
%   self: an instance of the linear-nonlinear model class
%   varargin: options (see below)

function fit_models(self, varargin)

  % optional arguments
  options.n_pos_bins    = 20;
  options.n_dir_bins    = 10;
  options.n_speed_bins  = 10;
  options.n_theta_bins  = 18;

  corelib.parseNameValueArguments(options, varargin{:});
