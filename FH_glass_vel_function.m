function [ result ] = FH_glass_vel_function(t)

global glass_pull;

if t==0
    t=1;
elseif t>length(glass_pull)
    t=length(glass_pull);
end

p=glass_pull(ceil(t(1)));
result=(0.0344*p+1.236)*0.001;

end
