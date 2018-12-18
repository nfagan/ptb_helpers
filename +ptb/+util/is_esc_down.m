function tf = is_esc_down()

%   IS_ESC_DOWN -- True if escape key has been pressed.
%
%     See also ptb.util.get_escape_key_code
%
%     OUT:
%       - `tf` (logical)

tf = ptb.util.is_key_down( ptb.util.get_escape_key_code() );

end