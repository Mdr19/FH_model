function [ sys_output, simulated_end_state] = MD_simulate_MISO_system_output_without_sel(sys_input,initial_state,current_model,exclude_nr,disp_message)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

T_sim=length(sys_input);
t=0:T_sim-1;

pv_temp_u=[];



switch MD_constant_values.ident_mode
    case 1
    case 2
    case 3
    case 4
    case 5
    case 6
    case 7
        
        if length(current_model)>1
            for i=1:size(initial_state,1)
                if i~=exclude_nr
                    state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
                
                    if disp_message
                        initial_state(i,:)
                        state_space
                    end
                
                    sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
                    pv_temp_u(i,:)=sim(:,end);
                    simulated_end_state(i,:)=sim(end,:);
                end
            end
             
            if size(pv_temp_u,1)>1
                sys_output=sum(pv_temp_u);
            else
                sys_output=pv_temp_u;
            end
                
        else
            
            inputs_nr=size(current_model.B,2);
            
            for i=1:inputs_nr
                if i~=exclude_nr
                    state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
                    initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
                    pv_temp_u=lsim(state_space,sys_input,t,initial_state);
                end
            end
            
            simulated_end_state=pv_temp_u(end,:);
            
            if size(pv_temp_u,1)>1
                sys_output=sum(pv_temp_u');
            else
                sys_output=pv_temp_u;
            end
            
        end
        
    otherwise
   
end


%simulated_end_state=reshape(simulated_end_state,1,(MD_constant_values.m-1)*length(initial_state));

simulated_end_state
%{
            obj.simulated_signals_intervals(obj.current_interval).signals=sum(pv_temp_u);
            
            obj.simulated_signals_intervals(obj.current_interval).time=start_time:...
                start_time+length(obj.simulated_signals_intervals(obj.current_interval).signals)-1;
            
            obj.simulated_signals_intervals(obj.current_interval).zero_point_offset=obj.current_zero_point_offset;
%}

%disp('Koniec');

end