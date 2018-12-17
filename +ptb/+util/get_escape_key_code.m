function code = get_escape_key_code()

%   GET_ESCAPE_KEY_CODE -- Get key code for escape key, cross-platform.
%
%     See also ptb.State, ptb.util.try_add_ptoolbox
%
%     OUT:
%       - `code` (double)

if ( ispc() )
  code = KbName( 'esc' );
else
  code = KbName( 'escape' );
end

end