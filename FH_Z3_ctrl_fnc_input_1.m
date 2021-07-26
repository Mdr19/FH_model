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

global temp_zone_prev_inp
%global time_horizon


max_press=MD_constant_values.mix_press_max;
min_press=MD_constant_values.mix_press_min;
max_cln_vlv=MD_constant_values.cln_vlv_max;
min_cln_vlv=MD_constant_values.cln_vlv_min;

max_press_d=MD_constant_values.mix_press_d;
min_press_d=-MD_constant_values.mix_press_d;
max_cln_vlv_d=MD_constant_values.cln_vlv_d;
min_cln_vlv_d=-MD_constant_values.cln_vlv_d;


max_int=MD_constant_values.PID_max_int;
max_int_cln=MD_constant_values.PID_max_cln_int;

if ~isempty(MPC_model.Z3_new) && ~isempty(MPC_model.Z3_new_model_set) && MPC_model.Z3_new_model_set && t(1)>=MD_constant_values.Z3_model_delay
    
    MPC_model.Z3_saved=MPC_model.Z3_new;
  
    if (MD_constant_values.sim_mode_Z3==2 || MD_constant_values.sim_mode_Z3==3) && (((abs(u_prev.Z3(2)-MD_constant_values.cln_vlv_min)<1 && temp_SP(end)>u(end)) || ...
            (abs(u_prev.Z3(2)-MD_constant_values.cln_vlv_max)<1 && temp_SP(end)<u(end))) && ...
            sum(MPC_model.Z3_saved.control_signals)==2)
        
        disp('Mix. press ONLY - 2');
        
        MPC_model.Z3=MPC_model.Z3_saved;
        MPC_model.Z3.control_signals(2)=0;
        
        if size(MPC_model.Z3_saved.B,2)==2
            
            MPC_model.Z3.B=MPC_model.Z3_saved.B(:,1);
            
            n=size(MPC_model.Z3_saved.Omega,1)/2;
            MPC_model.Z3.Omega=MPC_model.Z3_saved.Omega(1:n,1:n);
            
            m=size(MPC_model.Z3_saved.Psi,1)/2;
            MPC_model.Z3.Psi=MPC_model.Z3_saved.Psi(1:m,:);

            if MD_constant_values.sim_mode_Z3==3
                MPC_model.Z3.Gamma=MPC_model.Z3_saved.Gamma(1:m,:);
            end
                
            MPC_model.Z3.Lzerot=MPC_model.Z3_saved.Lzerot(1,1:n);
            
            MPC_model.Z3.M=[];
            
            for i=1:size(MPC_model.Z3_saved.M,1)
                if mod(i,2)==1
                    MPC_model.Z3.M(ceil(i/2),:)=MPC_model.Z3_saved.M(i,1:n);
                end
            end
            
         
        end
           
    elseif  (MD_constant_values.sim_mode_Z3==2 || MD_constant_values.sim_mode_Z3==3) && (((abs(u_prev.Z3(1)-MD_constant_values.mix_press_min)<0.25 && temp_SP(end)<u(end)) || ...
            (abs(u_prev.Z3(1)-MD_constant_values.mix_press_max)<0.25 && temp_SP(end)>u(end))) && ...
            sum(MPC_model.Z3_saved.control_signals)==2)
        
        disp('Cln vlv ONLY - 2');
        
        MPC_model.Z3=MPC_model.Z3_saved;
        MPC_model.Z3.control_signals(1)=0;
        
        if size(MPC_model.Z3_saved.B,2)==2
            
            MPC_model.Z3.B=MPC_model.Z3_saved.B(:,2);
            
            n=size(MPC_model.Z3_saved.Omega,1)/2;
            MPC_model.Z3.Omega=MPC_model.Z3_saved.Omega(n+1:end,n+1:end);
            
            m=size(MPC_model.Z3_saved.Psi,1)/2;
            MPC_model.Z3.Psi=MPC_model.Z3_saved.Psi(m+1:end,:);
            
            if MD_constant_values.sim_mode_Z3==3
                MPC_model.Z3.Gamma=MPC_model.Z3_saved.Gamma(m+1:end,:);
            end
                
            MPC_model.Z3.Lzerot=MPC_model.Z3_saved.Lzerot(2,n+1:end);
            
            MPC_model.Z3.M=[];
            
            for i=1:size(MPC_model.Z3_saved.M,1)
                if mod(i,2)==0
                    MPC_model.Z3.M(ceil(i/2),:)=MPC_model.Z3_saved.M(i,n+1:end);
                end
            end
            
        end
    else
        MPC_model.Z3=MPC_model.Z3_saved;
    end
    
    u_mpc.Z3=u_prev.Z3-MPC_model.Z3.ctrl_offset';
    
    MPC_model.Z3_new_model_set=false;
    state_prev.Z3=MPC_model.Z3.X0;

    E_int.Z3=0;
end


if (MD_constant_values.sim_mode_Z3==0)
    
    % Logged inputs applied
    
    if t==0
        t=1;
    elseif t>length(input_signals.Z3_input_1)
        t=length(input_signals.Z3_input_1);
    end
    
    result=input_signals.Z3_input_1(ceil(t(1)))*ones(size(u));
    
elseif (MD_constant_values.sim_mode_Z3==1) || isempty(MPC_model.Z3) %|| isempty(MPC_model.Z3) % PID
    
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
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];

        
        disp(['Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int.Z3) ' control signal: ' num2str(result(1))]);
        
        u_prev.Z3(1,:)=result(1);
        %first_time=true;
        
        if ~isempty(MPC_model.Z3_new) && MPC_model.Z3_new_model_set && MPC_model.Z3_new.control_signals(1)==1
            u_mpc.Z3(1,:)=u_prev.Z3(1)-MPC_model.Z3_new.ctrl_offset(1);
        end
        
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
    
elseif (MD_constant_values.sim_mode_Z3==2 && sum(MPC_model.Z3.control_signals)==2) || (MD_constant_values.sim_mode_Z3==3 && sum(MPC_model.Z3.control_signals)==2)...
        || (MD_constant_values.sim_mode_Z3==4 && sum(MPC_model.Z3.control_signals)==2) || (MD_constant_values.sim_mode_Z3==5 && sum(MPC_model.Z3.control_signals)==2)
    
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
                
       
         if MD_constant_values.sim_mode_Z3==2
                                             
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,[],[],...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3,[max_press max_cln_vlv],[min_press min_cln_vlv],[max_press_d max_cln_vlv_d],[min_press_d min_cln_vlv_d],...  
            MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset,y_,sp_,0);
        
        elseif MD_constant_values.sim_mode_Z3==3
            
            %eta_d=FH_calc_prev_zone_eta(MPC_model.Z3.A,MPC_model.Z3.Bd,MPC_model.Z3.tau,MPC_model.Z3.X0,MPC_model.Z3.phi_d,t,time_horizon,temp_zone_prev_inp);   
            
            %{
            if ~isempty(MPC_model.Z3.Bd)
                eta_d=FH_calc_prev_zone_eta(MPC_model.Z3.A,MPC_model.Z3.Bd,MPC_model.Z3.tau,MPC_model.Z3.X0,MPC_model.Z3.phi_d,t,time_horizon,temp_zone_prev_inp);   
            else
                eta_d=zeros(size(MPC_model.Z3.Gamma,2),1);
            end
            %}
            
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,MPC_model.Z3.Gamma,MPC_model.Z3_eta_d,...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3,[max_press max_cln_vlv],[min_press min_cln_vlv],[max_press_d max_cln_vlv_d],[min_press_d min_cln_vlv_d],...  
            MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset,y_,sp_,1);
            
         elseif MD_constant_values.sim_mode_Z3==4
             
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
             
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,[],MPC_model.Z3.Tc,u_mpc.Z3,[max_press max_cln_vlv],[min_press min_cln_vlv],...
            [max_press_d/h max_cln_vlv_d/h],[min_press_d/h min_cln_vlv_d/h],MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset,Y,SP,[],false);

             
        elseif MD_constant_values.sim_mode_Z3==5
        
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
             
            prev_zone_signal=FH_calc_prev_signal_out(temp_zone_prev_inp,t,MPC_model.Z3.h,MPC_model.Z3.Tc);
            
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,MPC_model.Z3.Phi_Phi_d,MPC_model.Z3.Tc,u_mpc.Z3,[max_press max_cln_vlv],[min_press min_cln_vlv],...
            [max_press_d/h max_cln_vlv_d/h],[min_press_d/h min_cln_vlv_d/h],MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset,Y,SP,prev_zone_signal',true);
            
        end
       
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        
        if isnan(u_mpc.Z3)
            u_mpc.Z3=u_prev.Z3-MPC_model.Z3.ctrl_offset';
        end
        
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
        
        u_prev.Z3=u_mpc.Z3+MPC_model.Z3.ctrl_offset';                           % z offsetem
        state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
        input_signal_applied.Z3_input_2=[input_signal_applied.Z3_input_2; [t(1) u_prev.Z3(2)]];
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    else
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    end
    
elseif (MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(1)) || (MD_constant_values.sim_mode_Z3==3 &&  MPC_model.Z3.control_signals(1))...
            || (MD_constant_values.sim_mode_Z3==4 &&  MPC_model.Z3.control_signals(1)) || (MD_constant_values.sim_mode_Z3==5 &&  MPC_model.Z3.control_signals(1))

    % MPC for mixture pressure
    
    if t(1)==0
        result=u_prev.Z3(1,:);
        u_mpc.Z3(1,:)=u_prev.Z3(1)-MPC_model.Z3.ctrl_offset(1);
        state_prev.Z3=MPC_model.Z3.X0;
        
        if isempty(output_signal.Z3)
            input_signal_applied.Z3_input_1=[t(1) u_prev.Z3(1)];
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
        
        y_=interp1([output_signal.Z3(end,1) t(1)],[output_signal.Z3(end,2) u(end)],time_)-MPC_model.Z3.output_offset(1,:);
        sp_t=[time_(1) time_(end)];
        
        sp=[temp_SP(max(1,ceil(time_index-delta_t))) temp_SP(min(length(temp_SP),time_index))];
        sp_=interp1(sp_t,sp,time_)-MPC_model.Z3.output_offset;
        
        if MD_constant_values.sim_mode_Z3==2
                        
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,[],[],...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3(1),max_press,min_press,max_press_d,min_press_d,...
            MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset(1),y_,sp_,0);
        
        elseif MD_constant_values.sim_mode_Z3==3
                 
            %{
            if ~isempty(MPC_model.Z3.Bd)
                %eta_d=FH_calc_prev_zone_eta(MPC_model.Z3.A,MPC_model.Z3.Bd,MPC_model.Z3.tau,MPC_model.Z3.X0,MPC_model.Z3.phi_d,t,time_horizon,temp_zone_prev_inp);   
                eta_d=FH_calc_prev_zone_eta(MPC_model.Z3.A,MPC_model.Z3.Bd,h,MPC_model.Z3.X0,MPC_model.Z3.Ap,MPC_model.Z3.Lzerot,MPC_model.Z3.phi,MPC_model.Z3.phi_d,t,time_horizon,temp_zone_prev_inp);
            else
                eta_d=zeros(size(MPC_model.Z3.Gamma,2),1);
            end
            %}
            
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_MPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,...
            MPC_model.Z3.C,MPC_model.Z3.K_ob,MPC_model.Z3.Omega,MPC_model.Z3.Psi,MPC_model.Z3.Gamma,MPC_model.Z3_eta_d,...
            MPC_model.Z3.Lzerot,MPC_model.Z3.M,h,u_mpc.Z3(1),max_press,min_press,max_press_d,min_press_d,...
            MPC_model.Z3.X0,MPC_model.Z3.ctrl_offset(1),y_,sp_,1);
        
         elseif MD_constant_values.sim_mode_Z3==4
             
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
             
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,[],MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,[],MPC_model.Z3.Tc,u_mpc.Z3(1),max_press,min_press,max_press_d/h,min_press_d/h,MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset(1),Y,SP,[],false);

             
         elseif MD_constant_values.sim_mode_Z3==5
          
            Y=output_signal.Z3(end,2)-MPC_model.Z3.output_offset;
            SP=sp(end)-MPC_model.Z3.output_offset;
             
            prev_zone_signal=FH_calc_prev_signal_out(temp_zone_prev_inp,t,MPC_model.Z3.h,MPC_model.Z3.Tc);
            
            [u_mpc.Z3, MPC_model.Z3.X0]=MD_calculate_DMPC_control_signal(MPC_model.Z3.A,MPC_model.Z3.B,MPC_model.Z3.Bd,MPC_model.Z3.C,MPC_model.Z3.K_ob,...
            MPC_model.Z3.Phi_Phi,MPC_model.Z3.Phi_R,MPC_model.Z3.Phi_F,MPC_model.Z3.Phi_Phi_d,MPC_model.Z3.Tc,u_mpc.Z3(1),max_press,min_press,max_press_d/h,min_press_d/h,MPC_model.Z3.X0,...
            MPC_model.Z3.ctrl_offset(1),Y,SP,prev_zone_signal',true);

        end
        
        output_signal.Z3=[output_signal.Z3; [t(1) u(end)]];
        
        if isnan(u_mpc.Z3(1))
            u_mpc.Z3(1)=u_prev.Z3(1)-MPC_model.Z3.ctrl_offset(1);
        end
        
        if isnan(MPC_model.Z3.X0)
            MPC_model.Z3.X0=state_prev.Z3;
        end
        
        u_prev.Z3(1)=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);                           % z offsetem
        state_prev.Z3=MPC_model.Z3.X0;
        
        input_signal_applied.Z3_input_1=[input_signal_applied.Z3_input_1; [t(1) u_prev.Z3(1)]];
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    else
        
        result=u_mpc.Z3(1)+MPC_model.Z3.ctrl_offset(1);
        
    end
    
elseif (MD_constant_values.sim_mode_Z3==2 && MPC_model.Z3.control_signals(2)) || (MD_constant_values.sim_mode_Z3==3 &&  MPC_model.Z3.control_signals(2)) ||...
        (MD_constant_values.sim_mode_Z3==4 && MPC_model.Z3.control_signals(2)) || (MD_constant_values.sim_mode_Z3==5 &&  MPC_model.Z3.control_signals(2))
    
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
                elseif E_temp<0 && E_int.Z3*Ki<-max_int
                    E_int.Z3=-max_int/Ki;
                else
                    E_int.Z3=E_int.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
                
                if E_temp>0 && E_int_cln.Z3*Ki_cln>max_int_cln
                    E_int_cln.Z3=max_int_cln/Ki_cln;
                else
                    E_int_cln.Z3=E_int_cln.Z3+E_temp*(t(1)-input_signal_applied.Z3_input_1(end,1));
                end
            end
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
        %u_mpc.Z3(1,:)=result(1);
        
        
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