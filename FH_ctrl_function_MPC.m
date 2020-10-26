function [ result ] = FH_ctrl_function_MPC(u,t)

%disp(['Czas ' num2str(t)]);

%global mix_press;

global temp_SP;
global prev_SP;

global E_int;
global E_temp;
global time_current;
global input_signal_applied;

global DC_signal
%global control_offset
%global FF_model
%global output_signal_logged;

global error_hist;

%global control_signal_last;
%global output_signal_last;


global MPC_model;
global u_mpc;
global u_PID;

global output_signal;
%global sim_mode_append;

%K_p=1.5;        %1.5          2
%K_i=0.05;       %0.05        0.1

global Kp;
global Ki;

%disp(['Nastawy: ' num2str(Kp) ' ' num2str(Ki)]);

if t(1)==0
    time_index=1;
elseif t(1)>length(temp_SP)
    time_index=length(temp_SP);
else
    time_index=ceil(t(1));
end

error=temp_SP(time_index)-u(end);

if time_current<time_index
    time_current=time_index;
    
    % update integratora
    if prev_SP==temp_SP(time_index);
        E_temp=temp_SP(time_index)-u(end);
        if t(1)>1
            E_int=E_int+E_temp*(t(1)-input_signal_applied(end,1));
        end
    else
        %E_int=0;
    end
    
    disp('----------------------------------------------------------------------------');
    if isempty(MPC_model)
        u_mpc=0;
    end
    
    if time_index==1
        % tylko gdy nie bylo wczesniej MPC
        if u_mpc==0 && ~isempty(MPC_model)
            u_mpc=u_PID-MPC_model.ctrl_offset;
        end
        
    else
        disp(['Time current ' num2str(t(1)) ' time prev ' num2str(output_signal(end,1)) ' delta t '...
            num2str(t(1)-output_signal(end,1))]);
        disp(['Output current ' num2str(u(end)) ' time prev ' num2str(output_signal(end,2)) ' delta y '...
            num2str(u(end)-output_signal(end,2))]);
        
        if ~isempty(MPC_model)
            
            delta_t=t(1)-output_signal(end,1);
            h=0.03;
            time_=output_signal(end,1):h:t(1);
            y_=interp1([output_signal(end,1) t(1)],[output_signal(end,2) u(end),],time_)-MPC_model.output_offset;
            
            sp_t=[time_(1) time_(end)];
            
            
            
            sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
            
            sp_=interp1(sp_t,sp,time_)-MPC_model.output_offset;
            
            
            [u_mpc, MPC_model.X0]=MD_calculate_MPC_control_signal(MPC_model.A,MPC_model.B,...
                MPC_model.C,MPC_model.K_ob,MPC_model.Omega,MPC_model.Psi,...
                MPC_model.Lzerot,MPC_model.M,h,u_mpc,MPC_model.X0,MPC_model.ctrl_offset,y_,sp_);
                        
        end
    end
    
    
    
    
    % modyfikacja sterowania dla FF
    if ~isempty(DC_signal)
        %result=Kp*error+Ki*E_int-DC_signal(time_index)+control_offset;
        %result=-DC_signal(time_index)+control_offset;
        
        if ~isempty(MPC_model)
            result=u_mpc+MPC_model.ctrl_offset-DC_signal(time_index);
        else
            result=Kp*error+Ki*E_int-DC_signal(time_index);
        end
        
        
        %disp(['Control error: ' num2str(Kp*error) ' control integral: ' num2str(Ki*E_int)...
        %    ' Feed forward signal: ' num2str(DC_signal(time_index)) ' Control signal: ' num2str(result) ]);
        %u(end)
    else
        if ~isempty(MPC_model)
            result=u_mpc+MPC_model.ctrl_offset;
            disp(['My result ' num2str(result)]);
        else
            result=Kp*error+Ki*E_int;
        end
        
        %u(end)
    end
    
    
    for i=1:length(result)
        if result(i)>6
            result(i)=6;
        elseif result(i)<0.6
            result(i)=0.6;
        end
    end
    
    
    if isempty(MPC_model)
        u_PID=result;
    end
    
    input_signal_applied=[input_signal_applied; [t(1) result(1)]];
    output_signal=[output_signal; [t(1) u(end)]];
    
    %disp(['Time: ' num2str(time_current) ' error: ' num2str(error) ' integral: ' num2str(E_int) ' control signal: ' num2str(result(1))]);
    disp(['Time: ' num2str(time_current) ' control signal original: ' num2str(result(1)) ' control signal MPC: ' num2str(u_mpc)]);
    
else
    
    %result=Kp*error+Ki*E_int;
    
    if ~isempty(DC_signal)
        %result=Kp*error+Ki*E_int-DC_signal(time_index)+control_offset;
        %result=-DC_signal(time_index)+control_offset;
        
        if ~isempty(MPC_model)
            result=u_mpc+MPC_model.ctrl_offset-DC_signal(time_index);
        else
            result=Kp*error+Ki*E_int-DC_signal(time_index);
        end
        
    else
        if ~isempty(MPC_model)
            result=u_mpc+MPC_model.ctrl_offset;
        else
            result=Kp*error+Ki*E_int;
        end
        
        
    end
    
    % ograniczenia na sterowanie
    
    for i=1:length(result)
        if result(i)>6
            result(i)=6;
        elseif result(i)<0.6
            result(i)=0.6;
        end
    end
    
    
end


prev_SP=temp_SP(time_index);

error_hist=[error_hist; [t(1) error]];

if length(error_hist)>1
    for i=1:length(error_hist)-1
        if i==length(error_hist)-1 && (error_hist(i,1)<t(1)) && (error_hist(i+1,1)>=t(1))
            %error_hist=error_hist(i:end,:);
            %E_int=E_int+error_hist(i,2);
            error_hist=error_hist(i:end,:);
        end
    end
end

end