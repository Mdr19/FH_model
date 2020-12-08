function [temp_SP_steps, temp_SP_values]= MD_generate_SP_evenly(start_cnt,end_cnt,elements_nr,start_SP,end_SP)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

delta_t=ceil((end_cnt-start_cnt)/elements_nr);
delta_SP=(end_SP-start_SP)/elements_nr;

temp_SP_steps=zeros(elements_nr+1,1);
temp_SP_values=zeros(elements_nr+1,1);

temp_SP_steps(1)=1;
temp_SP_values(1)=start_SP;

for i=2:elements_nr+1
    temp_SP_values(i)=start_SP+delta_SP*(i-1);
    temp_SP_steps(i)=start_cnt+delta_t*(i-2);
end

end

