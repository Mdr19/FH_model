function [ result ] = FH_Z3_ctrl_fnc_input_1(u,t)

%disp(['Czas ' num2str(t)]);
%load('PNV_FH_signals','input_signal_1');

%global input_signal_1
global input_signals

global temp_SP;
global prev_SP;

global E_int;
global E_int_cln;

global E_temp;
global time_temp;

global input_signal_applied;
global output_signal;

%global first_time;

%global error_hist;

global Kp;
global Ki;

global Ki_cln;

global u_prev;
global state_prev;
global u_mpc;

global MPC_model


max_press=MD_constant_values.mix_press_max;
min_press=MD_constant_values.mix_press_min;

max_int=MD_constant_values.PID_max_int;
max_int_cln=MD_constant_values.PID_max_cln_int;

if (MD_constant_values.sim_mode_Z3==0)
    
    % Logged inputs applied
    
    if t==0
        t=1;
    elseif t>length(input_signals.Z3_input_1)
        t=length(input_signals.Z3_input_1);
    end
    
    result=input_signals.Z3_input_1(ceil(t(1)))*ones(size(u));
    
elseif (MD_constant_values.sim_mode_Z3==1) || isempty(MPC_model) || isempty(MPC_model.Z3) % PID
    
    % PID controller
    
    if t==0
        t=1;
    elseif t>length(temp_SP)
        t=length(temp_SP);
    end
    
    error=temp_SP(ceil(t(1)))-u(end);
        
    if time_temp<t(1)
        %time_temp=t(1);
        
        if prev_SP==temp_SP(ceil(t(1)));
            E_temp=temp_SP(ceil(t(1)))-u(end);
            if t(1)>1
                
                if E_temp>0 && E_int.Z3*Ki>max_int
                    E_int.Z3=max_int/Ki;
                else
                    E_int.Z3=E_int.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
                
                if E_temp>0 && E_int_cln.Z3*Ki_cln>max_int_cln
                    E_int_cln.Z3=max_int_cln/Ki_cln;
                else
                    E_int_cln.Z3=E_int_cln.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
                
                
            end
        else
            %E_int=0;
        end
        
        
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
        
        disp(['Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int.Z3) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z3(1,:)=result(1);
        %first_time=true;
        
    else
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
    end
    
    prev_SP=temp_SP(ceil(t(1)));
    
elseif MD_constant_values.sim_mode_Z3==2 && sum(MPC_model.Z3.control_signals)==2
    
    % MPC model for both inputs
    
    if t(1)==0
        result=u_prev.Z3(1);
        u_mpc.Z3=u_prev.Z3-MPC_model.Z3.ctrl_offset';
        state_prev.Z3=MPC_model.Z3.X0;
        
        if isempty(output_signal.Z3)
            input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
            input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
            output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        end
        
    elseif time_temp<t(1) && t(1)>0
        
        if t(1)>length(temp_SP)
            time_index=length(temp_SP);
        else
            time_index=ceil(t(1));
        end
        
        delta_t=t(1)-time_temp;
        
        h=MD_constant_values.h_Z3;         %0.03  0.02
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
        
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
        
        %result=u_mpc.Z3+MPC_model.Z3.ctrl_offset';
        
        u_prev.Z3=u_mpc.Z3+MPC_model.Z3.ctrl_offset';                           % z offsetem
        state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    else
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    end
    
elseif MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(1)
    
    % MPC for mixture pressure
   
    if t(1)==0
        result=u_prev.Z3(1,:);
        u_mpc.Z3(1,:)=u_prev.Z3(1,:)-MPC_model.Z3.ctrl_offset(1,:)';
        state_prev.Z3=MPC_model.Z3.X0;
        
        if isempty(output_signal.Z3)
            input_signal_applied.Z3_input_1=[t(1) u_prev.Z3(1,:)];
            %input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
            output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
            
            %first_time=true;
        end
        
    elseif time_temp<t(1) && t(1)>0
        
        if t(1)>length(temp_SP)
            time_index=length(temp_SP);
        else
            time_index=ceil(t(1));
        end
        
        delta_t=t(1)-time_temp;
        
        h=MD_constant_values.h_Z3;         %0.03  0.02
        time_=time_temp:h:t(1);
                
        y_=interp1([output_signal.Z3(end,1) t(1)],[output_signal.Z3(end,2) u(end),],time_)-MPC_model.Z3.output_offset(1,:);
        sp_t=[time_(1) time_(end)];
        
        sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
        sp_=interp1(sp_t,sp,time_)-MPC_model.Z3.output_offset;
           
        [u_mpc.Z3(1,:), MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3(1,:),MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset,y_,sp_);
                
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        
        if isnan(u_mpc.Z3(1,:))
            u_mpc.Z3(1,:)=u_prev.Z3(1,:)-MPC_model.Z3.ctrl_offset(1,:)';
        end
        
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
                
        u_prev.Z3(1,:)=u_mpc.Z3(1,:)+MPC_model.Z3.ctrl_offset(1,:)';                           % z offsetem
        state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
        
        result=u_mpc.Z3(1,:)+MPC_model.Z3.ctrl_offset(1,:);
        
    else
        
        result=u_mpc.Z3(1,:)+MPC_model.Z3.ctrl_offset(1,:);
        
    end
    
elseif MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(2)
    
   % PID for mix. press.
    
    if t(1)==0
        time_index=1;
    elseif t>length(temp_SP)
        time_index=length(temp_SP);
    else
        time_index=ceil(t(1));
    end
    
    error=temp_SP(time_index)-u(end);
    %error_disp=error;
    
     if t(1)==0
    
         if isempty(input_signal_applied.Z3_input_1)
            input_signal_applied.Z3_input_1=[t(1) u_prev.Z3(1,:)];
            %input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
         end
        
         result=u_prev.Z3(1,:);
    
    
    elseif time_temp<t(1)
        %time_temp=t(1);
                
        if ~isempty(input_signal_applied.Z3_input_1)   %prev_SP==temp_SP(ceil(t(1)));
            E_temp=temp_SP(time_index)-u(end);
            if t(1)>1
                
                if E_temp>0 && E_int.Z3*Ki>max_int
                    E_int.Z3=max_int/Ki;
                else
                    E_int.Z3=E_int.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
                
                if E_temp>0 && E_int_cln.Z3*Ki_cln>max_int_cln
                    E_int_cln.Z3=max_int_cln/Ki_cln;
                else
                    E_int_cln.Z3=E_int_cln.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
                
            end
        else
            %E_int=0;
        end
        
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
        
        %input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
        
        disp(['PID mix press. Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int.Z3) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z3(1,:)=result(1);
        u_mpc.Z3(1,:)=result(1);
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
                
        %first_time=true;
        
    else
        result=Kp*error+Ki*E_int.Z3;
        
        for i=1:length(result)
            if result(i)>max_press
                result(i)=max_press;
            elseif result(i)<min_press
                result(i)=min_press;
            end
        end
        
    end
    
    prev_SP=temp_SP(time_index);
        
end

end