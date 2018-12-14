classdef Never < ptb.XYBounds
  
  methods
    function obj = Never()
      
      %   NEVER -- Never in bounds.
      %
      %     obj = ptb.bounds.Never() returns an object whose `test` method
      %     always returns false.
      %
      %     See also ptb.XYBounds, ptb.XYBounds.test, ptb.bounds.Always
      
      obj = obj@ptb.XYBounds();
    end
  end
  
  methods (Access = public)
    function tf = test(obj, x, y)
      tf = false;
    end
  end
end