%%% analyze results from the GLM model %%%%%
% Explanation of script:
% This takes the output from doGLM_testDiffModels.m (the output is
% doGLM_testDiffModels_output), and figures out the 'best' model for each
% cell (which is saved in 'cellType'). It also plots the tuning curves and
% response profiles (exponentiated parameters) for each cell.

%% clear workspace
clear all; clc; close all

%% load TCS data
[~,~,data] = xlsread('Wildtype_Mice_Database_v5.xlsx');

withoutNE = 878;
GridScore = data(2:withoutNE,23); % it's 2 because of the header in the excel file
HDScore = data(2:withoutNE,43);
BorderScore = data(2:withoutNE,45);
SpeedScore = data(2:withoutNE,end); % this is the speed correlation
Coverage = cell2mat(data(2:withoutNE,44));
goodCov = find(Coverage > 75); % these are the cells I will analyze
numCell = length(goodCov);

%% load model output - this is from doGLM
load doGLM_testDiffModels_output
iter = 10; % number of folds
n_pos_bins = 400; n_dir_bins = 18; n_speed_bins = 10; n_theta_bins = 18;

% take away low-coverage sessions
paramMat = paramMat(goodCov);
paramNullMat = paramNullMat(goodCov,:);
testFit_all = testFit_all(goodCov);
trainFit_all = trainFit_all(goodCov);


%% initialize matrices

allSelectedModels = nan(numCell,3); % best single, double, triple
LLH_increase = nan(numCell,15,2);
cellType = nan(numCell,1);
varExp = nan(numCell,15);
corrCoeff = nan(numCell,15);

for k = 1:numel(goodCov)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    temp_test = testFit_all{k}; 
    % temp_test is a 15x1 cell - 15 because there are 15 models
    % temp_test{i} is a 10x6 matrix - 10 b/c of 10 folds - 3rd column is
    % LLH increase, 1st is var exp, 2nd is correlation coeff
    LLH_all = nan(iter,15);
    for m = 1:15
        temp = log2(exp(1))*temp_test{m}(:,3); % change from nats to bits      
        LLH_all(:,m) = temp;
        LLH_increase(k,m,:) = [nanmean(temp) nanstd(temp)./sqrt(numel(temp))];
        varExp(k,m) = nanmean(temp_test{m}(:,1));
        corrCoeff(k,m) = nanmean(temp_test{m}(:,2));
    end
    
    %% LOTS OF PLOTTING STUFF
    % original ordering:
    % full / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
    % pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta
    
    % order for the plotting in the paper:
    % pos / hd / speed / theta /  pos & hd / pos&spd / pos&th/ hd&spd / hd&theta / spd&theta /
    % pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / full
    
    newOrder = [12 13 14 15 6 7 8 9 10 11 2 3 4 5 1];
    figure(1)
    subplot(3,4,9:12)
    errorbar(LLH_increase(k,newOrder,1),LLH_increase(k,newOrder,2),'ok','linewidth',3)
    hold on
    plot(LLH_increase(k,newOrder,1),'or','linewidth',3)
    plot(0.5:15.5,zeros(16,1),'--b','linewidth',2)
    hold off
    box off
    set(gca,'fontsize',20)
    set(gca,'XLim',[0 16]); set(gca,'XTick',[1:15])
    set(gca,'XTickLabel',{'P','H','S','T','PH','PS','PT','HS',...
        'HT','ST','PHS','PHT','PST','HST','PHST'});
    
    % plot the null and glm features
    param = paramMat{k}{1};
    pos_ind = 1:n_pos_bins; pos_param = param(pos_ind);
    hd_ind = n_pos_bins+1:n_pos_bins+n_dir_bins; hd_param = param(hd_ind);
    spd_ind = n_pos_bins+n_dir_bins+1:n_pos_bins+n_dir_bins+n_speed_bins;
    speed_param = param(spd_ind);
    th_ind = numel(param)-n_theta_bins+1:numel(param);
    theta_param = param(th_ind);
    
    scale_factor_pos = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(theta_param))*50;
    scale_factor_hd = mean(exp(speed_param))*mean(exp(pos_param))*mean(exp(theta_param))*50;
    scale_factor_spd = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(theta_param))*50;
    scale_factor_theta = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(pos_param))*50;
    
    pos_param = scale_factor_pos*exp(pos_param);
    hd_param = scale_factor_hd*exp(hd_param);
    speed_param = scale_factor_spd*exp(speed_param);
    theta_param = scale_factor_theta*exp(theta_param);
    
    null_param= paramNullMat(k,:);
    null_grid_param = null_param(pos_ind);
    null_HD_param = null_param(hd_ind);
    null_speed_param = null_param(spd_ind);
    null_th_param = null_param(th_ind);
    
    maxVal_pos = min([max(pos_param) max(null_grid_param)]);
    maxVal_pos = maxVal_pos - 0.1*maxVal_pos;
    minVal_pos = min([min(pos_param) min(null_grid_param)]);
    
    maxVal = max([max(hd_param) max(speed_param) max(theta_param) ...
        max(null_HD_param) max(null_speed_param) max(null_th_param)]);
     minVal = min([min(hd_param) min(speed_param) min(theta_param) ...
        min(null_HD_param) min(null_speed_param) min(null_th_param)]);
    
    HDVec = 2*pi/n_dir_bins/2:2*pi/n_dir_bins:2*pi - 2*pi/n_dir_bins/2;
    ThetaVec = HDVec;
    SpeedVec = 2.5:50/n_speed_bins:47.5;
    
    figure(1)
    subplot(3,4,1)
    imagesc(reshape(null_grid_param,20,20)); colorbar
    g_score = num2str(round(GridScore{goodCov(k)}*10)/10);
    b_score = num2str(round(BorderScore{goodCov(k)}*10)/10);
    title(['Grid score = ',g_score,' Border score = ',b_score])
    caxis([minVal_pos maxVal_pos])
    axis off
    subplot(3,4,2)
    plot(HDVec,null_HD_param,'k','linewidth',3)
    box off
    axis([0 2*pi minVal maxVal])
    xlabel('Head direction')
    h_score = num2str(HDScore{goodCov(k)});
    title(['HD score = ',h_score])
    subplot(3,4,3)
    plot(SpeedVec,null_speed_param,'k','linewidth',3)
    box off
    xlabel('Running speed')
    axis([0 50 minVal maxVal])
    s_score = num2str(SpeedScore{goodCov(k)});
    title(['Speed score = ',s_score])
    subplot(3,4,4)
    plot(ThetaVec,null_th_param,'k','linewidth',3)
    xlabel('Theta phase')
    axis([0 2*pi minVal maxVal])
    box off
    
    subplot(3,4,5)
    imagesc(reshape(pos_param,20,20)); axis off; colorbar
    caxis([minVal_pos maxVal_pos])
    subplot(3,4,6)
    plot(HDVec,hd_param,'k','linewidth',3)
    xlabel('Head direction')
    title('FR vs HD')
    box off
    axis([0 2*pi minVal maxVal])
    box off
    subplot(3,4,7)
    plot(SpeedVec,speed_param,'k','linewidth',3)
    xlabel('Running speed')
    title('FR vs Speed')
    axis([0 50 minVal maxVal])
    box off
    subplot(3,4,8)
    plot(ThetaVec,theta_param,'k','linewidth',3)
    xlabel('Theta phase')
    title('FR vs Theta')
    axis([0 2*pi minVal maxVal])
    box off

    %% FIND THE BEST MODEL
    % the model indexing scheme I am using:
    % phst, phs, pht, pst, hst, ph, ps, pt, hs, ht, st, p,  h,  s,  t
    % 1      2    3    4    5    6   7  8   9   10  11  12  13  14  15
    
    % find the best single model
    [~,top1] = max(nanmean(LLH_all(:,12:15))); top1 = top1 + 11;
    
    % find the best double model that includes the single model
    if top1 == 12 % P -> PH, PS, PT
        [~,top2] = max(nanmean(LLH_all(:,[6 7 8]))); 
        vec = [6 7 8]; top2 = vec(top2);
    elseif top1 == 13 % H -> PH, HS, HT
        [~,top2] = max(nanmean(LLH_all(:,[6 9 10]))); 
        vec = [6 9 10]; top2 = vec(top2);
    elseif top1 == 14 % S -> PS, HS, ST
        [~,top2] = max(nanmean(LLH_all(:,[7 9 11]))); 
        vec = [7 9 11]; top2 = vec(top2);
    else % T -> PT, HT, ST
        [~,top2] = max(nanmean(LLH_all(:,[8 10 11]))); 
        vec = [8 10 11]; top2 = vec(top2);
    end
    
    % find the best triple model that includes the double model
    if top2 == 6 % PH-> PHS, PHT
        [~,top3] = max(nanmean(LLH_all(:,[2 3])));
        vec = [2 3]; top3 = vec(top3);
    elseif top2 == 7 % PS -> PHS, PST
        [~,top3] = max(nanmean(LLH_all(:,[2 4])));
        vec = [2 4]; top3 = vec(top3);
    elseif top2 == 8 % PT -> PHT, PST
        [~,top3] = max(nanmean(LLH_all(:,[3 4])));
        vec = [3 4]; top3 = vec(top3);
    elseif top2 == 9 % HS -> PHS, HST
        [~,top3] = max(nanmean(LLH_all(:,[2 5])));
        vec = [2 5]; top3 = vec(top3);
    elseif top2 == 10 % HT -> PHT, HST
        [~,top3] = max(nanmean(LLH_all(:,[3 5])));
        vec = [3 5]; top3 = vec(top3);
    elseif top2 == 11 % ST -> PST, HST
        [~,top3] = max(nanmean(LLH_all(:,[4 5])));
        vec = [4 5]; top3 = vec(top3);
    end

    top4 = 1;
    
    % this is just to check later if I want
    allSelectedModels(k,:) = [top1 top2 top3]; %single, double, triple
    
    figure(2)
    subplot(1,3,1)
    LLH1 = LLH_all(:,top1); LLH2 = LLH_all(:,top2);
    LLH1(isnan(LLH2)) = []; LLH2(isnan(LLH2)) = [];
    LLH2(isnan(LLH1)) = []; LLH1(isnan(LLH1)) = [];
    plot(LLH1,LLH2,'ok','linewidth',5)
    maxLLH = max(max(LLH1),max(LLH2));
    hold on
    plot([min(LLH1) maxLLH],[min(LLH1) maxLLH],'r','linewidth',3)
    hold off
    axis tight
    box off
    set(gca,'fontsize',20)
    xlabel('Single')
    ylabel('Double')
    if ~isempty(LLH2)
        [p_llh_12,~] = signrank(LLH2,LLH1,'tail','right');
    else
        p_llh_12 = NaN;
    end
    title(['p-llh = ',num2str(round(p_llh_12*100)/100)])
    
    subplot(1,3,2)
    LLH2 = LLH_all(:,top2); LLH3 = LLH_all(:,top3);
    LLH2(isnan(LLH3)) = []; LLH3(isnan(LLH3)) = [];
    LLH3(isnan(LLH2)) = []; LLH2(isnan(LLH2)) = [];
    plot(LLH2,LLH3,'ok','linewidth',5)
    maxLLH = max(max(LLH2),max(LLH3));
    hold on
    plot([min(LLH2) maxLLH],[min(LLH2) maxLLH],'r','linewidth',3)
    hold off
    axis tight
    box off
    set(gca,'fontsize',20)
    xlabel('Double')
    ylabel('Triple')
    if ~isempty(LLH2)
        [p_llh_23,~] = signrank(LLH3,LLH2,'tail','right');
    else
        p_llh_23 = NaN;
    end
    title(['p-llh = ',num2str(round(p_llh_23*100)/100)])
    
    subplot(1,3,3)
    LLH3 = LLH_all(:,top3); LLH4 = LLH_all(:,top4);
    LLH3(isnan(LLH4)) = []; LLH4(isnan(LLH4)) = [];
    LLH4(isnan(LLH3)) = []; LLH3(isnan(LLH3)) = [];
    plot(LLH3,LLH4,'ok','linewidth',5)
    maxLLH = max(max(LLH4),max(LLH3));
    hold on
    plot([min(LLH4) maxLLH],[min(LLH3) maxLLH],'r','linewidth',3)
    hold off
    axis tight
    box off
    set(gca,'fontsize',20)
    xlabel('Triple')
    ylabel('Full')
    if ~isempty(LLH3)
        [p_llh_34,~] = signrank(LLH4,LLH3,'tail','right');
    else
        p_llh_34 = NaN;
    end
    title(['p-llh = ',num2str(round(p_llh_34*100)/100)])
    
    if p_llh_12 < 0.05 % double model is sig. better
        if p_llh_23 < 0.05  % triple model is sig. better
            if p_llh_34 < 0.05 % full model is sig. better
                cellType(k) = 1; % full model
            else
                cellType(k) = top3; %triple model
            end
        else
            cellType(k) = top2; %double model
        end
    else
        cellType(k) = top1; %single model
    end
    
    figure(1)
    subplot(3,4,9:12)
    hold on
    % newOrder = [12 13 14 15 6 7 8 9 10 11 2 3 4 5 1];
    rev_newOrder = [15 11 12 13 14 5 6 7 8 9 10 1 2 3 4];
    plot(rev_newOrder(cellType(k)),LLH_increase(k,cellType(k),1),'og','linewidth',3)
    hold off
    
    % re-set if the selected model isn't significantly greater than mean
    % model
    temp_test = testFit_all{k};
    pval = nan(15,1);
    for m = 1:15
        temp = temp_test{m}(:,3);
        temp(isnan(temp)) = [];
        if ~isempty(temp)
            pval(m) = signrank(temp,[],'tail','right');
        end
    end
    
    if ~ (pval(cellType(k)) < 0.05)
        cellType(k) = NaN;
    else
        %{
        fig1 = figure(1);
        fig2 = figure(2);
        set(fig1,'units','pix','pos',[0,0,1200,900])
        set(fig2,'units','pix','pos',[0,0,900,300])
        epsfig = hgexport('factorystyle');
        epsfig.Format = 'eps';
        hgexport(fig1,['/Users/kiah/Dropbox/lnp-in-mec/Model_Fitting_and_Model_Selection/Example Cells/Param_',num2str(k)],epsfig,'Format','epsc')
        hgexport(fig2,['/Users/kiah/Dropbox/lnp-in-mec/Model_Fitting_and_Model_Selection/Example Cells/Fit_no2std',num2str(k)],epsfig,'Format','epsc')
        close all
        %}
    end
    k
end


