function model_stable = MD_check_model_stable(params_vector,n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

den=params_vector(1:n);
sys=tf(1,den');

model_stable=isstable(sys);

end

