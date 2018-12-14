classdef Clock < handle
  
  properties (Access = private)
    timer;
  end
  
  methods
    function obj = Clock()
      
      %   CLOCK -- Create Clock instance.
      %
      %     obj = ptb.Clock() creates a Clock object -- a simple wrapper
      %     around Matlab's tic / toc functions.
      %
      %     After creating the object, the `elapsed` function gives the
      %     elapsed time since the object was created; the `reset` function
      %     can be used to reset the clock to 0.
      %
      %     See also ptb.Clock.elapsed
      
      reset( obj );
    end
  end
  
  methods (Access = public)
    function reset(obj)
      
      %   RESET -- Reset clock to 0.
      %
      %     See also ptb.Clock.Clock
      
      obj.timer = tic();
    end
    
    function t = elapsed(obj)
      
      %   ELAPSED -- Elapsed time in seconds.
      %
      %     elapsed( obj ) gives the elapsed time in seconds since the last
      %     call to `reset`. `reset` is also called internally upon object 
      %     construction.
      %
      %     See also ptb.Clock.reset
      %
      %     OUT:
      %       - `t` (double)
      
      t = toc( obj.timer );      
    end
    
    function disp(obj)
      fprintf( '  ptb.Clock instance | elapsed: %0.5f (s)\n\n', elapsed(obj) );
    end
  end
  
end