% [o_Filters, o_Frequencies] = CreateErbFilters(i_LowFrequency, i_MaxFrequency, i_BinCount, i_NyquistFrequency)
%
% CreateErbFilters() creates and returns a set of filters and their central
% frequency. The filter can be used to split a single audio single into
% several frequency bins. The frequency bins have a 50% overlap and the two
% outer bins are low and highpass. This allows for perfect reconstruction
% of the audiosignal. 
%
%% Input
% i_LowFrequency is the lowest frequency that will be caught in the normal
% filters.
% 
% i_MaxFrequency is the highest frequency that will be caught in the normal
% filters. However, if this number is above the frequency that can be
% caught in the entire file (FileLength/2), it will be correct.
%
% i_BinCount is the amount of frequency bins that will be used to split the
% audiodata. The resulting bincount is actually 2 higher due to low and 
% highpass filters. 
%
% i_NyquistFrequency is the maximum frequency we can record. 
%
% i_Frequencies are the center frequencies of the filters we created
%
% Based on Dec 2012 - Josh McDermott
% May 2017 - Jelle Femmo Millenaar

%%Function
function [o_Filters, o_Frequencies] = CreateErbFilters(i_LowFrequency, i_MaxFrequency, i_BinCount, i_Frequencies, i_NyquistFrequency )
    %Prepare the data
    o_Filters = zeros(i_NyquistFrequency+1, i_BinCount + 2);
    
    %Calculate the middle of the frequency filters
    o_Frequencies = erb2freq([freq2erb(i_LowFrequency) : (freq2erb(i_MaxFrequency)-freq2erb(i_LowFrequency))/(i_BinCount+1) : freq2erb(i_MaxFrequency)]);
    if(i_MaxFrequency == 200 )
        o_Frequencies = [ 0, 0.5, 0.6854, 0.9394, 1.2877, 1.7651, 2.4195, 3.3164, 4.5459, 6.2312, 8.5413, 11.7078, 16.0482, 21.9977, 30.1527, 41.3311, 56.6536, 77.6566, 106.4459, 145.9081];
    end
    
    %Create the filters
    for k=1:i_BinCount
        l = o_Frequencies(k);
        h = o_Frequencies(k+2); %adjacent filters overlap by 50%
        l_ind = min(find(i_Frequencies>l));
        h_ind = max(find(i_Frequencies<h));
        avg = (freq2erb(l)+freq2erb(h))/2;
        rnge = (freq2erb(h)-freq2erb(l));
        o_Filters(l_ind:h_ind,k) = cos((freq2erb( i_Frequencies(l_ind:h_ind) ) - avg)/rnge*pi); %map cutoffs to -pi/2, pi/2 interval
    end
    
    %Add lowpass and highpass filters to allow perfect reconstruction
    o_Filters(:, 2:i_BinCount+1) = o_Filters(:, 1:i_BinCount);
    h_ind = max(find(i_Frequencies<o_Frequencies(2))); %lowpass filter goes up to peak of first cos filter
    o_Filters(1:h_ind,1) = sqrt(1 - o_Filters(1:h_ind,2).^2);
    l_ind = min(find(i_Frequencies>o_Frequencies(i_BinCount+1))); %highpass filter goes down to peak of last cos filter
    o_Filters(l_ind:i_NyquistFrequency+1,i_BinCount+2) = sqrt(1 - o_Filters(l_ind:i_NyquistFrequency+1,i_BinCount+1).^2);
end