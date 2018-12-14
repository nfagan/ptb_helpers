classdef EyelinkSource < ptb.XYSource
  
  properties (Access = private, Constant = true)
    uninitialized_error_id = 'EyelinkSource:record:EyelinkNotInitialized';
    file_io_component = 'EyelinkSource:io:';
    record_component = 'EyelinkSource:record:';
    message_component = 'EyelinkSource:message:';
  end
  
  properties (Access = private)
    eyelink_defaults;
    tracked_eye_index = -1;
    
    is_initialized = false;
    is_recording = false;
    is_file_open = false;
    
    file_name = '';
  end
  
  methods
    function obj = EyelinkSource()
      
      %   EYELINKSOURCE -- Create EyelinkSource object instance.
      %
      %     obj = ptb.EyelinkSource() creates an interface for obtaining 
      %     (X, Y) position samples from an Eyelink eyetracker, as well as
      %     saving those samples to disk.
      %
      %     See also ptb.EyelinkSource.initialize,
      %       ptb.EyelinkSource.update, ptb.EyelinkSource.start_recording,
      %       ptb.MouseSource
      
      obj = obj@ptb.XYSource();
      
      obj.eyelink_defaults = EyelinkInitDefaults();
    end
  end
  
  methods (Access = public)
    function start_recording(obj, file_name)
      
      %   START_RECORDING -- Begin recording samples.
      %
      %     start_recording( obj ) attempts to begin recording samples from 
      %     Eyelink. An error is thrown if the EyelinkSource is not 
      %     initialized, or if an attempt to start recording fails. Data
      %     are not saved on the Eyelink computer.
      %
      %     start_recording( obj, file_name ) attempts to open the file 
      %     `file_name` on the Eyelink computer before beginning to record 
      %     samples, saving data to that file. An error is thrown if an 
      %     attempt to open the file fails, in which case recording is also 
      %     not started.
      %
      %     See also ptb.EyelinkSource, ptb.EyelinkSource.stop_recording,
      %       ptb.EyelinkSource.receive_file
      %
      %     IN:
      %       - `filename` (char) |OPTIONAL|
      
      if ( ~obj.is_initialized )
        error( obj.uninitialized_error_id ...
          , 'Cannot begin recording, because Eyelink is not initialized.' );
      end
      
      if ( nargin == 2 )
        try_open_file( obj, file_name );
        WaitSecs( 0.5 ); % Give eyelink time to open the file.
      end
      
      status = Eyelink( 'StartRecording' );
      
      if ( status ~= 0 )
        error( 'EyelinkSource:record:StartRecordingError' ...
          , 'Failed to start recording samples.' );
      end
      
      obj.is_recording = true;
    end
    
    function stop_recording(obj)
      
      %   STOP_RECORDING -- Stop recording samples, closing file if open.
      %
      %     stop_recording( obj ) stops recording samples from Eyelink. If
      %     a file name was given in a call to `start_recording`, then the
      %     file is closed as well. An error is thrown in the case that the
      %     closing of a file fails.
      %
      %     See also ptb.EyelinkSource, ptb.EyelinkSource.start_recording
      
      if ( ~obj.is_recording )
        return
      end
      
      Eyelink( 'StopRecording' );
      
      if ( obj.is_file_open )
        WaitSecs( 0.5 );  % Give eyelink time to stop recording.
        
        try
          try_close_file( obj );
        catch err
          throw( err );
        end
      end
      
      obj.is_recording = false;
    end
    
    function receive_file(obj, dest)
      
      %   RECEIVE_FILE -- Transfer file from Eyelink to host.
      %
      %     receive_file( obj, dest ) transfers the file opened during a
      %     call to `start_recording` to the folder given by `dest`. If a
      %     file was not specified during the call to `start_recording`,
      %     this function has no effect; otherwise, an error is thrown if
      %     the transfer fails.
      %
      %     See also ptb.EyelinkSource, ptb.EyelinkSource.start_recording
      %
      %     IN:
      %       - `dest` (char)
      
      if ( obj.is_recording )
        error( [obj.record_component, 'IsRecording'] ...
          , 'Cannot receive a file until recording is stopped.' );
      end
      
      if ( isempty(obj.file_name) )
        % File was not opened during call to `start_recording`.
        return
      end
      
      try
        dest = char( ptb.EyelinkSource.validate_scalar_text(dest, 'destination') );
      catch err
        throw( err );
      end
      
      status = Eyelink( 'ReceiveFile', obj.file_name, dest, 1 );
      
      if ( status < 0 )
        error( [obj.file_io_component, 'ReceiveFileError'] ...
          , 'Failed to receive file: "%s".', obj.file_name );
      end
    end
    
    function initialize(obj)
      
      %   INITIALIZE -- Attempt to initialize connection to Eyelink.
      %
      %     initialize( obj ) attempts to open a TCP/IP link to a connected
      %     Eyelink tracker, throwing an error if the initialization is
      %     unsuccessful. 
      %
      %     See also ptb.EyelinkSource
      
      status = Eyelink( 'Initialize' );
      success = status == 0;
      
      if ( ~success )
        error( 'EyelinkSource:initialize:initialize' ...
          , 'Failed to initialize Eyelink system and connection.' );
      end
      
      try
        link_gaze_data( obj );
      catch err
        throw( err );
      end
      
      obj.is_initialized = true;
    end
    
    function send_message(obj, message)
      
      %   SEND_MESSAGE -- Send message to Eyelink.
      %
      %     send_message( obj, message ) sends `message` to Eyelink.
      %     `message` must be a character vector.
      %
      %     An error is thrown if the EyelinkSource is not initialized;
      %     a warning is generated if the message fails to send.
      %
      %     See also ptb.EyelinkSource, ptb.EyelinkSource.initialize
      %
      %     IN:
      %       - `message` (char)
      
      ptb.EyelinkSource.validate_scalar_text( message, 'message' );
      
      if ( ~obj.is_initialized )
        error( obj.uninitialized_error_id ...
          , 'Cannot send "%s", because Eyelink is not initialized.', message );
      end
      
      status = Eyelink( 'Message', message );
      
      if ( status ~= 0 )
        warning( [obj.message_component, 'SendMessageFailure'] ...
          , 'Failed to send message "%s".', message );
      end
    end
  end
  
  methods (Access = private)    
    function try_open_file(obj, file_name)
      file_name = ptb.EyelinkSource.validate_scalar_text( file_name, 'filename' );
      file_name = char( file_name );

      status = Eyelink( 'OpenFile', file_name );

      if ( status ~= 0 )
        error( [obj.file_io_component, 'open'], 'Failed to open file "%s".', file_name );
      end

      obj.is_file_open = true;
      obj.file_name = file_name;
    end
    
    function try_close_file(obj)
      status = Eyelink( 'CloseFile' );

      if ( status ~= 0 )
        error( [obj.file_io_component, 'CloseFileError'] ...
          , 'Failed to close file: "%s".', obj.file_name );
      end

      obj.is_file_open = false;
    end
    
    function link_gaze_data(obj)
      status = Eyelink( 'command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY' );
      
      if ( status ~= 0 )
        error( 'EyelinkSource:link_gaze_data:link_event_data' ...
          , 'Failed to link gaze event data.' );
      end
      
      status = Eyelink( 'command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON' );
      
      if ( status ~= 0 )
        error( 'EyelinkSource:link_gaze_data:link_event_filter' ...
          , 'Failed to link event filter data.' );
      end
    end
    
    function tracked_eye = get_tracked_eye_index(obj)
      tracked_eye = obj.tracked_eye_index;
      
      if ( tracked_eye ~= -1 )
        return
      end
      
      tracked_eye = Eyelink( 'EyeAvailable' );
      obj.tracked_eye_index = tracked_eye;
    end 
  end
  
  methods (Access = protected)
    function tf = new_sample_available(obj)
      tf = obj.is_recording && Eyelink( 'NewFloatSampleAvailable' ) > 0;
    end
    
    function [x, y, success] = get_latest_sample(obj)
      
      tracked_eye = get_tracked_eye_index( obj );
      
      x = nan;
      y = nan;
      success = false;
      
      event = Eyelink( 'NewestFloatSample' );
      
      if ( isnumeric(event) && event == -1 )
        % No valid sample available.
        return
      end
      
      if ( tracked_eye == -1 )
        % No tracked eye found.
        return
      end
      
      x = event.gx(tracked_eye+1);
      y = event.gy(tracked_eye+1);

      md = obj.eyelink_defaults.MISSING_DATA;
        
      % If either X or Y is missing or NaN, indicate failure
      success = x ~= md && y ~= md && event.pa(tracked_eye+1) > 0 && ...
        ~isnan( x ) && ~isnan( y );
    end
  end
  
  methods (Access = private, Static = true)
    function text = validate_scalar_text(text, var_name)
      classes = { 'char', 'string' };
      attrs = { 'scalartext', 'nonempty' };

      validateattributes( text, classes, attrs, mfilename, var_name );
    end
  end
  
end