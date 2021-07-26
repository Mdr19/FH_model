function FH_set_diturbance_eta( ident_section,section_name)

global MPC_model


if ~isempty(ident_section.MPC_model)  
    
    disp('Setting the current MPC model disturbance eta');
    
    %MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;  
    MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;    
    MPC_model.(strcat(section_name,'_new_model_set'))=true;
    
end

end

