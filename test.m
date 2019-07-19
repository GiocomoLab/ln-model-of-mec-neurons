% This is a test script.
% It should:
% 1. Load up a CMBHOME.Session object (root)
% 2. Create a linear-nonlinear model object
% 3. Compute the likelihoods for each model.
% 4. Determine the best model.
% 5. TODO: Compute the tuning curves
% 6. TODO: Plot the results

% load the data
load('~/Downloads/180827_S1_lightVSdarkness.mat');

% create the L-NL model object
ln = LNLModel(root, [1, 1]);

% test all of the models
[testFit, trainFit, param] = ln.fit_models();

% select the best model
selected_model = LNLModel.select_model(testFit);

% compute tuning curves
smooth_firing_rate = ln.get_filtered_firing_rate(LNLModel.get_filter('hardcastle'));

% plot
ln.plot(param, smooth_firing_rate);
