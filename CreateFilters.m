% [o_Filters, o_Frequencies] = CreateFilters(i_FilterType, i_LowFrequency,
% i_MaxFrequency, i_BinCount, i_FilterSamplesize, i_TotalSamplesize)
%
% CreateErbFilters() creates and returns a set of filters and their central
% frequency. The filter can be used to split a single audio single into
% several frequency bins. The frequency bins have a 50% overlap and the two
% outer bins are low and highpass. This allows for perfect reconstruction
% of the audiosignal. 
%
%% Input
% i_FilterType is the identifier for using specific filter designs. The
% filter types are defined in the FilterType enumeration
%
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
% Based on Dec 2012 - Josh McDermott
% May 2017 - Jelle Femmo Millenaar

%% Function
function [o_Filters, o_Frequencies] = CreateFilters(i_FilterType, i_LowFrequency, i_MaxFrequency, i_BinCount, i_FilterSamplesize, i_TotalSamplesize)
    %Prepare the data
    NyquistFrequency = i_FilterSamplesize/2;
    MaxFrequency = i_TotalSamplesize/2;
    Frequencies = [0:MaxFrequency/NyquistFrequency:MaxFrequency]; %go all the way to nyquist

    %Verify i_MaxFrequency
    if i_MaxFrequency > MaxFrequency
        i_MaxFrequency = MaxFrequency;
    end
    
    %Create filters
    if( i_FilterType == FilterType.Erb ) % ErbFilters
        [ o_Filters, o_Frequencies ] = CreateErbFilters( i_LowFrequency, i_MaxFrequency, i_BinCount, Frequencies, NyquistFrequency );
    elseif( i_FilterType == FilterType.Log) % LogFilters
        [ o_Filters, o_Frequencies ] = CreateLogFilters( i_LowFrequency, i_MaxFrequency, i_BinCount, Frequencies, NyquistFrequency );
    end
end