function [MISO_output] = MD_simulate_MISO_without_selected(current_system,...
    initial_state,u_sim,current_nr)

    %Symuluj wszystkie oprocz zadanego 

    inputs_nr=length(current_system);
    
    n=rank(current_system(1).A);

    
    t_=0:1:length(u_sim)-1;

    %Symuluj wszystkie oprocz zadanego 
    pv_temp_u=[]; 
        
    for i=1:inputs_nr
        if i~=current_nr
           state_space=ss(current_system(i).A,current_system(i).B,...
           current_system(i).C,current_system(i).D);
           pv_temp_u(i,:,:)=lsim(state_space,u_sim(i,:),t_,initial_state(i,:));
        end
    end
        
    if size(pv_temp_u,1)>1   
        MISO_output=sum(pv_temp_u(:,:,n));
    else
        MISO_output=pv_temp_u(:,:,n);
    end
        
end

        
