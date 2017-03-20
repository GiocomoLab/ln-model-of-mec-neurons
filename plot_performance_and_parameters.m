%% LOTS OF PLOTTING STUFF
% original ordering:
% full / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
% pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta

% order for the plotting in the paper:
% pos / hd / speed / theta /  pos & hd / pos&spd / pos&th/ hd&spd / hd&theta / spd&theta /
% pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / full

% plot the null and glm features
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