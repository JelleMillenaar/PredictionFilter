% [o_Envelope, o_Phase] = HilbertTransform( i_Signal )
%
% Calculated the instantaneous amplitute and phase throught the hilbert
% transform. The amplitute is the envelope and can be further used. The
% phase is mostly useful for later reconstruction of the original signal.
%
%% Input
% i_Signal = Audiodata.
%
%% Output
% o_Envelope = The envelope of the signal, also known as the instantaneous
% amplitue.
% o_Phase = The instantaneous phase, which can be used for reconstruction
% of the signal using ReconstructSignal()
%
% May 2017 - Jelle Femmo Millenaar

%% function
function [o_Envelope, o_Phase] = HilbertTransform( i_Signal )
    Temp = hilbert(i_Signal);
    o_Phase = angle(Temp);
    o_Envelope = abs(Temp);
end 