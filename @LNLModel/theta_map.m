function [theta_grid,phaseVec,phase_time] = theta_map(self, nbins)

    %compute instantaneous phase
    hilb_eeg = hilbert(self.filt_eeg); % compute hilbert transform
    phase = atan2(imag(hilb_eeg),real(hilb_eeg)); %inverse tangent (-pi to pi)
    ind = phase <0; phase(ind) = phase(ind)+2*pi; % from 0 to 2*pi

    %give index in egf
    phase_ind = round(self.post*self.eeg_sample_rate);

    %if spikes happened after eeg stopped recording, remove
    phase_ind(phase_ind + 1>numel(self.filt_eeg)) = [];
    phase_time = phase(phase_ind+1); %gives phase of lfp at every time point

    theta_grid = zeros(length(self.post),nbins);
    phaseVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

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
