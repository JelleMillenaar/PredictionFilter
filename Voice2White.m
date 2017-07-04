% V2W = Voice2White( i_Signal, i_StartBin, i_EndBin)
%
% Voice2White calculates the ratio between the frequencies of human
% speech and all the frequencies.  
%
%% Input
% i_Signal = The audio envelopes of the audiosignal.
% i_StartBin = The ID of the first speech bin.
% i_EndBin = The ID of the last speech bin.
%
%% Ouput
% V2W = Array of audiolength that contains the V2W ratio over time.
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function V2W = Voice2White( i_Signal, i_StartBin, i_EndBin )
    %Prepare data
    AudioLength = size(i_Signal,1);
    BinCount = size(i_Signal,2);
    if( BinCount < i_StartBin || BinCount < i_EndBin || i_EndBin < i_StartBin )
        DisplayMessages("Invalid bin id's given to V2W function");
    end
    V2W = zeros( AudioLength, 1);
    
    %Calculate the rest
    for i=1:AudioLength
        V2W(i) = sum(i_Signal(i,(i_StartBin:i_EndBin))) / (sum(i_Signal(i,:))+eps(1));
    end

end