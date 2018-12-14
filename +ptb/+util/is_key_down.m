function tf = is_key_down(code)

%   IS_KEY_DOWN -- True if the key given by a key-code is down.
%
%     See also KbName
%
%     IN:
%       - `code` (numeric)
%     OUT:
%       - `tf` (logical)

[key_pressed, ~, key_code] = KbCheck();
tf = key_pressed && key_code(code);

end