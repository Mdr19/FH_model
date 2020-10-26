function [ result ] = FH_boundary_function(t)

global temp_zone_prev;

if t==0
    t=1;
elseif t>length(temp_zone_prev)
    t=length(temp_zone_prev);
end

result=temp_zone_prev(ceil(t));

end