classdef SnrArea < Area
    properties (SetAccess = private)
        m_SNR;
    end %of private properties
    
    methods
        function this = SnrArea(i_StartIndex, i_EndIndex)
             %Area Initization
             this = this@Area(i_StartIndex, i_EndIndex);
             
             %Create data array
             this.m_SNR = zeros( i_EndIndex - i_StartIndex, 1);             
        end % of constructor
        
        function this = CalculateSNR(this, i_Data, Noise)           
           %Correct for 0 data
           i_Data(this.m_StartIndex:this.m_EndIndex) = (i_Data(this.m_StartIndex:this.m_EndIndex) == 0) * eps(1) + i_Data(this.m_StartIndex:this.m_EndIndex);
            
            %Calculate the SNR
           this.m_SNR = 10 * log(i_Data(this.m_StartIndex:this.m_EndIndex) / Noise);
           if( ~isreal(mean(this.m_SNR)) )
               disp("Derp");
           end
        end %of CalculateSNR()
        
        function SNR = GetAverageSNR(this)
           SNR = mean( this.m_SNR ); 
        end %of GetAverageSNR()
        
    end %of methods
end %of SnrArea class