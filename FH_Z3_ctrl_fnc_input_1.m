function [ result ] = FH_Z3_ctrl_fnc_input_1(u,t)

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

global first_time;

%global error_hist;

global Kp;
global Ki;

global u_prev;
global state_prev;
global u_mpc;

global MPC_model

if (MD_constant_values.sim_mode_Z3==0)
    if t==0
        t=1;
    elseif t>length(input_signals.Z3_input_1)
        t=length(input_signals.Z3_input_1);
    end
    
    result=input_signals.Z3_input_1(ceil(t(1)))*ones(size(u));
    
elseif (MD_constant_values.sim_mode_Z3==1) || isempty(MPC_model) || isempty(MPC_model.Z3) % PID
    
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
                E_int.Z3=E_int.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
            end
        else
            %E_int=0;
        end
        
        
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>6
                result(i)=6;
            elseif result(i)<0.6
                result(i)=0.6;
            end
        end
        
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
        
        disp(['Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int.Z3) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z3(1,:)=result(1);
        first_time=true;
        
    else
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>6
                result(i)=6;
            elseif result(i)<0.6
                result(i)=0.6;
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
    
    
elseif MD_constant_values.sim_mode_Z3==2
    
    if t(1)==0
        result=u_prev.Z3(1);
        u_mpc.Z3=u_prev.Z3-MPC_model.Z3.ctrl_offset';
        %state_prev.Z3=MPC_model.Z3.X0;
        
        if isempty(output_signal.Z3)
            input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
            input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
            output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        end
        
        %{
        disp('Sterowanie przed :')
        u_mpc.Z3
        disp('--------------------------');
        u_mpc.Z3+MPC_model.Z3.ctrl_offset'
        %}
        
    elseif time_temp<t(1) && t(1)>0
        
        if t(1)>length(temp_SP)
            time_index=length(temp_SP);
        else
            time_index=ceil(t(1));
        end
        
        delta_t=t(1)-time_temp;
        
        h=0.1;         %0.03  0.02
        time_=time_temp:h:t(1);
        
        time_temp=t(1);
        
        
        y_=interp1([output_signal.Z3(end,1) t(1)],[output_signal.Z3(end,2) u(end),],time_)-MPC_model.Z3.output_offset;
        sp_t=[time_(1) time_(end)];
        
        sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
        sp_=interp1(sp_t,sp,time_)-MPC_model.Z3.output_offset;
        
               
        [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3,MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset,y_,sp_);
        
        %disp(['Control calulated: ' ]);
        %u_mpc.Z3
        
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        
        if isnan(u_mpc.Z3)
            u_mpc.Z3=u_prev.Z3-MPC_model.Z3.ctrl_offset';
        end
        
        %{
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
        %}
        
        result=u_mpc.Z3+MPC_model.Z3.ctrl_offset';
        
        u_prev.Z3=result;                           % z offsetem
        %state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) result(2)]];
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    else
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
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
