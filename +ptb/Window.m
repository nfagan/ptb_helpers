classdef Window < handle  
  properties (Access = public)
    %   INDEX -- Index of the monitor on which to open the Window.
    %
    %     Index is a numeric integer scalar giving the index of the monitor
    %     on which to open the window. Default is 0, meaning the complete
    %     desktop.
    %
    %     An error is thrown if this index is out of bounds of the number
    %     of monitors available on your system.
    %
    %     See also ptb.Window, ptb.Window.IsOpen, ptb.Window.Rect
    Index = 0;
    
    %   RECT -- Bounding Rect of the window.
    %
    %     Rect is an object that gives the minimum x, minimum y, maximum x,
    %     and maximum y coordinates of the Window, respectively. It is of
    %     class ptb.Rect.
    %     
    %     See also ptb.Rect, ptb.Window, ptb.Window.Width, 
    %       ptb.Window.Height, ptb.Window.set_width, ptb.Window.set_height
    Rect = ptb.Rect.Configured( ...
          'IsNonNan',       true ...
        , 'IsNonNegative',  true ...
        , 'Empty',          true ...
    );
    
    %   BACKGROUNDCOLOR -- Background color of the Window.
    %
    %     BackgroundColor is a three-element vector giving the
    %     background-color of the window. Default is black, i.e., 
    %     [0, 0, 0].
    %
    %     See also ptb.Window, ptb.Window.Rect
    BackgroundColor = zeros( 1, 3 );
  end
  
  properties (GetAccess = public, SetAccess = private)
    %   ISOPEN -- True if the window is open.
    %
    %     IsOpen is a read-only logical scalar indicating whether the
    %     window is open. Note that it is possible for the underlying
    %     Psychtoolbox window handle to become invalid before the Window
    %     object's close method is called (e.g., after a call to `sca`)
    IsOpen = false;
    
    %   CENTER -- (X, Y) center of the window, in pixels.
    %
    %     Center is a read-only 2-element vector giving the (X, Y) center
    %     of the window, in pixels. If the Rect property has not been
    %     set, then the Center will remain similarly undefined until the
    %     window has been opened.
    %
    %     See also ptb.Window, ptb.Window.Rect
    Center = [];
    
    %   WIDTH -- Width of the window in pixels.
    %
    %     Width gives the width of the window `obj` in pixels. If the 
    %     window is not open and no Rect has been manually set, then Width 
    %     is NaN.
    %
    %     See also ptb.Window, ptb.Window.Height    
    Width = nan;
    
    %   HEIGHT -- Height of the window in pixels.
    %
    %     Height gives the height of the window `obj` in pixels. If the 
    %     window is not open and no Rect has been manually set, then Height 
    %     is NaN.
    %
    %     See also ptb.Window, ptb.Window.Width    
    Height = nan;
    
    %   WINDOWHANDLE -- Handle to the underlying Psychtoolbox window.
    %
    %     WindowHandle is an scalar integer double handle to the underlying
    %     window object, managed by Psychtoolbox. If the window is not
    %     open, this value is NaN.
    %
    %     See also ptb.Window, ptb.Window.open, ptb.Window.Rect, Screen
    WindowHandle = nan;
  end
  
  methods
    function obj = Window(varargin)
      
      %   WINDOW -- Create Window object instance.
      %
      %     obj = ptb.Window() creates a default-constructed Window object
      %     instance -- a wrapper around Screen sub-routines dealing
      %     with window opening, closing, and drawing.
      %
      %     Once `obj` has been created, configure its properties using the
      %     . syntax, before opening the window with a call to open.
      %
      %     EXAMPLE //
      %
      %     window = ptb.Window();
      %     window.Rect = [0, 0, 100, 100]; % 100px-by-100px, top-left
      %     window.BackgroundColor = [ 255, 255, 255 ] %  white
      %     open( window );
      %     WaitSecs( 1 );
      %     close( window );
      %
      %     See also ptb.Window.Index, ptb.Window.Rect,
      %       ptb.Window.BackgroundColor, ptb.Window.IsOpen,
      %       ptb.Window.open
      
    end
    
    function set.Index(obj, index)
      try
        set_error_if_open( obj, 'Index' );
      catch err
        throw( err );
      end
      
      try
        validateattributes( index, {'numeric'}, {'integer', 'nonnegative'} ...
          , mfilename, 'index' );

        screens = Screen( 'Screens' );
        
        if ( ~any(screens == index) )
          join_str = strjoin( arrayfun(@num2str, screens, 'un', 0), ' | ' );
          error( 'Screen index %d is invalid; options are: \n\n%s', index, join_str );
        end
      catch err
        throw( err );
      end
      
      obj.Index = double( index );
    end
    
    function set.Rect(obj, rect)
      try
        set_error_if_open( obj, 'Rect' );
      catch err
        throw( err );
      end
      
      try
        tmp_rect = obj.Rect;
        
        if ( isempty(tmp_rect) && ~isempty(rect) )
          tmp_rect = get_default_rect( obj );
        elseif ( ~isempty(tmp_rect) && isempty(rect) )
          tmp_rect(1) = [];
        end
        
        obj.Rect = set( tmp_rect, rect );
      catch err
        throw( err );
      end
      
      elements = get( obj.Rect );
      
      set_center_from_rect( obj, elements );
      set_dimensions_from_rect( obj, elements );
    end
    
    function set.BackgroundColor(obj, bc)
      try
        set_error_if_open( obj, 'BackgroundColor' );
      catch err
        throw( err );
      end
      
      if ( isempty(bc) )
        bc = zeros( 1, 3 );
      else
        try
          validateattributes( bc, {'numeric'}, {'nonnegative', 'vector' ...
            , 'numel', 3, '<=', 255}, mfilename, 'BackgroundColor' );
        catch err
          throw( err );
        end
        
        bc = double( bc(:)' );
      end
      
      obj.BackgroundColor = bc;      
    end
    
    function delete(obj)
      close( obj );
    end
  end
  
  methods (Access = public)
    
    function tf = is_window_handle_valid(obj)
      
      %   IS_WINDOW_HANDLE_VALID -- True if the underlying WindowHandle
      %     points to an existing Psychtoolbox window.
      %
      %     tf = is_window_handle_valid( obj ); returns true if the 
      %     WindowHandle in `obj` points to a valid, open Psychtoolbox
      %     window. This function returns a reliable result regardless of
      %     the state of the IsOpen property.
      %
      %     Because Psychtoolbox windows can be closed at the
      %     command-prompt, it is possible for the IsOpen property to
      %     be true, despite that Psychtoolbox window has been closed /
      %     destroyed.
      %
      %     See also ptb.Window, ptb.Window.IsOpen, ptb.Window.open
      %
      %     OUT:
      %       - `tf` (logical)
      
      wh = obj.WindowHandle;
      tf = ~isnan( wh ) && any( Screen('Windows') == wh );
    end
    
    function set_width(obj, w)
      
      %   SET_WIDTH -- Set window width.
      %
      %     set_width( obj, w ); configures the Rect property such that the
      %     width of the window is `w`, a positive numeric scalar. 
      %
      %     If Rect is currently empty, then the X- and Y-origins will be 
      %     set to (0, 0), and the height will be set to 1 px. Otherwise,
      %     the X- and Y-origins will remain unchanged, and the height
      %     unchanged.
      %
      %     An error is thrown if the window is already open.
      %
      %     See also ptb.Window.width, ptb.Window.Rect,
      %       ptb.window.set_height
      %     
      %     IN:
      %       - `w` (double)
      
      set_error_if_open( obj, 'width' );
      
      rect = require_rect( obj );
      
      obj.Rect = set_x_extent( rect, w );
    end
    
    function set_height(obj, h)
      
      %   SET_WIDTH -- Set window height.
      %
      %     set_height( obj, h ); configures the Rect property such that the
      %     height of the window is `h`, a positive numeric scalar. 
      %
      %     If Rect is currently empty, then the X- and Y-origins will be 
      %     set to (0, 0), and the width will be set to 1 px. Otherwise,
      %     the X- and Y-origins will remain unchanged, and the width
      %     unchanged.
      %
      %     An error is thrown if the window is already open.
      %
      %     See also ptb.Window.width, ptb.Window.Rect,
      %       ptb.window.set_height
      %     
      %     IN:
      %       - `w` (double)
      
      set_error_if_open( obj, 'height' );
      
      rect = require_rect( obj );
      
      obj.Rect = set_y_extent( rect, h );
    end
    
    function set_dimensions(obj, w, h)
      
      %   SET_DIMENSIONS -- Set width and height, at once.
      %
      %     set_dimensions( obj, w, h ); sets the width and height
      %     components of the Rect property to `w` and `h`, respectively.
      %     `w` and `h` are positive numeric scalars.
      %
      %     An error is thrown if the window is already open. Additionally,
      %     if an invalid width or height is given, the Rect property
      %     remains unchanged.
      %
      %     See also ptb.Window, ptb.Window.set_width,
      %       ptb.Window.set_height, ptb.Window.Rect
      %
      %     IN:
      %       - `w` (double)
      %       - `h` (double)
      
      set_error_if_open( obj, 'width' );
      
      orig_rect = obj.Rect;
      
      try
        set_width( obj, w );
        set_height( obj, h );
      catch err
        obj.Rect = orig_rect;
        throw( err );
      end
    end
    
    function time_stamp = flip(obj)
      
      %   FLIP -- Swap front- and back-buffers of the Window.
      %
      %     flip( obj ); swaps the front- and back-buffers of the open
      %     window `obj`, displaying whatever has been drawn to the window
      %     since the last call to `flip`. An error is thrown if IsOpen is
      %     false. Script execution is blocked until the flip operation
      %     completes.
      %
      %     t = flip(...); returns the estimated time that the flip
      %     occurred.
      %
      %     If the underlying window handle has been invalidated by e.g. a
      %     call to `sca`, a warning is printed, and `t` is NaN.
      %
      %     See also ptb.Window, ptb.Window.open, Screen
      
      if ( ~obj.IsOpen )
        error( 'Window is not open.' );
      end
      
      time_stamp = nan;
      
      try
        time_stamp = Screen( 'Flip', obj.WindowHandle );
      catch err
        warning( err.message );
      end
    end
    
    function open(obj)
      
      %   OPEN -- Open window.
      %
      %     open( obj ); opens the window according to the currently
      %     configured properties of `obj`. An error is thrown if the 
      %     window is already open.
      %
      %     See also ptb.Window, ptb.Window.close, ptb.Window.flip
      
      if ( obj.IsOpen )
        error( 'The window is already open.' );
      end
      
      rect = get( obj.Rect );
      
      try
        [handle, rect] = Screen( 'OpenWindow', obj.Index, obj.BackgroundColor, rect );
      catch err
        throw( err );        
      end
      
      obj.WindowHandle = handle;
      obj.Rect = rect;
      
      obj.IsOpen = true;
    end
    
    function close(obj)
      
      %   CLOSE -- Close window.
      %
      %     close( obj ); closes the window previously opened with a call
      %     to `open`. If the window is already closed, this function has
      %     no effect.
      %
      %     A warning is printed if the underlying window handle is
      %     invalid, such as if it has been manually closed with a call to
      %     `sca`.
      %
      %     See also ptb.Window, ptb.Window.open, sca
      
      if ( ~obj.IsOpen )
        return
      end
      
      try
        Screen( 'Close', obj.WindowHandle );
      catch err
        warning( err.message );
      end
      
      obj.IsOpen = false;
      obj.WindowHandle = nan;
    end    
  end
  
  methods (Access = private)
    
    function r = require_rect(obj)
      if ( isempty(obj.Rect) )
        r = get_default_rect( obj );
      else
        r = obj.Rect;
      end
    end
    
    function dflt = get_default_rect(obj)
      dflt = ptb.Rect.Configured( ...
          'IsNonNan',       true ...
        , 'IsNonNegative',  true ...
      );
    end
    
    function set_center_from_rect(obj, rect)
      if ( isempty(rect) )
        obj.Center = [];
        return
      end
      
      w = rect(3) - rect(1);
      h = rect(4) - rect(2);
      
      xc = rect(1) + w/2;
      yc = rect(2) + h/2;
      
      obj.Center = [ xc, yc ];
    end
    
    function set_dimensions_from_rect(obj, rect)
      
      if ( isempty(rect) )
        obj.Width = nan;
        obj.Height = nan;
      else
        obj.Width = rect(3) - rect(1);
        obj.Height = rect(4) - rect(2);
      end
    end
    
    function set_error_if_open(obj, prop)
      if ( obj.IsOpen )
        error( 'Cannot set the "%s" property once IsOpen is true.', prop );
      end
    end
  end
  
end