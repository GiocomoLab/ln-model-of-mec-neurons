function [trainFit_all,testFit_all,param,param_null] = createGLM_testDiffModels(posfile,spikefile,filt_eeg,sampleRate,boxSize)

% load spike file
load(spikefile)

% load and rescale position file
[posx,posy,posx2,posy2,post] = rescalePos(posfile,boxSize,filt_eeg,sampleRate);
posx_c = mean([posx posx2],2); posy_c = mean([posy posy2],2); % compute average

% take out times when the animal ran over 50 cm/s - I don't totally trust
% these data points and I don't want test/train the model on junk
% compute speed matrix
n_speed_bins = 10;
[speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins);
too_fast = find(speed >= 50);
posx(too_fast) = []; posy(too_fast) = []; posx2(too_fast) = []; posy2(too_fast) = [];
posx_c(too_fast) = []; posy_c(too_fast) = []; speed(too_fast) = []; speedgrid(too_fast,:) = [];

% compute position matrix
n_pos_bins = 20; pos = [posx_c posy_c];
[posgrid, posVec] = pos_map(pos, n_pos_bins, boxSize);

% compute head direction matrix
n_dir_bins = 18;
[hdgrid,hdVec,direction] = hd_map(posx,posx2,posy,posy2,n_dir_bins);

% compute theta matrix
n_theta_bins = 18;
[thetagrid,thetaVec,phase] = theta_map(filt_eeg,post,sampleRate,n_theta_bins);

% find # of spikes in every 20 ms bin
[spiketrain] = computeFR(cellTS,post);

% take out times when the animal ran >= 50 cm/s
thetagrid(too_fast,:) = []; phase(too_fast) = []; spiketrain(too_fast) = [];

% smooth firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); %smooth over 100 ms
dt = (post(3)-post(2)); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same'); %returns vector same size as original

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIT MODELS - THERE ARE 15 POSSIBLE MODELS
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

keyboard

for n = 1:modelNum
    [testFit_all{n},trainFit_all{n},param{n}] = fit_model_kfold_fmin(A{n},dt,spiketrain,filter,modelType{n});
    
end

% null parameters
[rateMap] = computeRateMap(posx_c,posy_c,smooth_fr);
[hd_val] = computeHdMap(direction,n_dir_bins,smooth_fr);
[speed_fr_mean] = computeSpeedMap(speed,speedVec,smooth_fr);
[theta_val] = computeThetaMap(phase,thetaVec,fr);
param_null = [rateMap(:)' hd_val' speed_fr_mean' theta_val'];

return