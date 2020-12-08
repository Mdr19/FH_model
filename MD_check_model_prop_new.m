function model_prop = MD_check_model_prop_new(current_model,model_inputs,n,input_signs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

model_prop=true;
%inputs_nr=sum(model_inputs);

for model_nr=1:length(current_model)
    
    current_input=1;
    model_inputs_nr=size(current_model(model_nr).B,2);
    params_vector=current_model(model_nr).vector;
    
    
    for i=1:model_inputs_nr
        
        for j=1:n
            
            %model_nr
            %i
            %current_input
            %params_vector(end-(model_inputs_nr-current_input+1)*n+j)
            
            if model_inputs(i)==0
                
            elseif (input_signs(i)==0) || (params_vector(end-(model_inputs_nr-current_input+1)*n+j)>0 && input_signs(i)==1) ||...
                    (params_vector(end-(model_inputs_nr-current_input+1)*n+j)<0 && input_signs((model_nr-1)+i)==-1)
                
                model_prop=true;
            else
                disp('Inappropriate model');
                model_prop=false;
                break;
            end
        end
        
        if model_prop==false;
            break;
        else
            current_input=current_input+1;
        end
        
        
    end
    
end

%{
model_prop=true;
inputs_nr=sum(model_inputs);

params_vector

current_input=1;

for i=1:length(model_inputs)
    
    for j=1:n
        if model_inputs(i)==0
            
        elseif (input_signs(i)==0) || (params_vector(end-(inputs_nr-current_input+1)*n+j)>0 && input_signs(i)==1) ||...
                (params_vector(end-(inputs_nr-current_input+1)*n+j)<0 && input_signs(i)==-1)
            
            model_prop=true;
        else
            disp('Inappropriate model');
            model_prop=false;
            break;
        end
    end
    
    if model_prop==false;
        break;
    else
        current_input=current_input+1;
    end
end
%}