classdef XYSource < handle
  
  properties (GetAccess = public, SetAccess = protected)
    X = nan;
    Y = nan;
    
    IsNewSample = false;
    IsValidSample = false;
  end
  
  methods
    function obj = XYSource()
      
      %   XYSOURCE -- Abstract superclass for gaze position sources.
      %
      %     This class serves as an interface, and is not meant to be
      %     directly instantiated.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
  end
  
  methods (Access = public)
    function update(obj)
      
      %   UPDATE -- Update gaze data to latest sample, if available.
      %
      %     update( obj ) attempts to fetch the latest gaze sample from
      %     Eyelink and assign it to the X and Y coordinates of the 
      %     EyelinkSource `obj`. If the EyelinkSource is not recording, or 
      %     if no new sample is available, the X and Y coordinates remain 
      %     unchanged.
      %
      %     See also ptb.EyelinkSource, ptb.EyelinkSource.initialize
      %
      %     OUT:
      %       - `is_new_sample` (logical)
      
      obj.IsNewSample = false;
      
      if ( ~new_sample_available(obj) )
        return
      end
      
      obj.IsNewSample = true;
      
      [x, y, success] = get_latest_sample( obj );
      
      if ( ~success )
        obj.IsValidSample = false;
        return
      end
      
      obj.X = x;
      obj.Y = y;
      
      obj.IsValidSample = true;
    end
  end
  
  methods (Abstract, Access = protected)
    new_sample_available(obj);
    get_latest_sample(obj);
  end
  
end