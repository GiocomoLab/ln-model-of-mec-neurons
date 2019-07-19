function [pos_curve, hd_curve, speed_curve, theta_curve] = compute_tuning_curves(self, smooth_firing_rate)
  
  pos_curve   = LNLModel.compute_2d_tuning_curve(self.posx_c, self.posy_c, smooth_firing_rate, self.bins.position, 0, self.box_size);
  hd_curve    = LNLModel.compute_1d_tuning_curve(self.sheaddir, smooth_firing_rate, self.bins.head_direction, 0, 2*pi))
  speed_curve = LNLModel.compute_1d_tuning_curve(self.speed, smooth_firing_rate, self.bins.speed, 0, 50);
  theta_curve = LNLModel.compute_1d_tuning_curve(self.phase, smooth_firing_rate, self.bins.theta, 0, 2*pi);

end % function
