%% SNR = SlidingSNR( a_aSignal, a_aNoise, a_iWindowSize, a_iStepSize )
%
% Calculates the SNR over time using a sliding window. 
%
%% Input
% a_aSignal = AudioData about the Signal/Target
%
% a_aNoise = AudioData about the Noise
%
% a_iWindowSize = Size of the window in samples to calculate the SNR
%
% a_iStepSize = The number of samples the window will move for the next SNR
% calculatation
%
%% Output
% SNR = Array of SNR for every window of the signal.
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function SNR = SlidingSNR( a_aSignal, a_aNoise, a_iWindowSize, a_iStepSize )
    %Check file lengths
    SignalLength = length(a_aSignal);
    if( SignalLength ~= length(a_aNoise))
        DisplayWarning("Audiofiles do not have the same length.");
        return;
    end
    
    %Loop through the windows
    WindowCount = floor((SignalLength-a_iWindowSize) /a_iStepSize);
    SNR = zeros(WindowCount, 1);
    EndWindow = a_iWindowSize+1;
    for k = 1:WindowCount
        StartWindow = EndWindow-a_iWindowSize;
        SNR(k) = sum(a_aSignal(StartWindow:EndWindow).^2)./sum(a_aNoise(StartWindow:EndWindow).^2);
        EndWindow = EndWindow + a_iStepSize;
    end
    
end