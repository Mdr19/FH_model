function [ result ] = FH_Z3_ctrl_fnc_input_2(u,t)

%disp(['Czas ' num2str(t)]);
%load('PNV_FH_signals','input_signal_1');

%global input_signal_1
global input_signals

global temp_SP;
global prev_SP;

global input_signal_applied;
global output_signal;

%global first_time;


%global E_int;
global E_int_cln;
global time_temp;

global Kp_cln;
global Ki_cln;

global u_prev;
global state_prev;

global u_mpc;
global MPC_model

global temp_zone_prev_inp
%global time_horizon

max_cln_vlv=MD_constant_values.cln_vlv_max;
min_cln_vlv=MD_constant_values.cln_vlv_min;

max_cln_vlv_d=MD_constant_values.cln_vlv_d;
min_cln_vlv_d=-MD_constant_values.cln_vlv_d;


max_int_cln=MD_constant_values.PID_max_cln_int;


if (MD_constant_values.sim_mode_Z3==0)
    
    
    if t==0
        t=1;
    elseif t>length(input_signals.Z3_input_2)
        t=length(input_signals.Z3_input_2);
    end
    
    result=input_signals.Z3_input_2(ceil(t(1)))*ones(size(u));
    
elseif (MD_constant_values.sim_mode_Z3==1) || isempty(MPC_model) || isempty(MPC_model.Z3) % PID
    
    if t==0
        t=1;
    elseif t>length(temp_SP)
        t=length(temp_SP);
    end
    
    error=temp_SP(ceil(t(1)))-u(end);
    %error_disp=error;
    
    
    
    result=-(Kp_cln*error+Ki_cln*E_int_cln.Z3);
    
    for i=1:length(result)
        if result(i)>max_cln_vlv
            result(i)=max_cln_vlv;
        elseif result(i)<min_cln_vlv
            result(i)=min_cln_vlv;
        end
    end
    
    if time_temp<t(1)
        time_temp=t(1);
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) result(1)]];
        %first_time=false;
        u_prev.Z3(2,:)=result(1);
    end
    
    if ~isempty(MPC_model.Z3_new) && MPC_model.Z3_new_model_set && MPC_model.Z3_new.control_signals(2)==1
        u_mpc.Z3(2,:)=u_prev.Z3(2)-MPC_model.Z3_new.ctrl_offset(end);
    end
    
elseif (MD_constant_values.sim_mode_Z3==2 && sum(MPC_model.Z3.control_signals)==2) || (MD_constant_values.sim_mode_Z3==3 && sum(MPC_model.Z3.control_signals)==2)...
        || (MD_constant_values.sim_mode_Z3==4 && sum(MPC_model.Z3.control_signals)==2) || (MD_constant_values.sim_mode_Z3==5 && sum(MPC_model.Z3.control_signals)==2)
    
    result=u_mpc.Z3(2)+MPC_model.Z3.ctrl_offset(end);
    
elseif (MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(1)) || (MD_constant_values.sim_mode_Z3==3 &&  MPC_model.Z3.control_signals(1))...
       || (MD_constant_values.sim_mode_Z3==4 &&  MPC_model.Z3.control_signals(1)) || (MD_constant_values.sim_mode_Z3==5 &&  MPC_model.Z3.control_signals(1))
    
    % PID for cln vlv
    
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
        
        if isempty(input_signal_applied.Z3_input_2)
            input_signal_applied.Z3_input_2=[t(1) u_prev.Z3(2,:)];
            %input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
        end
        
        result=u_prev.Z3(2,:);
        
    elseif time_temp<t(1)
        
        time_temp=t(1);
        
        if ~isempty(input_signal_applied.Z3_input_2)   %prev_SP==temp_SP(ceil(t(1)));
            E_temp=temp_SP(time_index)-u(end);
            
            
            if t(1)>1
                
                if E_temp>0 && E_int_cln.Z3*Ki_cln>max_int_cln
                    E_int_cln.Z3=max_int_cln/Ki_cln;
                elseif E_temp<0 && E_int_cln.Z3*Ki_cln<-max_int_cln
                    E_int_cln.Z3=-max_int_cln/Ki_cln;
                else
                    E_int_cln.Z3=E_int_cln.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_2(end,1));
                end
                
                
            end
            
        end
        
        result=-(Kp_cln*error+Ki_cln*E_int_cln.Z3);
        
        for i=1:length(result)
            if result(i)>max_cln_vlv
                result(i)=max_cln_vlv;
            elseif result(i)<min_cln_vlv
                result(i)=min_cln_vlv;
            end
        end
        
        
        %input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) result(1)]];
        
        disp(['PID cln vlv. Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int_cln.Z3) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z3(2,:)=result(1);
        %u_mpc.Z3(2,:)=result(1);
        
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) result(1)]];
        
        %first_time=false;
        
    else
        result=-(Kp_cln*error+Ki_cln*E_int_cln.Z3);
        
        for i=1:length(result)
            if result(i)>max_cln_vlv
                result(i)=max_cln_vlv;
            elseif result(i)<min_cln_vlv
                result(i)=min_cln_vlv;
            end
        end
        
    end
    
    prev_SP=temp_SP(time_index);
    
elseif (MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(end)) || (MD_constant_values.sim_mode_Z3==3 &&  MPC_model.Z3.control_signals(end))...
        || (MD_constant_values.sim_mode_Z3==4 &&  MPC_model.Z3.control_signals(end)) || (MD_constant_values.sim_mode_Z3==5 &&  MPC_model.Z3.control_signals(end))
    
    % MPC for cln vlv
    
    if t(1)==0
        result=u_prev.Z3(2,:);
        u_mpc.Z3(2)=u_prev.Z3(2)-MPC_model.Z3.ctrl_offset(end);
        state_prev.Z3=MPC_model.Z3.X0;
        
        if isempty(input_signal_applied.Z3_input_2)
            input_signal_applied.Z3_input_2=[t(1) u_prev.Z3(2,:)];
            %input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
            output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        end
        
    elseif time_temp<t(1) && t(1)>0
        
        if t(1)>length(temp_SP)
            time_index=length(temp_SP);
        else
            time_index=ceil(t(1));
        end
        
        delta_t=t(1)-time_temp;
        
        h=0.01; %MD_constant_values.h_Z3;         %0.03  0.02
        time_=time_temp:h:t(1);
        
        time_temp=t(1);
        %first_time=true;
        
        y_=interp1([output_signal.Z3(end,1) t(1)],[output_signal.Z3(end,2) u(end),],time_)-MPC_model.Z3.output_offset;
        sp_t=[time_(1) time_(end)];
        
        sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
        sp_=interp1(sp_t,sp,time_)-MPC_model.Z3.output_offset;
        
        
        if MD_constant_values.sim_mode_Z3==2
            
            [u_mpc.Z3(2), MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],...
                MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,[],[],...
                MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3(2),max_cln_vlv,min_cln_vlv,max_cln_vlv_d,min_cln_vlv_d,...
                MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset(end),y_,sp_,0);
            
        elseif MD_constant_values.sim_mode_Z3==3
            
            %{
            if ~isempty(MPC_model.Z3.Bd)
                eta_d=FH_calc_prev_zone_eta(MPC_model.Z3.A,MPC_model.Z3.Bd,MPC_model.Z3.tau,MPC_model.Z3.X0,MPC_model.Z3.phi_d,t,time_horizon,temp_zone_prev_inp);
            else
                eta_d=zeros(size(MPC_model.Z3.Gamma,2),1);
            end
            %}
            
            [u_mpc.Z3(2), MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,...
                MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,MPC_model.Z3.Gamma,MPC_model.Z3_eta_d,...
                MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3(2),max_cln_vlv,min_cln_vlv,max_cln_vlv_d,min_cln_vlv_d,...
                MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset(end),y_,sp_,1);
            
        elseif MD_constant_values.sim_mode_Z3==4
            
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
             
            [u_mpc.Z3(2), MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,[],MPC_model.Z3.Tc,u_mpc.Z3(2),max_cln_vlv,min_cln_vlv,max_cln_vlv_d/h,min_cln_vlv_d/h,MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset(end),Y,SP,[],false);
            
        elseif MD_constant_values.sim_mode_Z3==5
            
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
            
            prev_zone_signal=FH_calc_prev_signal_out(temp_zone_prev_inp,t,MPC_model.Z3.h,MPC_model.Z3.Tc);
             
            [u_mpc.Z3(2), MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,MPC_model.Z3.Phi_Phi_d,MPC_model.Z3.Tc,u_mpc.Z3(2),max_cln_vlv,min_cln_vlv,max_cln_vlv_d/h,min_cln_vlv_d/h,MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset(end),Y,SP,prev_zone_signal',true);
 
        end
        
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        
        if isnan(u_mpc.Z3(2))
            u_mpc.Z3(2)=u_prev.Z3(2)-MPC_model.Z3.ctrl_offset(end);
        end
        
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
        
        u_prev.Z3(2)=u_mpc.Z3(2)+MPC_model.Z3.ctrl_offset(end);                           % z offsetem
        state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
        
        result=u_mpc.Z3(2)+MPC_model.Z3.ctrl_offset(end);
        
    else
        
        result=u_mpc.Z3(2)+MPC_model.Z3.ctrl_offset(end);
        
    end
end

end