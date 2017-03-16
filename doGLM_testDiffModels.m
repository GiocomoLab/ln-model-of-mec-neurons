function [] = doGLM_testDiffModels()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% clear workspace
clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load spreadsheet
[~,~,data] = xlsread('Wildtype_Mice_Database_v5.xlsx');

% nighteyes - NE (an animal) - recordings were from deeper layers of MEC.
% excluded from this analyses
withoutNE = 878;
Coverage = cell2mat(data(2:withoutNE,44));
Session = data(2:withoutNE,11); 
Tetrode = data(2:withoutNE,3);
Unit = data(2:withoutNE,4);
BoxSize = data(2:withoutNE,13);
numCell = numel(Tetrode);

goodCov = find(Coverage > 75); % a hard-coded threshold (75% of environment covered)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize matrices
trainFit_all = cell(numCell,1);
testFit_all = cell(numCell,1);
paramMat = cell(numCell,1);
paramNullMat = cell(numCell,1); % old way - paramNullMat = nan(numCell,numParam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do the for loop

for n = goodCov'
    n
    %%%%%%%%%%%%%%%%%%%%%%%% LOAD ALL FILES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %find directory
    session_dir = Session{n};
    
    session_dir_split =  strsplit(session_dir,'\');
    session_dir_short = session_dir_split{end};
    animalName = session_dir_split{end-2};

    %prefix = 'C:\Users\khardcas\Google Drive\GLM data\All cells\';
    prefix = '/Users/kiah/Desktop/GLM Project/Data/';
    
    %find pos file
    posfile = strcat(prefix,animalName,'_',session_dir_short,'_pos.mat');
    
    %find spike file
    spikefile = strcat(prefix,animalName,'_',session_dir_short,'_T',num2str(Tetrode{n}),'C',num2str(Unit{n}),'.mat');
    
    % find eeg file
    eegfile = strcat(prefix,animalName,'_',session_dir_short,'_eeg.mat');
    load(eegfile);

    %%%%%%%%%%%%%%%%%%%%%%%% COLLECT PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %collect rate map
    [trainFit,testFit,param,param_null] = createGLM_testDiffModels(posfile,spikefile,filt_eeg,sampleRate,BoxSize{n});
    trainFit_all{n} = trainFit;
    testFit_all{n} = testFit;
    paramMat{n} = param;
    paramNullMat{n} = param_null;
    %save('GLM_testDiffModels_jul19_centerPos_303.mat','trainFit_all','testFit_all','paramMat','paramNullMat','Session','Tetrode','Unit','BoxSize','Coverage')
end

return