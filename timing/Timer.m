classdef Timer < handle
  
  properties
    timers = {};
    ids = {};
    durations = [];
  end
  
  methods
    
    function obj = Timer(ids, durations)
      
      %   TIMER -- Instantiate a Timer object.
      %
      %     IN:
      %       - `ids` (cell array of strings, char) -- Ids of each timer.
      %       - `durations` (double) -- Vector setting the time-limit of
      %         the timer associated with each `ids`(i). Must have the same
      %         number of elements as `ids`.
      
      if ( nargin == 0 ), return; end;
      ids = obj.ensure_cell( ids );
      obj.assert__is_cellstr( ids, 'the timer ids' );
      obj.assert__matching_n_ids_durations( ids, durations );
      obj.ids = ids;
      obj.durations = durations;
      obj.reset_timers( ids );
    end
    
    function add_timer(obj, id, duration)
      
      %   ADD_TIMER -- Add a new timer.
      %
      %     IN:
      %       - `id` (char) -- Id of the new timer. Must not already exist.
      %       - `duration` (double)
      
      obj.assert__isa( id, 'char', 'the timer id' );
      obj.assert__isa( duration, 'double', 'the duration' );
      obj.assert__ids_do_not_exist( id );
      obj.ids{end+1} = id;
      obj.durations(end+1) = duration;
      obj.timers{end+1} = NaN;
      obj.reset_timers( id );
    end
    
    function reset_timers(obj, ids)
      
      %   RESET_TIMERS -- Reset timers associated with the given ids.
      %
      %     IN:
      %       - `ids` (cell array of strings, char)
      
      ids = obj.ensure_cell( ids );
      obj.assert__is_cellstr( ids );
      obj.assert__ids_exist( ids );
      ind = cellfun( @(x) find(strcmp(obj.ids, x)), ids );
      for i = 1:numel(ind)
        obj.timers{ind(i)} = tic;
      end
    end
    
    function t = get_time(obj, id)
      
      %   GET_TIME -- Return the elapsed time associated with a given id.
      %
      %     IN:
      %       - `id` (char)
      
      obj.assert__isa( id, 'char', 'the timer id' );
      obj.assert__ids_exist( id );
      ind = strcmp( obj.ids, id );
      t = toc( obj.timers{ind} );
    end
    
    function tf = duration_met(obj, ids)
      
      %   DURATION_MET -- Return whether the duration criterion has been
      %     met for the given id(s).
      %
      %     IN:
      %       - `ids` (cell array of strings, char) -- Ids to check.
      %     OUT:
      %       - `tf` (logical) -- Logical array where the i-th element is
      %         true if the duration associated with ids(i) has been met.
      
      ids = obj.ensure_cell( ids );
      elapsed = cellfun( @(x) obj.get_time(x), ids );
      thresh = obj.durations( cellfun(@(x) find(strcmp(obj.ids, x)), ids) );
      tf = elapsed >= thresh;
    end
    
    function set_durations(obj, ids, durations)
      
      %   SET_DURATIONS -- Update the duration criterion associated with
      %     the given id(s)
      %
      %     IN:
      %       - `ids` (cell array of strings, char)
      %       - `durations` (double)
      
      ids = obj.ensure_cell( ids );
      obj.assert__isa( durations, 'double', 'the durations' );
      obj.assert__is_cellstr( ids );
      obj.assert__ids_exist( ids );
      obj.assert__matching_n_ids_durations( ids, durations );
      inds = cellfun( @(x) find(strcmp(obj.ids, x)), ids );
      obj.durations( inds ) = durations;
    end
    
    %{
        UTIL
    %}
    
    function arr = ensure_cell(obj, arr)
      
      %   ENSURE_CELL -- Ensure an input is a cell array.
      %
      %     IN:
      %       - `arr` (/any/)
      %     OUT:
      %       - `arr` (cell)      
      
      if ( ~iscell(arr) ), arr = { arr }; end;
    end
    
    %{
        ASSERTIONS
    %}
    
    function assert__matching_n_ids_durations(obj, ids, durations)
      
      %   ASSERT__MATCHING_N_IDS_DURATIONS -- Ensure a given ids array
      %     has the same number of elements as a given durations array.
      
      assert( numel(durations) == numel(ids), ['The number of ids must' ...
        , ' match the number of durations.'] );
    end
    
    function assert__ids_exist(obj, ids)
      
      %   ASSERT__IDS_EXIST -- Ensure a given number of ids exist in the
      %     obj.ids array.
      %
      %     IN:
      %       - `ids` (cell array of strings, char) -- Ids to check.
      
      msg = 'The specified id ''%s'' does not exist.';
      ids = obj.ensure_cell( ids );
      cellfun( @(x) assert(any(strcmp(obj.ids, x)), msg, x), ids );
    end
    
    function assert__ids_do_not_exist(obj, ids)
      
      %   ASSERT__IDS_EXIST -- Ensure a given number of ids do not
      %     already exist in the obj.ids array.
      %
      %     IN:
      %       - `ids` (cell array of strings, char) -- Ids to check.
      
      msg = 'The specified id ''%s'' already exists.';
      ids = obj.ensure_cell( ids );
      cellfun( @(x) assert(~any(strcmp(obj.ids, x)), msg, x), ids );
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
    
    function assert__is_cellstr(obj, var, var_name)
      
      %   ASSERT__IS_CELLSTR -- Ensure a variable is a cell array of
      %     strings.
      %
      %     IN:
      %       - `var` (/any/) -- Variable to check.
      %       - `var_name` (char) |OPTIONAL| -- Optionally provide a more
      %         descriptive name for the variable in case the assertion
      %         fails.      
      
      if ( nargin < 3 ), var_name = 'input'; end;
      assert( iscellstr(var), ['Expected %s to be a cell array of strings;' ...
        , ' was a ''%s''.'], var_name, class(var) );
    end
  end
  
end