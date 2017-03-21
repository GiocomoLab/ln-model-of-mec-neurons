%%% plot the model-derived response profiles, the tuning curves, and the
%%% model fits

%% plot the tuning curves

% create x-axis vectors
hd_vector = 2*pi/n_dir_bins/2:2*pi/n_dir_bins:2*pi - 2*pi/n_dir_bins/2;
theta_vector = hd_vector;
speed_vector = 2.5:50/n_speed_bins:47.5;

% plot the tuning curves
figure(1)
subplot(3,4,1)
imagesc(pos_curve); colorbar
axis off
title('Position')
subplot(3,4,2)
plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
title('Head direction')
subplot(3,4,3)
plot(speed_vector,speed_curve,'k','linewidth',3)
box off
xlabel('Running speed')
axis([0 50 -inf inf])
title('Speed')
subplot(3,4,4)
plot(theta_vector,theta_curve,'k','linewidth',3)
xlabel('Theta phase')
axis([0 2*pi -inf inf])
box off
title('Theta')

%% compute and plot the model-derived response profiles

% show parameters from the full model
param_full_model = param{1};

% pull out the parameter values
pos_param = param_full_model(1:n_pos_bins);
hd_param = param_full_model(n_pos_bins+1:n_pos_bins+n_dir_bins);
speed_param = param_full_model(n_pos_bins+n_dir_bins+1:n_pos_bins+n_dir_bins+n_speed_bins);
theta_param = param_full_model(numel(param)-n_theta_bins+1:numel(param));

% compute the scale factors
scale_factor_pos = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(theta_param))*50;
scale_factor_hd = mean(exp(speed_param))*mean(exp(pos_param))*mean(exp(theta_param))*50;
scale_factor_spd = mean(exp(pos_param))*mean(exp(hd_param))*mean(exp(theta_param))*50;
scale_factor_theta = mean(exp(speed_param))*mean(exp(hd_param))*mean(exp(pos_param))*50;

% compute the model-derived response profiles
pos_response = scale_factor_pos*exp(pos_param);
hd_response = scale_factor_hd*exp(hd_param);
speed_response = scale_factor_spd*exp(speed_param);
theta_response = scale_factor_theta*exp(theta_param);

% plot the model-derived response profiles
subplot(3,4,5)
imagesc(reshape(pos_response,20,20)); axis off; colorbar
subplot(3,4,6)
plot(hd_vector,hd_response,'k','linewidth',3)
xlabel('direction angle')
box off
axis([0 2*pi -inf inf])
box off
subplot(3,4,7)
plot(speed_vector,speed_response,'k','linewidth',3)
xlabel('Running speed')
axis([0 50 -inf inf])
box off
subplot(3,4,8)
plot(theta_vector,theta_response,'k','linewidth',3)
xlabel('Theta phase')
axis([0 2*pi -inf inf])
box off


%% compute and plot the model performances

% ordering:
% pos&hd&spd&theta / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
% pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta

LLH_increase_mean = mean(LLH_values);
LLH_increase_sem = std(LLH_values)/sqrt(iter);

figure(1)
subplot(3,4,9:12)
errorbar(LLH_increase_mean,LLH_increase_sem,'ok','linewidth',3)
hold on
errorbar(LLH_increase_mean(selected_model),LLH_increase_sem(selected_model),'or','linewidth',3)
plot(0.5:15.5,zeros(16,1),'--b','linewidth',2)
hold off
box off
set(gca,'fontsize',20)
set(gca,'XLim',[0 16]); set(gca,'XTick',1:15)
set(gca,'XTickLabel',{'PHST','PHS','PHT','PST','HST','PH','PS','PT','HS',...
    'HT','ST','P','H','S','T'});
legend('Model performance','Selected model','Baseline')
   

