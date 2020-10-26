function [ result ] = FH_Z3_ctrl_fnc_input_2(u,t)

%disp(['Czas ' num2str(t)]);
%load('PNV_FH_signals','input_signal_1');

%global input_signal_1
global input_signals
global temp_SP;

global input_signal_applied;

global first_time;


global E_int;


global Kp_cln;
global Ki_cln;

global u_prev;

global u_mpc;
global MPC_model


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
    
    
    
    result=-(Kp_cln*error+Ki_cln*E_int.Z3);
    
    %result=5;
    
    for i=1:length(result)
        if result(i)>75
            result(i)=75;
        elseif result(i)<5
            result(i)=5;
        end
    end
    
    
    if first_time
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) result(1)]];
        first_time=false;
        u_prev.Z3(2,:)=result(1);
    end
    
elseif MD_constant_values.sim_mode_Z3==2
    
    result=u_mpc.Z3(2)+MPC_model.Z3.ctrl_offset(2);
    
    %{
    for i=1:length(result)
        if result(i)>75
            result(i)=75;
        elseif result(i)<5
            result(i)=5;
        end
    end
    %}
    
end



end

