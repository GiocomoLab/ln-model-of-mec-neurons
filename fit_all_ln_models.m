%% Description

% This will fit 15 LN models to the spike train of a single cell. Each
% model uses information about position, head direction, running speed,
% theta phase, or some combination thereof, to predict a section of the
% spike train. Model fitting and model performance is computed through
% 10-fold cross-validation, and the minimization procedure is carried out
% through fminunc. Once all models are fit, a forward-search procedure is
% implemented to find the simplest 'best' model describing this spike
% train. The forward-search procedure can be embedded into the
% model-fitting procedure; we don't do that here for clarity

% The model: r = exp(W*theta), where r is the predicted # of spikes, W is a
% matrix of one-hot vectors describing variable (P, H, S, or T) values, and
% theta is the learned vector of parameters.

% In addition, this code will compute the tuning curves for position, head
% direction, running speed, and theta phase

% Code as implemented in Hardcastle, Maheswaranthan, Ganguli, Giocomo,
% Neuron 2017
% V1: Kiah Hardcastle, March 16, 2017


%% clear the workspace

clear all; close all; clc

%% load the data

load data_for_cell77

% description of variables included:
% boxSize = length (in cm) of one side of the square box
% post = vector of time (seconds) at every 20 ms time bin
% spiketrain = vector of the # of spikes in each 20 ms time bin
% posx = x-position of left LED every 20 ms
% posx2 = x-position of right LED every 20 ms
% posx_c = x-position in middle of LEDs
% posy = y-position of left LED every 20 ms
% posy2 = y-posiiton of right LED every 20 ms
% posy_c = y-position in middle of LEDs
% filt_eeg = local field potential, filtered for theta frequency (4-12 Hz)
% eeg_sample_rate = sample rate of filt_eeg


%% compute the position, head direction, speed, and theta phase matrices

% initialize the number of bins that position, head direction, speed, and
% theta phase will be divided into
n_pos_bins = 20;
n_dir_bins = 18;
n_speed_bins = 10;
n_theta_bins = 18;

% compute the speed of the animal and remove times when the animal
% ran > 50 cm/s (these data points may contain artifacts)
[speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins);
too_fast = find(speed >= 50);
posx(too_fast) = []; posy(too_fast) = []; posx2(too_fast) = []; posy2(too_fast) = [];
posx_c(too_fast) = []; posy_c(too_fast) = []; speed(too_fast) = []; speedgrid(too_fast,:) = [];

% compute position matrix
[posgrid, posVec] = pos_map([posx_c posy_c], n_pos_bins, boxSize);

% compute head direction matrix
[hdgrid,hdVec,direction] = hd_map(posx,posx2,posy,posy2,n_dir_bins);

% compute theta matrix
[thetagrid,thetaVec,phase] = theta_map(filt_eeg,post,sampleRate,n_theta_bins);

% take out times when the animal ran >= 50 cm/s
thetagrid(too_fast,:) = []; phase(too_fast) = []; spiketrain(too_fast) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fit all 15 LN models
modelNum = 15;
testFit_all = cell(modelNum,1);
trainFit_all = cell(modelNum,1);
param = cell(modelNum,1);
A = cell(modelNum,1);
modelType = cell(modelNum,1);

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

% smooth firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); %smooth over 100 ms
dt = (post(3)-post(2)); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same'); %returns vector same size as original

for n = 1:modelNum
    [testFit_all{n},trainFit_all{n},param{n}] = fit_model_kfold_fmin(A{n},dt,spiketrain,filter,modelType{n});
    
end

% null parameters
[rateMap] = computeRateMap(posx_c,posy_c,smooth_fr);
[hd_val] = computeHdMap(direction,n_dir_bins,smooth_fr);
[speed_fr_mean] = computeSpeedMap(speed,speedVec,smooth_fr);
[theta_val] = computeThetaMap(phase,thetaVec,fr);
param_null = [rateMap(:)' hd_val' speed_fr_mean' theta_val'];

