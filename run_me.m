%% Description of run_me

% This script is segmented into three parts. In the first, the data (an
% example cell) is loaded. In the second, 15 LN models are fit to the
% cell's spike train. Each model uses information about 
% position, head direction, running speed, theta phase,
% or some combination thereof, to predict a section of the
% spike train. Model fitting and model performance is computed through
% 10-fold cross-validation, and the minimization procedure is carried out
% through fminunc. In the third part, a forward-search procedure is
% implemented to find the simplest 'best' model describing this spike
% train. In addition, the model-derived response profiles, and the firing
% rate tuning curves, are plotted alongside the model performances.

% Code as implemented in Hardcastle, Maheswaranthan, Ganguli, Giocomo,
% Neuron 2017
% V1: Kiah Hardcastle, March 16, 2017


%% Clear the workspace and load the data

clear all; close all; clc

% load the data
load data_for_cell77
sampleRate = 50;      % sampling rate of neural data and behavioral variables is 50Hz

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

%% fit the model

fit_all_ln_models

%% find the simplest model that best describes the spike train

select_best_model

%% Compute the firing-rate tuning curves

compute_all_tuning_curves

%% plot the results

plot_performance_and_parameters
