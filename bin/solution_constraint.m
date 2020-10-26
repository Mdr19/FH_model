function [ params_vector ] = solution_constraint( params_vector )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
n=MD_constant_values.n;
m=MD_constant_values.m;


for i=1:length(params_vector)
    if mod(i,m-1+n)<m && mod(i,m-1+n)>0
        %disp(['Param ' num2str(params_vector(i)) 'mod value ' num2str(mod(i,m-1+n))]);
        if params_vector(i)>0
            disp('Constraint violated !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            params_vector(i)=-0.1;%-0.1;
        else
            disp('Constraint violated !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            %params_vector(i)=1;%-0.1;
        end
    end
end

end

