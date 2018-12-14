classdef Always < ptb.XYBounds
  
  methods
    function obj = Always()
      
      %   ALWAYS -- Always in bounds.
      %
      %     obj = ptb.bounds.Always() returns an object whose `test` method
      %     always returns true.
      %
      %     See also ptb.XYBounds, ptb.XYBounds.test
      
      obj = obj@ptb.XYBounds();
    end
  end
  
  methods (Access = public)
    function tf = test(obj, x, y)
      tf = true;
    end
  end
end