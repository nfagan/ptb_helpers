classdef XYSource < handle
  
  properties (GetAccess = public, SetAccess = protected)
    %   X -- Latest X coordinate.
    %
    %     X is a read-only double scalar giving the latest X-pixel
    %     coordinate.
    %
    %     See also ptb.XYSource, ptb.XYSource.Y
    X = nan;
    
    %   Y -- Latest Y coordinate.
    %
    %     Y is a read-only double scalar giving the latest Y-pixel
    %     coordinate.
    %
    %     See also ptb.XYSource, ptb.XYSource.X, ptb.XYSource.IsNewSample
    Y = nan;
    
    %   ISNEWSAMPLE -- True if (X, Y) coordinates were updated.
    %
    %     IsNewSample is a read-only logical scalar indicating whether the
    %     current X and Y coordinates were updated during the call to
    %     `update`.
    %
    %     See also ptb.XYSource, ptb.XYSource.IsValidSample, 
    %       ptb.XYSource.update
    IsNewSample = false;
    
    %   ISVALIDSAMPLE -- True if current (X, Y) coordinates are valid.
    %
    %     IsValidSample is a read-only logical scalar indicating whether
    %     the current X and Y coordinates are valid. What it means for a
    %     sample to be valid is determined by the subclassing object --
    %     for example, to an EyelinkSource, a valid sample is one that is
    %     not nan.
    %
    %     See also ptb.XYSource, ptb.XYSource.IsNewSample, ptb.XYSource.update
    IsValidSample = false;
  end
  
  methods
    function obj = XYSource()
      
      %   XYSOURCE -- Abstract superclass for gaze position sources.
      %
      %     This class serves as an interface, and is not meant to be
      %     directly instantiated.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource, ptb.XYSource.X,
      %       ptb.XYSource.IsValidSample
      
    end
  end
  
  methods (Access = public)
    function update(obj)
      
      %   UPDATE -- Update gaze data to latest sample, if available.
      %
      %     update( obj ) attempts to fetch the latest gaze sample from
      %     the underlying source and assign it to the X and Y coordinates 
      %     of `obj`. If no new sample is available, the X and Y 
      %     coordinates remain unchanged.
      %
      %     After calling this function, the IsNewSample and IsValidSample
      %     properties can be used to assess the state of the sample.
      %
      %     See also ptb.EyelinkSource, ptb.MouseSource, ptb.XYSource,
      %       ptb.XYSource.IsNewSample, ptb.XYSource.IsValidSample
      
      obj.IsNewSample = false;
      
      if ( ~new_sample_available(obj) )
        return
      end
      
      [x, y, success] = get_latest_sample( obj );
      
      obj.X = x;
      obj.Y = y;
      
      obj.IsValidSample = success;
      obj.IsNewSample = true;
    end
  end
  
  methods (Abstract, Access = protected)
    new_sample_available(obj);
    get_latest_sample(obj);
  end
  
end