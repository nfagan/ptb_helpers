classdef MouseSource < ptb.XYSource
  
  properties (Access = private)
    window_handle = 0;
  end
  
  methods
    function obj = MouseSource(window_handle)
      
      %   MOUSESOURCE -- Create MouseSource object instance.
      %
      %     obj = ptb.MouseSource() creates an interface for obtaining 
      %     (X, Y) position samples from a mouse. Mouse position is given
      %     with respect to window 0 (i.e., the full desktop).
      %
      %     obj = ptb.MouseSource( window_or_screen ) gets the mouse
      %     position with respect to the window or screen given by
      %     `window_or_screen`. An error is thrown if this index is
      %     invalid.
      %
      %     The underlying mouse-position querying depends on the
      %     `GetMouse` function in Psychtoolbox.
      %
      %     See also GetMouse, Screen, ptb.EyelinkSource,
      %       ptb.MouseSource.update
      
      obj = obj@ptb.XYSource();
      
      if ( nargin == 0 )
        window_handle = 0;
      else
        try
          window_handle = ptb.MouseSource.validate_window_handle( window_handle );
        catch err
          throw( err );
        end
      end
        
      obj.window_handle = window_handle;
    end
  end
  
  methods (Access = public)
    function initialize(obj, varargin)
      
      %   INITIALIZE -- Dummy initialization.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
    
    function start_recording(obj, varargin)
      
      %   START_RECORDING -- Dummy start_recording.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
    
    function stop_recording(obj, varargin)
      
      %   STOP_RECORDING -- Dummy stop_recording.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
    
    function receive_file(obj, varargin)
      
      %   RECEIVE_FILE -- Dummy recieve_file.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
    
    function send_message(obj, varargin)
      
      %   SEND_MESSAGE -- Dummy send_message.
      %
      %     See also ptb.MouseSource, ptb.EyelinkSource
      
    end
  end
  
  methods (Access = protected)
    function tf = new_sample_available(obj)
      tf = true;
    end
    
    function [x, y, success] = get_latest_sample(obj)
      [x, y] = GetMouse( obj.window_handle );
      success = true;
    end
  end
  
  methods (Access = private, Static = true)
    function window_handle = validate_window_handle(window_handle)
      validateattributes( window_handle, {'numeric'}, {'scalar', 'integer'} ...
          , mfilename, 'window_handle' );
      
      window_handle = double( window_handle );
      
      screens = Screen( 'Screens' );
      windows = Screen( 'Windows' );
      
      if ( ~any(screens == window_handle) && ~any(windows == window_handle) )
        error( 'Window or screen index given by %d is invalid.', window_handle );
      end
    end
  end
  
end