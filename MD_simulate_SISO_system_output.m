function [ sys_output, simulated_end_state] = MD_simulate_SISO_system_output(sys_input,initial_state,current_model,disp_message)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

T_sim=length(sys_input);
t=0:T_sim-1;

%pv_temp_u=[];



switch MD_constant_values.ident_mode
    case 1
    case 2
    case 3
    case 4
    case 5
    case 6
    case 7
        
        state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
        
        if disp_message
            initial_state
            state_space
        end
        
        sim=lsim(state_space,sys_input,t,initial_state);
        sys_output=sim(:,end);
        simulated_end_state=sim(end,:);
        
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