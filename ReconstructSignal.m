% TemporalData = ReconstructSignal( i_Envelopes, i_Phases )
%
% Reconstructs the temporal signal from the envelopes and phases.
%
%% Input
% i_Envelopes = The envelopes of the subbands
% i_Phases = The instantaneous phases of the subbands. These have been
% returned by the HilbertTransform() function.
%
%% Output
% TemporalData = The temporal audiodata of the signal.

%% function
function TemporalData = ReconstructSignal(i_Envelopes, i_Phases)
    %Reconstruct the sound from the analytic signal
    TemporalBins = real(i_Envelopes.*exp(complex(zeros(size(i_Envelopes)), i_Phases)));
    TemporalData = zeros(length(TemporalBins(:,1)), 1);
    for i=1:length(TemporalBins(1,:))
       TemporalData = TemporalData + TemporalBins(:,i);
    end
    TemporalData = max(0,TemporalData);
end