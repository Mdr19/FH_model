function model_prop = MD_check_model_prop( model_inputs,params_vector,input_signs,n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

model_prop=true;
inputs_nr=sum(model_inputs);
current_input_nr=1;

params_vector

for i=1:length(model_inputs)
    if model_inputs(i)
        if model_inputs(i)==0
            
        elseif (input_signs(i)==0) || (input_signs(i)==1 && params_vector(end-(inputs_nr-current_input_nr+1)*n+1)>0) ||...
                (input_signs(i)==-1 && params_vector(end-(inputs_nr-current_input_nr+1)*n+1)<0)
            %params_vector(end-(inputs_nr-current_input_nr+1)*n+1)
            current_input_nr=current_input_nr+1;
            model_prop=true;
        else
            %params_vector(end-(inputs_nr-current_input_nr+1)*n+1)
            disp('Inappropriate model');
            model_prop=false;
            break;
        end
    end
end

end

