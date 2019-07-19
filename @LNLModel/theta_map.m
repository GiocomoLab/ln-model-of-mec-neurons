function [theta_grid,phaseVec,phase_time] = theta_map(self)

    %give index in egf
    phase_ind = round(self.post*self.eeg_sample_rate);

    %if spikes happened after eeg stopped recording, remove
    phase_ind(phase_ind + 1>numel(self.filt_eeg)) = [];
    phase_time = self.phase(phase_ind+1); %gives phase of lfp at every time point

    theta_grid = zeros(length(self.post), self.bins.theta);
    phaseVec = 2*pi/self.bins.theta/2:2*pi/self.bins.theta:2*pi-2*pi/self.bins.theta/2;

    for i = 1:numel(self.post)-1
        try
            % figure out the theta index
            [~, idx] = min(abs(phase_time(i)-phaseVec));
            theta_grid(i,idx) = 1;
        catch
            keyboard
        end

    end

end % function
