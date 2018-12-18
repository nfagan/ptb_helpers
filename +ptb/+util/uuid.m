function id = uuid()

%   UUID -- Generate a random 128-bit id
%
%     OUT:
%       - `id` (char)

id = char( java.util.UUID.randomUUID() );

end