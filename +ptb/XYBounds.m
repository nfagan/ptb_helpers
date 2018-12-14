classdef XYBounds < handle
  
  methods
    function obj = XYBounds()
      
      %   XYBOUNDS -- Abstract interface to test if (X, Y) samples are in
      %     bounds.
      %
      %     See also ptb.XYBounds.test, ptb.bounds.Always, 
      %       ptb.bounds.Never, ptb.XYTarget
      
    end
  end
  
  methods (Abstract = true)
    %   TEST -- Test whether (X, Y) position is in bounds.
    %
    %     tf = test( obj, x, y ); returns a logical scalar value `tf`
    %     indicating whether the current (`x`, `y`) coordinate is
    %     considered in bounds.
    %
    %     Objects that subclass the ptb.XYBounds class can (must) implement
    %     this method according to their own logic.
    %
    %     See also ptb.XYTarget, ptb.XYBounds
    test(obj, x, y);
  end
  
end