function [ diff_signal ] = FH_calc_prev_signal_out( signal,t0,h,Tp)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

n_start=floor(ceil(t0(1))/h);
horizon=Tp+1;

new_signal=ones(1,horizon);

if length(signal)-n_start>horizon
    new_signal=signal(n_start+1:n_start+horizon);
elseif n_start<length(signal)
    
    for i=1:horizon
        if n_start+i<=length(signal)
            new_signal(i)=signal(n_start+i);
        else
            new_signal(i)=signal(end);
        end
    end
        
else
    new_signal=signal(end)*new_signal;
end

diff_signal=diff(new_signal);

end

