classdef Area
    properties (SetAccess = private)
        m_StartIndex;
        m_EndIndex;
    end %of private properties
    
    methods
         function this = Area(i_StartIndex, i_EndIndex)
             %Set Data
            this.m_StartIndex = i_StartIndex;
            this.m_EndIndex = i_EndIndex;
        end % of constructor
        
        function Size = GetSize(this)
           Size = this.m_EndIndex - this.m_StartIndex; 
        end %of GetSize()
        
        function this = SetStartIndex(this, i_StartIndex)
            this.m_StartIndex = i_StartIndex;
        end
        
        function this = SetEndIndex(this, i_EndIndex)
            this.m_EndIndex = i_EndIndex;
        end
        
    end %of methods
end %of Area class