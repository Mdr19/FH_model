function [MISO_output] = MD_simulate_SISO_selected(current_system,initial_state,u_sim)

    
    t_=0:1:length(u_sim)-1;

    %Symuluj wszystkie oprocz zadanego 
    pv_temp_u=[]; 
        
    state_space=ss(current_system.A,current_system.B,...
    current_system.C,current_system.D);
    MISO_output=lsim(state_space,u_sim,t_,initial_state);

end

        
