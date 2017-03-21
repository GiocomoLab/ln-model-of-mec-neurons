%%%%%%% compute all of the tuning curves %%%%%%%%%

% take out times when the animal ran >= 50 cm/s
phase(too_fast) = [];
posx(too_fast) = []; posy(too_fast) = []; posx2(too_fast) = []; posy2(too_fast) = [];
posx_c(too_fast) = []; posy_c(too_fast) = []; speed(too_fast) = [];

% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(posx_c,posy_c,smooth_fr,n_pos_bins,0,boxSize);
[hd_curve] = compute_1d_tuning_curve(direction,smooth_fr,n_dir_bins,0,2*pi);
[spd_curve] = compute_1d_tuning_curve(direction,smooth_fr,n_speed_bins,0,50);
[theta_curve] = compute_1d_tuning_curve(phase,fr,n_theta_bins,0,2*pi);