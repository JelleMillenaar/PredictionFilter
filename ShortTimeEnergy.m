% STE = ShortTimeEnergy( i_Signal )
%
% Calculates and plots the ShortTimeEnergy of a signal. Short Time Energy
% is defined as the average spectral power across all frequencies. During
% speech onset and ending this number will spike. 
% 
%% Input
% i_Signal = The BinEnvelopes of an audiosignal.
%
%% Output
% STE = An array of Short Time Energy
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function STE = ShortTimeEnergy( i_Signal )
    %Prepare data
    AudioLength = size(i_Signal,1);
    BinCount = size(i_Signal,2);
    STE = zeros( AudioLength, 1);
    STE(1) = sum(i_Signal(1,:).^2) / BinCount;
    
    %Calculate the rest
    for i=2:AudioLength
        STE(i) = sum(i_Signal(i,:).^2) / BinCount;
    end
    
end