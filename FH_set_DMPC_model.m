function FH_set_DMPC_model( ident_section,section_name)
%UNTITLED Summary of this function goes here
global MPC_model

if ~isempty(ident_section.MPC_model)
    
    disp('Obtaining the current DMPC model');
    
    %MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;
    MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;
    MPC_model.(strcat(section_name,'_new_model_set'))=true;
    
    
end

end

