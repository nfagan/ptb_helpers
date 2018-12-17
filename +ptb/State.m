classdef State < handle
  
  properties (Access = public)
    %   ENTRY -- Entry function.
    %
    %     Entry is a handle to a function that is called once upon entering
    %     the state. The function should accept a single argument -- the
    %     state object instance -- and return no outputs.
    %
    %     See also ptb.State.run, ptb.State.Loop
    Entry = @(varargin) 1;
    
    %   EXIT -- Exit function.
    %
    %     Exit is a handle to a function that is called once upon exiting
    %     the state. The function should accept a single argument -- the
    %     state object instance -- and return no outputs.
    %
    %     See also ptb.State.run, ptb.State.Loop
    Exit = @(varargin) 1;
    
    %   LOOP -- Loop function.
    %
    %     Loop is a handle to a function that is called repeatedly, until
    %     the state exits. The function should accept a single argument -- 
    %     the state object instance -- and return no outputs.
    %
    %     See also ptb.State.run, ptb.State.Entry, ptb.State.Exit
    Loop = @(varargin) 1;
    
    %   BYPASS -- Bypass function.
    %
    %     Bypass is a handle to a function is called instead of the usual
    %     sequence of Entry, Loop, and Exit functions, in the event that
    %     IsBypassed is true. The function should accept a single argument 
    %     -- the state object instance -- and return no outputs.
    %
    %     Bypass is mainly useful when the state object is run by a Task
    %     object as part of a sequence. In this case, Bypass can be used to
    %     e.g. establish a direct link between adjacent states, skipping
    %     over the bypassed state.
    %
    %     See also ptb.State, ptb.State.IsBypassed, ptb.Task, ptb.State.Entry
    Bypass = @(varargin) 1;
    
    %   ISBYPASSED -- True if Bypassed function should be called.
    %
    %     IsBypassed is a logical scalar value indicating whether the state
    %     object's Bypass function should be called -- in lieu of the usual
    %     sequence of Entry, Loop, and Exit functions -- when the state is
    %     run.
    %
    %     Setting this value within the Entry, Loop, or Exit functions will
    %     not have an effect until the next time the state is run.
    %
    %     See also ptb.State, ptb.State.Bypass
    IsBypassed = false;
    
    %   DURATION -- Duration of the state in seconds.
    %
    %     Duration is a scalar non-negative number that gives the minimum 
    %     amount of time in seconds that will be spent in the state 
    %     before the Exit function is called. The default value is 0.
    %
    %     Setting Duration to a particular value does not guarantee that
    %     exactly that many seconds will be spent in the state; it only
    %     gives the absolute minimum number of seconds that will be spent
    %     in the state. In general, the amount of overshoot will depend on
    %     how computationally expensive the Loop and Entry functions are.
    %     The `elapsed` function, when called from the Exit function, can 
    %     be used to determine the amount of overshoot.
    %
    %     An important consideration is that the Entry, Exit, and Loop
    %     functions are guaranteed to be called at least once, no matter
    %     how short the value of Duration (even if it is 0).
    %
    %     See also ptb.State.run, ptb.State.Loop, ptb.State.elapsed
    Duration = 0;
    
    %   NAME -- Name of the state.
    %
    %     Name is a character vector or string scalar giving the
    %     human-readable name of the state. Useful in certain logging
    %     contexts.
    %
    %     See also ptb.State.Duration, ptb.State.run
    Name = '';
    
    %   LOGENTRY -- Optionally print entry information.
    %
    %     LogEntry is a scalar logical flag indicating whether to log the
    %     entry into the state with a message. Default is false.
    %
    %     See also ptb.State.Name, ptb.State.LogExit
    LogEntry = false;
    
    %   LOGEXIT -- Optionally print exit information.
    %
    %     LogExit is a scalar logical flag indicating whether to log the
    %     exit out of the state with a message. Default is false.
    %
    %     See also ptb.State.Name, ptb.State.LogEntry
    LogExit = false;
  end
  
  properties (Access = private)
    exit_conditions = {};
    entered = false;
    exited = false;
    should_escape = false;
    
    clock;
  end
  
  properties (Access = protected)
    next_state = [];
  end
  
  methods
    function obj = State()
      
      %   STATE -- Create State instance.
      %
      %     obj = ptb.State() creates a State object -- a
      %     callback-orientated interface exposing Entry, Exit, and Loop
      %     functions.
      %
      %     A State object can be used in isolation, or more commonly as
      %     part of a circular sequence of states managed by a Task
      %     object. 
      %
      %     EXAMPLE //
      %
      %       state = ptb.State();
      %       state.Duration = 2; % 2 seconds
      %       state.Entry = @(st) fprintf('\n Entered');
      %       state.Exit = @(st) fprintf('\n Exited after %0.4fs\n', elapsed(st));
      %       state.run();
      %
      %     See also ptb.State.Entry, ptb.State.Exit, ptb.State.Duration,
      %       ptb.Task, ptb.State.run
      
      obj.clock = ptb.Clock();
      add_duration_exit_condition( obj );
    end
    
    function set.Duration(obj, v)
      validateattributes( v, {'numeric'}, {'scalar', 'real', 'nonnegative'} ...
        , mfilename, 'Duration' );
      obj.Duration = double( v );
      
      add_duration_exit_condition( obj );
    end
    
    function set.Entry(obj, v)
      validate_state_function( obj, v, 'Entry' );
      obj.Entry = v;
    end
    
    function set.Exit(obj, v)
      validate_state_function( obj, v, 'Exit' );
      obj.Exit = v;
    end
    
    function set.Loop(obj, v)
      validate_state_function( obj, v, 'Loop' );
      obj.Loop = v;
    end
    
    function set.Bypass(obj, v)
      validate_state_function( obj, v, 'Bypass' );
      obj.Bypass = v;
    end
    
    function set.Name(obj, v)
      validateattributes( v, {'char', 'string'}, {'scalartext'}, mfilename, 'Name' );
      obj.Name = char( v );
    end
    
    function set.IsBypassed(obj, v)
      validateattributes( v, {'logical'}, {'scalar'}, mfilename, 'IsBypassed' );
      obj.IsBypassed = v;
    end
    
    function set.LogEntry(obj, v)
      validateattributes( v, {'logical'}, {'scalar'}, mfilename, 'LogEntry' );
      obj.LogEntry = v;
    end
    
    function set.LogExit(obj, v)
      validateattributes( v, {'logical'}, {'scalar'}, mfilename, 'LogExit' );
      obj.LogExit = v;
    end
  end
  
  methods (Access = public)
    function t = elapsed(obj)
      
      %   ELAPSED -- Elapsed time in state, in seconds.
      %
      %     t = elapsed( obj ) gives the time-since-entry into the state,
      %     in seconds.
      %
      %     See also ptb.State, ptb.State.run, ptb.Clock
      
      t = elapsed( obj.clock );
    end
    
    function run(obj)
      
      %   RUN -- Run state.
      %
      %     run( obj ) calls the Entry function once, then the Loop
      %     function repeatedly, until at least one exit condition is met.
      %     Once an exit condition is met, the Exit function is called, and
      %     execution is returned to the caller.
      %
      %     This function is used to run the state in isolation; if you
      %     wish to run the state as part of a sequence of states, use a
      %     ptb.Task object.
      %
      %     See also ptb.State.add_exit_condition, ptb.State.Entry,
      %       ptb.Task
      
      if ( obj.IsBypassed )
        bypass( obj );
        return
      end
      
      entry( obj );
      
      is_first = true;
      
      while ( is_first || ~should_exit(obj) )
        loop( obj );
        is_first = false;
      end
      
      exit( obj );
    end
    
    function next(obj, s)
      
      %   NEXT -- Set next state.
      %
      %     next( obj, s ) indicates that state `s` is to be run next,
      %     after `obj` exits. This function is only useful if `obj` is
      %     part of a sequence of states managed by a ptb.Task object.
      %
      %     `s` can also be the empty matrix ([]), indicating that no state
      %     is to be run next.
      %
      %     See also ptb.State.run, ptb.Task
      %
      %     IN:
      %       - `state` (ptb.State, [])
      
      try
        set_next( obj, s );
      catch err
        throw( err );
      end
    end
    
    function escape(obj)
      
      %   ESCAPE -- Proceed to state exit.
      %
      %     escape( obj ), when called from the Entry or Loop functions,
      %     causes the state's Exit function to be called on the next
      %     update of the state.
      %
      %     Note that if escape() is called in the Entry function, the Loop
      %     function is still called once before the Exit function.
      %
      %     See also ptb.State, ptb.State.Entry
      
      obj.should_escape = true;
    end
    
    function set_logging(obj, tf)
      
      %   SET_LOGGING -- Set logging behavior.
      %
      %     set_logging( obj, tf ); sets both LogEntry and LogExit to the
      %     value given by `tf`.
      %
      %     See also ptb.State.run, ptb.State
      %
      %     IN:
      %       - `tf` (logical)
      
      validateattributes( tf, {'logical'}, {'scalar'}, mfilename, 'logging' );
      
      obj.LogEntry = tf;
      obj.LogExit = tf;
    end
    
    function add_exit_condition(obj, condition)
      
      %   ADD_EXIT_CONDITION -- Add condition testing whether to exit.
      %
      %     add_exit_condition( obj, condition ) adds the exit condition
      %     `condition` to the current list of condition-functions that, if
      %     they return true, will cause the state to exit.
      %
      %     `condition` is a handle to a function that accepts no inputs
      %     and returns a single scalar logical output indicating whether
      %     the state should exit.
      %
      %     Each state has an in-built exit condition that tests whether
      %     the state's Duration has been met.
      %
      %     See also ptb.State.Duration, ptb.State.exit_on_key_down
      %
      %     IN:
      %       - `condition` (function_handle)
      
      validateattributes( condition, {'function_handle'}, {'scalar'} ...
        , mfilename, 'exit_condition' );      
      
      obj.exit_conditions{end+1} = condition;      
    end
    
    function exit_on_key_down(obj, key_code)
      
      %   EXIT_ON_KEY_DOWN -- Exit when key is first registered as down.
      %
      %     exit_on_key_down( obj, key_code ) sets the state to exit as
      %     soon as the key given by `key_code` is down.
      %
      %     exit_on_key_down( obj ) sets the state to exist as soon as the
      %     escape key is pressed.
      %
      %     EXAMPLE //
      %
      %     state = ptb.State();
      %     % Exit the state when the escape key is pressed.
      %     state.exit_on_key_down( KbName('escape') );
      %
      %     See also ptb.State, ptb.State.add_exit_condition, 
      %       ptb.util.is_key_down
      %
      %     IN:
      %       - `key_code` (numeric)
      
      if ( nargin < 2 )
        key_code = ptb.util.get_escape_key_code();
      end
      
      condition = @() ptb.util.is_key_down( key_code );
      add_exit_condition( obj, condition );
    end
  end
  
  methods (Access = protected)
    function entry(obj, clear_next)
      reset( obj.clock );
      
      if ( nargin < 2 || clear_next )
        clear_next_state( obj );
      end
      
      obj.should_escape = false;
      
      if ( obj.LogEntry )
        fprintf( '\n Entered: %s', obj.Name );
      end
      
      obj.Entry( obj );
    end
    
    function exit(obj)
      obj.Exit( obj );
      
      if ( obj.LogExit )
        fprintf( '\n Exited:  %s (%0.3f s)', obj.Name, elapsed(obj) );
      end
    end
    
    function bypass(obj)
      reset( obj.clock );
      
      clear_next_state( obj );
      
      obj.Bypass( obj );
    end
    
    function loop(obj)
      obj.Loop( obj );
    end
    
    function clear_next_state(obj)
      obj.next_state = [];
    end
    
    function validate_state_function(obj, v, kind)  %#ok
      validateattributes( v, {'function_handle'}, {'scalar'}, mfilename, kind );
    end
    
    function add_duration_exit_condition(obj)
      condition = @() elapsed( obj.clock ) >= obj.Duration;
      
      if ( isempty(obj.exit_conditions) )
        obj.add_exit_condition( condition );
      else
        obj.exit_conditions{1} = condition;
      end
    end
    
    function tf = should_exit(obj)
      
      %   SHOULD_EXIT -- True if the state should exit.
      
      if ( obj.should_escape )
        tf = true;
        return
      end
      
      tf = false;
      conditions = obj.exit_conditions;
      n_conditions = numel( conditions );
      
      for i = 1:n_conditions
        if ( conditions{i}() )
          tf = true;
          return
        end
      end
    end
    
    function set_next(obj, s)
      if ( isempty(s) )
        obj.next_state = [];
      else
        validateattributes( s, {'ptb.State'}, {'scalar'}, mfilename, 'state' );        
        obj.next_state = s;
      end
    end
  end
  
end