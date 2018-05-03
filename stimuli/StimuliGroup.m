classdef StimuliGroup < handle
  
  properties
    stimuli = {};
  end
  
  methods    
    function obj = StimuliGroup(stimuli)
      
      %   STIMULIGROUP -- Instantiate a StimuliGroup object.
      %
      %     IN:
      %       - `stimuli` (Stimulus, cell array of Stimulus)
      %     OUT:
      %       - `obj` (StimuliGroup)
      
      if ( nargin == 0 ), return; end
      obj.add_stimuli( stimuli );
    end
    
    function add_stimulus(obj, stimulus)
      
      %   ADD_STIMULUS -- Add stimulus to the group.
      %
      %     IN:
      %       - `stimulus` (Stimulus)
      
      assert__isa( stimulus, 'Stimulus' );
      obj.stimuli{end+1} = stimulus;
    end
    
    function add_stimuli(obj, stimuli)
      
      %   ADD_STIMULI -- Add multiple stimuli to the group.
      %
      %     IN:
      %       - `stimuli` (Stimulus, cell array of Stimulus)
      
      stimuli = StimuliGroup.ensure_cell( stimuli );
      cellfun( @(x) StimuliGroup.assert__isa(x, 'Stimulus'), stimuli );
      obj.stimuli(end+1:end+numel(stimuli)) = stimuli;
    end
    
    function update_targets(obj)
      
      %   UPDATE_TARGETS -- Update targets for all stimuli.
      
      cellfun( @(x) x.update_targets(), obj.stimuli );
    end
  end
  
  methods (Static = true)    
    function assert__isa(var, kind, var_name)
      
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
    
    function var = ensure_cell(var)
      
      %   ENSURE_CELL -- Ensure an input is a cell array.
      
      if ( ~iscell(var) ), var = { var }; end
    end
  end
end