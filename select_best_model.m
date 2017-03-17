% temp_test is a 15x1 cell - 15 because there are 15 models
% temp_test{i} is a 10x6 matrix - 10 b/c of 10 folds - 3rd column is
% LLH increase, 1st is var exp, 2nd is correlation coeff
iter = 10;
LLH_all = nan(iter,15);
for m = 1:15
    temp = log2(exp(1))*testFit{m}(:,3); % change from nats to bits
    LLH_all(:,m) = temp;
end

% plot the null and glm features
n_pos_bins = 400; n_dir_bins = 18; n_speed_bins = 10; n_theta_bins = 18;
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
LLH1 = LLH_all(:,top1); LLH2 = LLH_all(:,top2);
LLH1(isnan(LLH2)) = []; LLH2(isnan(LLH2)) = [];
LLH2(isnan(LLH1)) = []; LLH1(isnan(LLH1)) = [];
if ~isempty(LLH2)
    [p_llh_12,~] = signrank(LLH2,LLH1,'tail','right');
else
    p_llh_12 = NaN;
end

LLH2 = LLH_all(:,top2); LLH3 = LLH_all(:,top3);
LLH2(isnan(LLH3)) = []; LLH3(isnan(LLH3)) = [];
LLH3(isnan(LLH2)) = []; LLH2(isnan(LLH2)) = [];
if ~isempty(LLH2)
    [p_llh_23,~] = signrank(LLH3,LLH2,'tail','right');
else
    p_llh_23 = NaN;
end

LLH3 = LLH_all(:,top3); LLH4 = LLH_all(:,top4);
LLH3(isnan(LLH4)) = []; LLH4(isnan(LLH4)) = [];
LLH4(isnan(LLH3)) = []; LLH3(isnan(LLH3)) = [];

if ~isempty(LLH3)
    [p_llh_34,~] = signrank(LLH4,LLH3,'tail','right');
else
    p_llh_34 = NaN;
end

if p_llh_12 < 0.05 % double model is sig. better
    if p_llh_23 < 0.05  % triple model is sig. better
        if p_llh_34 < 0.05 % full model is sig. better
            cellType = 1; % full model
        else
            cellType = top3; %triple model
        end
    else
        cellType = top2; %double model
    end
else
    cellType = top1; %single model
end