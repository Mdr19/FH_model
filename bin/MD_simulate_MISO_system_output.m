function [ sys_output, simulated_end_state] = MD_simulate_MISO_system_output(sys_input,initial_state,current_model,disp_message)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

T_sim=length(sys_input);
t=0:T_sim-1;

pv_temp_u=[];



switch MD_constant_values.ident_mode
    case 1
        for i=1:size(initial_state,1)
            state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
            
            initial_state(i,:)
            if disp_message
                state_space
            end
            
            sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
            pv_temp_u(i,:)=sim(:,end);
            simulated_end_state(i,:)=sim(end,:);
        end
        
        sys_output=sum(pv_temp_u);
    case 2
    case 3
        state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
        if disp_message
            
            state_space
        end
        initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
        if disp_message
            initial_state
        end
        
        pv_temp_u=lsim(state_space,sys_input,t,initial_state);
        simulated_end_state=pv_temp_u(end,:);
        
        sys_output=sum(pv_temp_u');
    case 4
        
        if length(current_model)>1
            for i=1:size(initial_state,1)
                state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
                
                if disp_message
                    initial_state(i,:)
                    state_space
                end
                
                sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
                pv_temp_u(i,:)=sim(:,end);
                simulated_end_state(i,:)=sim(end,:);
            end
            
            sys_output=sum(pv_temp_u);
        else
            state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
            
            
            initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
            
            pv_temp_u=lsim(state_space,sys_input,t,initial_state);
            simulated_end_state=pv_temp_u(end,:);
            
            sys_output=sum(pv_temp_u');
        end
        
    case 5
        
        if length(current_model)>1
            for i=1:size(initial_state,1)
                state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
                
                if disp_message
                    initial_state(i,:)
                    state_space
                end
                
                sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
                pv_temp_u(i,:)=sim(:,end);
                simulated_end_state(i,:)=sim(end,:);
            end
            
            sys_output=sum(pv_temp_u);
        else
            state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
            
            
            initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
            
            pv_temp_u=lsim(state_space,sys_input,t,initial_state);
            simulated_end_state=pv_temp_u(end,:);
            
            sys_output=sum(pv_temp_u');
        end
        
    case 6
        
        if length(current_model)>1
            for i=1:size(initial_state,1)
                state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
                
                if disp_message
                    initial_state(i,:)
                    state_space
                end
                
                sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
                pv_temp_u(i,:)=sim(:,end);
                simulated_end_state(i,:)=sim(end,:);
            end
            
            sys_output=sum(pv_temp_u);
        else
            state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
            
            
            initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
            
            pv_temp_u=lsim(state_space,sys_input,t,initial_state);
            simulated_end_state=pv_temp_u(end,:);
            
            sys_output=sum(pv_temp_u');
        end
        
    case 7
        
        if length(current_model)>1
            for i=1:size(initial_state,1)
                state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
                
                if disp_message
                    initial_state(i,:)
                    state_space
                end
                
                current_inputs=size(current_model(i).B,2);
                
                %if current_inputs==1
                %    sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
                %else
                    sim=lsim(state_space,sys_input(i:i+current_inputs-1,:),t,initial_state(i,:));
                %end
                
                pv_temp_u(i,:)=sim(:,end);
                simulated_end_state(i,:)=sim(end,:);
            end
            
            sys_output=sum(pv_temp_u);
        else
            state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);
            
            
            initial_state=initial_state(1,:); % dla przypadku zerowego stanu poczatkowego
            
            pv_temp_u=lsim(state_space,sys_input,t,initial_state);
            simulated_end_state=pv_temp_u(end,:);
            
            sys_output=sum(pv_temp_u');
        end
        
    otherwise
        for i=1:size(initial_state,1)
            state_space=ss(current_model(i).A,current_model(i).B,current_model(i).C,current_model(i).D);
            
            if disp_message
                initial_state(i,:)
                state_space
            end
            
            sim=lsim(state_space,sys_input(i,:),t,initial_state(i,:));
            pv_temp_u(i,:)=sim(:,end);
            simulated_end_state(i,:)=sim(end,:);
        end
        
        sys_output=sum(pv_temp_u);
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