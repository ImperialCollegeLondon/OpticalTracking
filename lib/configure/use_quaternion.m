function R = use_quaternion(header)
% Looks for a header that includes 'q0'. Euler headers would include Rx.
R = any(contains(header, "q0", "IgnoreCase",true));
end