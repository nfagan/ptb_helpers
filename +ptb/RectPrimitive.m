classdef RectPrimitive
  
  methods
    function obj = RectPrimitive()
    end
  end
  
  methods (Access = public, Abstract = true)
    get(obj);
  end
  
end