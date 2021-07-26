function FH_set_MPC_model_FF( ident_section,section_name)

global MPC_model


if ~isempty(ident_section.MPC_model)  
    
    disp('Obtaining the current MPC model FF');
    
    %MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;  
    MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;    
    MPC_model.(strcat(section_name,'_new_model_set'))=true;
    
end

end

