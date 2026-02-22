%Increments quater count by n.
%Usage:
% q = q_plus(q,n)


function p = q_plus(q,n)

%Warning
warning('Index is preferred to q_plus.');

n_q = 4;
if q >n_q || q< 1
    error('Invalid quarter input');
end

p = mod(q+n,n_q);
if p == 0
    p = n_q;
end
