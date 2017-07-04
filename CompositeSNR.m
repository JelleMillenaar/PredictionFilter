%% SNR = CompositeSNR(a_aSignal, a_aNoise)
%
% Calculate the complete SNR of the two samples.
% Where SNR = Sum( Signal^2 / Noise^2 )
%
%% Input
% a_aSignal = AudioData about the Signal/Target
% a_aNoise = AudioData about the Noise
%
%% Output
% SNR = The ratio of the summed squared magnitude between the two samples.
%
% May 2017 - Jelle Femmo Millenaar 

%% Function
function SNR = CompositeSNR( a_aSignal, a_aNoise )
    %Check file lengths
    if( length(a_aSignal) ~= length(a_aNoise) )
        DisplayWarning("Audiofiles do not have the same length.");
        return;
    end
        
    % Calculate the SNR
    SNR = snr(a_aSignal, a_aNoise);

end

