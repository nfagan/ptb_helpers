classdef Pipeline < handle
  
  properties (Access = private, Constant = true)
    aggregate_classes = { 'ptb.XYSource', 'ptb.XYSampler', 'ptb.XYTarget' };
    aggregate_property_names = { 'Sources', 'Samplers', 'Targets' };
  end
  
  properties (GetAccess = public, SetAccess = private)
    Sources = {};
    Samplers = {};
    Targets = {};
  end
  
  methods
    function obj = Pipeline()
      
      %   PIPELINE -- Create Pipeline object instance.
      %
      %     
      
    end
  end
  
  methods (Access = public)
    function was_added = add_component(obj, component)
      
      %   ADD_COMPONENT -- Add updateable component.
      %
      %     add_component( obj, component ); adds `component` to the current
      %     list of ptb.XYSources, ptb.XYSamplers, or ptb.XYTargets, 
      %     according to the class of `component` -- so long as it has not 
      %     already been added.
      %
      %     was_added = add_component(...) returns whether `component` was
      %     newly added to the corresponding list.
      %
      %     An error is thrown if `component` is not of one of the above
      %     types.
      %
      %     See also ptb.Pipeline, ptb.Pipeline.add_components, ptb.XYSource
      %
      %     IN:
      %       - `component` (ptb.XYSource, ptb.XYSampler, ptb.XYTarget)
      %     OUT:
      %       - `was_added` (logical)
            
      classes = obj.aggregate_classes;
      props = obj.aggregate_property_names;
      N = numel( props );
      
      was_added = false;
      
      for i = 1:N
        [class_matched, was_added] = check_add_component( obj, component ...
          , classes{i}, props{i} );
        
        if ( class_matched )
          return
        end
      end
      
      validateattributes( component, obj.aggregate_classes, {} ...
        , mfilename, 'component' );
    end
    
    function was_added = add_components(obj, varargin)
      
      %   ADD_COMPONENTS -- Add arbitrary number of updateable components.
      %
      %     add_components( obj, component1, component2, ... ) adds any
      %     number of updateable components to `obj`. An error is thrown,
      %     and no components added, if any input is an invalid type.
      %
      %     See also ptb.Pipeline.add_component, ptb.Pipeline
      
      for i = 1:numel(varargin)
        validateattributes( varargin{i}, obj.aggregate_classes, {} ...
          , mfilename, 'a "component"', i );
      end
      
      was_added = false( size(varargin) );
      
      for i = 1:numel(varargin)
        was_added(i) = add_component( obj, varargin{i} );
      end
    end
    
    function update(obj)
      
      %   UPDATE -- Update components.
      %
      %     update( obj ) updates each source, sampler, and target in `obj`
      %     in logical order. Sources are updated first, followed by
      %     samplers, followed by targets.
      %
      %     See also ptb.Pipeline
      
      update_component_set( obj, obj.Sources );
      update_component_set( obj, obj.Samplers );
      update_component_set( obj, obj.Targets );
    end
  end
  
  methods (Access = private)
    function [class_matches, was_added] = ...
        check_add_component(obj, component, kind, aggregate)
      
      class_matches = false;
      was_added = false;
      
      if ( ~isa(component, kind) )
        return;
      end
      
      class_matches = true;
      
      if ( ~any(cellfun(@(x) x == component, obj.(aggregate))) )
        obj.(aggregate){end+1} = component;
        was_added = true;
      end
    end
    
    function update_component_set(obj, component_set)
      N = numel( component_set );
      
      for i = 1:N
        update( component_set{i} );
      end
    end
  end
end