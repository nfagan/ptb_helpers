classdef Identifier
  
  properties (Access = private)
    primary_id;
  end
  
  methods
    function obj = Identifier()
      obj.primary_id = ptb.util.uuid();
    end
  end
  
  methods (Access = public)
    function tf = eq(obj, B)
      
      %   EQ -- True if two operands are matching ptb.Identifier objects.
      %
      %     See also ptb.Identifier, ptb.ne
      
      cls = 'ptb.Identifier';
      tf = isa( B, cls ) && isa( obj, cls ) && strcmp( obj.primary_id, B.primary_id );
    end    
    
    function tf = ne(obj, B)
      
      %   EQ -- True if two operands are non-matching ptb.Identifier 
      %     objects, or are not both ptb.Identifier objects.
      %
      %     See also ptb.Identifier, ptb.eq
      
      tf = ~eq( obj, B );
    end
  end
end