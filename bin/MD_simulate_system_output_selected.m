function [ sys_output, simulated_end_state] = MD_simulate_system_output_selected(sys_input,initial_state,current_model,selected_nr,disp_message)
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
           
                    state_space=ss(current_model(selected_nr).A,current_model(selected_nr).B,current_model(selected_nr).C,current_model(selected_nr).D);
                    
                    if disp_message
                        initial_state(i,:)
                        state_space
                    end
                    
                    sim=lsim(state_space,sys_input,t,initial_state(selected_nr,:));
                    sys_output=sim(:,end)';
                    simulated_end_state=sim(end,:);
                
            
            %sys_output=sum(pv_temp_u);
        else
            
            B=current_model.B(:,selected_nr);
            D=0;
            n=rank(current_model.A);
            %initial_state_=[initial_state(1:n) initial_state(1,n+selected_nr)]; % dla przypadku zerowego stanu poczatkowego
            
            %{
            for i=1:length(sys_input);
                if i~=exclude_nr
                    B=[B; current_model.B(:,i)];
                    D=[D; current_model.D(:,i)];
                    initial_state_=[initial_state_ initial_state(1,n+i)];
                end
            end
            %}
            
            state_space=ss(current_model.A,B,current_model.C,D);
            
            
            %initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
            
            sys_output=lsim(state_space,sys_input,t,initial_state);
            simulated_end_state=sys_output(end,:);
            
            %sys_output=sum(pv_temp_u');
        end
        
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