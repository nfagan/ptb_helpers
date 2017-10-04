classdef EyeTracker < handle
  
  properties
    edf = [];
    folder = [];
    window = [];
    bypass = false;
    gaze_ready = false;
    coordinates = [];
    MAX_N_EDF_FILENAME_CHARS = 8;
  end
  
  methods
    function obj = EyeTracker( edf, folder, window )
      
      %   EYETRACKER -- Instantiate an EyeTracker.
      %
      %     IN:
      %       - `edf` (char) -- Edf filename.
      %       - `folder` (char) -- Folder in which to save the edf file.
      %       - `window` (number) -- Window identifier as returned by
      %         Screen('OpenWindow')
      
      obj.edf = edf;
      obj.folder = folder;
      obj.window = window;
    end
    
    function success = init(obj)
      
      %   INIT -- Initialize EyeLink.
      %
      %     OUT:
      %       - `success` (true, false)
      
      success = true;
      if ( obj.bypass ), return; end;
      obj.assert__edf_is_defined();
      success = EyelinkInit();
      success = logical( success );
      if ( ~success ), return; end
      Eyelink( 'command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY' );
      Eyelink( 'command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON' );
      Eyelink( 'Openfile', obj.edf );
      Eyelink( 'StartRecording' );
    end
    
    function status = send(obj, msg)
      
      %   SEND -- Send a message to Eyelink.
      %
      %     IN:
      %       - `msg` (char)
      %     OUT:
      %       - `status` (double) -- 0 if success, -1 if error.
      
      if ( obj.bypass ), status = 0; return; end;
      obj.assert__isa( msg, 'char', 'the to-be-sent message' );
      status = Eyelink( 'Message', msg );
    end
    
    function tf = new_gaze_ready(obj)
      
      %   NEW_GAZE_READY -- Return whether new gaze samples are available.
      %
      %     OUT:
      %       - `tf` (true, false)
      
      tf = true;
      if ( obj.bypass ), return; end;
      tf = Eyelink( 'NewFloatSampleAvailable' ) > 0;
    end
    
    function [success, x, y] = get_coordinates(obj)
      
      %   GET_COORDINATES -- Return the current gaze coordinates.
      %
      %     If obj.bypass is true, the returned coordinates will be the
      %     mouse coordinates.
      %
      %     OUT:
      %       - `success` (true, false)
      %       - `x` (double)
      %       - `y` (double)
      
      persistent eye_used;
      persistent el;
      if ( ~obj.bypass && isempty(eye_used) )
        eye_used = -1;
        el = EyelinkInitDefaults();
      end
      success = false;
      x = 0;
      y = 0;
      if ( obj.bypass )
        [x, y] = GetMouse( obj.window );
        success = true;
        return;
      end
      event = Eyelink( 'NewestFloatSample' );
      if ( eye_used ~= -1 )
        x = event.gx(eye_used+1);
        y = event.gy(eye_used+1);
        if ( x~=el.MISSING_DATA && y~=el.MISSING_DATA && event.pa(eye_used+1)>0 )
          success = true;
        end
      else
        eye_used = Eyelink( 'EyeAvailable' );
        if ( eye_used == el.BINOCULAR )
          eye_used = el.LEFT_EYE;
        end
      end
    end
    
    function update_coordinates(obj)
      
      %   UPDATE_COORDINATES -- Update the current gaze coordinates.
      
      ready = obj.new_gaze_ready();
      new_coordinates = [];
      if ( ready )
        [success, x, y] = obj.get_coordinates();
        if ( success )
          new_coordinates = [ x, y ];
        else
          ready = false;
        end
      end
      obj.gaze_ready = ready;
      obj.coordinates = new_coordinates;
    end
    
    function err = check_recording(obj)
      
      %   CHECK_RECORDING -- Return whether the Eyelink is in an error
      %     state.
      %
      %     OUT:
      %       - `err` (true, false) -- True if an error occurred.
      
      err = false;
      if ( obj.bypass ), return; end;
      err = Eyelink( 'CheckRecording' );
    end
    
    function send_message(obj, msg)
      
      %   SEND_MESSAGE -- Send a message to Eyelink.
      %
      %     IN:
      %       - `msg` (char)
      
      if ( obj.bypass ), return; end
      assert( ischar(msg), 'Message must be a char.' );
      Eyelink( 'SendMessage', msg );
    end
    
    function shutdown(obj)
      
      %   SHUTDOWN -- Stop recording and close the EyeLink connection.
      
      if ( obj.bypass ), return; end;

      edf_filename = obj.edf;
      folder_name = obj.folder;

      WaitSecs( 0.1 );
      Eyelink( 'StopRecording' );
      WaitSecs( 0.1 );
      Eyelink( 'CloseFile' );
      WaitSecs( 0.1 );

      try
        fprintf( 'Receiving data file ''%s''\n', edf_filename );
        status = Eyelink( 'ReceiveFile', edf_filename, folder_name, 1 );
        if ( status > 0 )
          fprintf( 'ReceiveFile status %d\n', status );
        end
      catch err
        fprintf( 'Problem receiving data file ''%s''\n', edf_filename );
        fprintf( '\n%s', err.message );
      end      
    end
    
    %{
        PROPERTY VALIDATION
    %}
    
    function set.edf(obj, val)
      
      %   SET.EDF -- Validate and update the edf property.
      %
      %     The edf file must be a char with at most
      %     `obj.MAX_N_EDF_FILENAME_CHARS` elements.
      %     
      %     IN:
      %       - `val` (char)
      
      obj.assert__isa( val, 'char', 'the edf filename' );
      assert( numel(val) <= obj.MAX_N_EDF_FILENAME_CHARS, ['The given' ...
        , ' edf filename ''%s'' is too long.'], val );
      obj.edf = val;
    end
    
    function set.folder(obj, val)
      
      %   SET.FOLDER -- Validate and update the folder property.
      %
      %     The folder must be a char and a valid filepath.
      %
      %     IN:
      %       - `val` (char)
      
      obj.assert__isa( val, 'char', 'the edf save folder' );
      assert( obj.is_valid_path(val), 'The path ''%s'' is invalid.', val );
      obj.folder = val;
    end
    
    %{
        ASSERTIONS
    %}
    
    function assert__edf_is_defined(obj, msg)
      
      %   ASSERT__EDF_IS_DEFINED -- Ensure the edf property is not empty.
      
      if ( nargin < 2 ), msg = 'The .edf filename has not been defined.'; end;
      assert( ~isempty(obj.edf), msg );
    end
    
    function assert__isa(obj, var, kind, var_name)
      
      %   ASSERT__ISA -- Ensure a variable is of a given kind.
      %
      %     IN:
      %       - `var` (/any/) -- Variable to check.
      %       - `kind` (char) -- Expected class of `var`.
      %       - `var_name` (char) |OPTIONAL| -- Optionally provide a more
      %         descriptive name for the variable in case the assertion
      %         fails.
      
      if ( nargin < 4 ), var_name = 'input'; end;
      assert( isa(var, kind), 'Expected %s to be a ''%s''; was a ''%s''.' ...
        , var_name, kind, class(var) );
    end
    
    %{
        UTIL
    %}
    
    function valid = is_valid_path(obj, pathstr)
      
      %   IS_VALID_PATH -- Return whether a given pathstr points to an
      %     existing directory.
      %
      %     IN:
      %       - `pathstr` (char)
      
      valid = true;
      original = cd;
      try
        cd( pathstr ); 
        cd( original );
      catch
        valid = false;
      end
    end
  end
  
end