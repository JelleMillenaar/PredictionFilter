%% PlotScaledColors( i_Signal, i_SpeechAreas)
%
% Plot a scaled color image of all the rows. 
%
%% Input
% i_Signal = The sound envelopes. This is mostly used for dimensions.
% i_SpeechAreas = Cell arrays of Area Objects when the speech areas are
% located.
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function PlotSpeechAreas(  i_Signal, i_SpeechAreas ) 
   %Prepare the speech array
   SpeechArray = zeros(size(i_Signal));
    
   %Loop through the frequencies in order to add the speech parts
   for i=1:size(i_Signal,2)
      %Loop through all SpeechAreas
      SpeechAreas = i_SpeechAreas{i};
      for k=1:size(SpeechAreas, 2)
          SpeechArray(SpeechAreas(k).m_StartIndex: SpeechAreas(k).m_EndIndex, i) = 1;
      end
   end
   
   PlotScaledColors(SpeechArray.', "Speech Areas", "Samples", "Frequencies(Hz)");
end