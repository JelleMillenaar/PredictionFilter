% [o_Filters, o_Frequencies] = CreateLogFilters(i_LowFrequency, i_MaxFrequency, i_BinCount, i_NyquistFrequency)
%
% CreateLogFilters() creates and returns a set of filters and their central
% frequency. The filter can be used to split a single audio single into
% several frequency bins. The frequencybins are logaritmically spaced.
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
function [o_Filters, o_Frequencies] = CreateLogFilters(i_LowFrequency, i_MaxFrequency, i_BinCount, i_Frequencies, i_NyquistFrequency )
    %Prepare the data
    o_Filters = zeros(i_NyquistFrequency+1, i_BinCount);
    
    %make center frequencies evenly spaced on a log scale
    %want highest cos filter to go up to hi_lim
    %i_Frequencies = i_Frequencies./10;
    o_Frequencies = 2.^([log2(i_LowFrequency) : (log2(i_MaxFrequency)-log2(i_LowFrequency))/(i_BinCount-1) : log2(i_MaxFrequency)]);

    %easy-to-implement version: filters are symmetric on linear scale
    for k=1:i_BinCount
        bw = o_Frequencies(k)/2; %Q == 2
        l = o_Frequencies(k)-bw; %so that half power point is at Cf-bw/2
        h = o_Frequencies(k)+bw;
        l_ind = find(i_Frequencies>l, 1 );
        h_ind = find(i_Frequencies<h, 1, 'last' );
        avg = o_Frequencies(k); %(log2(l+1)+log2(h+1))/2;
        rnge = h-l;%(log2(h+1)-log2(l+1));
        o_Filters(l_ind:h_ind,k) = cos((i_Frequencies(l_ind:h_ind) - avg)/rnge*pi); %map cutoffs to -pi/2, pi/2 interval
    end

    temp = sum(o_Filters'.^2);
    o_Filters=o_Filters/sqrt(mean(temp(i_Frequencies>=o_Frequencies(4) & i_Frequencies<=o_Frequencies(end-3))));
    %Add low and high pass filter
    %o_Frequencies(2:i_BinCount+1) = o_Frequencies(1:i_BinCount);
    %o_Frequencies(1) = 0.5;
    %h_ind = max(find(i_Frequencies<o_Frequencies(2))); %lowpass filter goes up to peak of first cos filter
    %o_Filters(1:h_ind,1) = sqrt(1 - o_Filters(1:h_ind,2).^2);
end