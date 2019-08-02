%% Description
% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.

%% compute the position, head direction, speed, and theta phase matrices
% initialize the number of bins that position, head direction, speed, and
% theta phase will be divided into
n_pos_bins = 20;
n_dir_bins = 18;
n_speed_bins = 10;
n_theta_bins = 18;

% compute position matrix
[posgrid, posVec] = pos_map([posx_c posy_c], n_pos_bins, boxSize);

% compute head direction matrix
[hdgrid,hdVec,direction] = hd_map_root(root.sheaddir,n_dir_bins);

% compute speed matrix
[speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins);

% compute theta matrix
[thetagrid,thetaVec,phase] = theta_map(filt_eeg,post,eeg_sample_rate,n_theta_bins);

% remove times when the animal ran > 50 cm/s (these data points may contain artifacts)
too_fast = find(speed >= 50);
posgrid(too_fast,:) = []; hdgrid(too_fast,:) = [];
speedgrid(too_fast,:) = []; thetagrid(too_fast,:) = [];
spiketrain(too_fast) = [];


%% Fit all 15 LN models

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
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter);
dt = post(3)-post(2); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same');

% compute the number of folds we would like to do
numFolds = 10;
keyboard
for n = 1:numModels
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    [testFit{n},trainFit{n},param{n}] = fit_model(A{n},dt,spiketrain,filter,modelType{n},numFolds);
end
