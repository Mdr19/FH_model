function [ result ] = FH_Z4_ctrl_fnc_input(u,t)

%disp(['Czas ' num2str(t)]);
%load('PNV_FH_signals','input_signal_1');

%global input_signal_1
global input_signals

global temp_SP;
global prev_SP;

global E_int;
global E_temp;
global time_temp;

global input_signal_applied;
global output_signal;

%global error_hist;

%global Z4_time_stamp;

%K_p=1.5;        %1.5          2
%K_i=0.05;       %0.05        0.1

global Kp;
global Ki;

global u_prev;
global state_prev;
global u_mpc;

global MPC_model


max_press=MD_constant_values.mix_press_max;
min_press=MD_constant_values.mix_press_min;

max_int=MD_constant_values.PID_max_int;


if ~isempty(MPC_model.Z4_new) && ~isempty(MPC_model.Z4_new_model_set) && MPC_model.Z4_new_model_set && t(1)>=MD_constant_values.Z4_model_delay
    MPC_model.Z4=MPC_model.Z4_new;
    MPC_model.Z4_new_model_set=false;
end


if (MD_constant_values.sim_mode_Z4==0) %|| ((MD_constant_values.sim_mode==2) && (sim_mode_append==1))
    %load('FH_signals','mix_press');
    
    if t==0
        t=1;
    elseif t>length(input_signals.Z4_input)
        t=length(input_signals.Z4_input);
    end
    
    result=input_signals.Z4_input(ceil(t(1)))*ones(size(u));
    
elseif (MD_constant_values.sim_mode_Z4==1) || isempty(MPC_model.Z4)  %MPC_model.Z4_new_model_set % || isempty(MPC_model.Z4) % PID
    
    if t==0
        t=1;
    elseif t>length(temp_SP)
        t=length(temp_SP);
    end
    
    error=temp_SP(ceil(t(1)))-u(end);
    %error_disp=error;
    
    
    if time_temp<t(1)
        time_temp=t(1);
        
        if prev_SP==temp_SP(ceil(t(1)));
            E_temp=temp_SP(ceil(t(1)))-u(end);
            if t(1)>1
                
                if E_temp>0 && E_int.Z4*Ki>max_int
                    E_int.Z4=max_int/Ki;
                else
                    E_int.Z4=E_int.Z4+E_temp*(t(1)-input_signal_applied.Z4_input_1(end,1));
                end
                
            end
        else
            %E_int=0;
        end
        
        
        result=Kp*error+Ki*E_int.Z4;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
        input_signal_applied.Z4_input_1=[input_signal_applied.Z4_input_1; [t(1) result(1)]];
        output_signal.Z4=[output_signal.Z4; [t(1) u(end)]];
        
        disp(['Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int.Z4) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z4=result(1);
        
        if ~isempty(MPC_model.Z4_new) && MPC_model.Z4_new_model_set
            u_mpc.Z4=u_prev.Z4-MPC_model.Z4_new.ctrl_offset;
        end
        
        %Z4_time_stamp=t(1);
    else
        result=Kp*error+Ki*E_int.Z4;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
    end
    
    prev_SP=temp_SP(ceil(t(1)));
    
    %{
    error_hist=[error_hist; [t(1) error]];
    
    if length(error_hist)>1
        for i=1:length(error_hist)-1
            if i==length(error_hist)-1 && (error_hist(i,1)<t(1)) && (error_hist(i+1,1)>=t(1))
                error_hist=error_hist(i:end,:);
            end
        end
    end
    %}
    
    
    
elseif MD_constant_values.sim_mode_Z4==2
    
    if t(1)==0
        result=u_prev.Z4;
        u_mpc.Z4=u_prev.Z4-MPC_model.Z4.ctrl_offset;
        
        if isempty(output_signal.Z4)
            input_signal_applied.Z4_input_1=[input_signal_applied.Z4_input_1; [t(1) result(1)]];
            output_signal.Z4=[output_signal.Z4; [t(1) u(end)]];
        end
        
    elseif time_temp<t(1) && t(1)>0
        
        if t(1)>length(temp_SP)
            time_index=length(temp_SP);
        else
            time_index=ceil(t(1));
        end
        
        delta_t=t(1)-time_temp;
        
        h=MD_constant_values.h_Z4;         %0.03  0.02
        time_=time_temp:h:t(1);
        
        time_temp=t(1);
        
        
        y_=interp1([output_signal.Z4(end,1) t(1)],[output_signal.Z4(end,2) u(end),],time_)-MPC_model.Z4.output_offset;
        sp_t=[time_(1) time_(end)];
        
        sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
        sp_=interp1(sp_t,sp,time_)-MPC_model.Z4.output_offset;
        
        %sp
        
        [u_mpc.Z4, MPC_model.Z4.X0]=MD_calculate_MPC_control_signal(MPC_model.Z4.A,MPC_model.Z4.B,...
            MPC_model.Z4.C,MPC_model.Z4.K_ob,MPC_model.Z4.Omega,MPC_model.Z4.Psi,...
            MPC_model.Z4.Lzerot,MPC_model.Z4.M,h,u_mpc.Z4,MPC_model.Z4.X0,MPC_model.Z4.ctrl_offset,y_,sp_);
        
        output_signal.Z4=[output_signal.Z4; [t(1) u(end)]];
        
        if isnan(u_mpc.Z4)
            u_mpc.Z4=u_prev.Z4-MPC_model.Z4.ctrl_offset;
        end
        
        if isnan(MPC_model.Z4.X0)
            MPC_model.Z4.X0=state_prev.Z4;
        end
        
        result=u_mpc.Z4+MPC_model.Z4.ctrl_offset;
        
        u_prev.Z4=result(1);
        state_prev.Z4=MPC_model.Z4.X0;
        
        input_signal_applied.Z4_input_1=[input_signal_applied.Z4_input_1; [t(1) result(1)]];
        
    else
        
        result=u_mpc.Z4+MPC_model.Z4.ctrl_offset;
        
    end
    
    %{
    for i=1:length(result)
        if result(i)>6
            result(i)=6;
        elseif result(i)<0.6
            result(i)=0.6;
        end
    end
    %}
    
end

end