function [ result ] = FH_ctrl_function_single(u,t)

%disp(['Czas ' num2str(t)]);

global mix_press;

global temp_SP;
global prev_SP;

global E_int;
global E_temp;
global time_temp;
global input_signal_applied;

global DC_signal
global control_offset
%global FF_model
%global output_signal_logged;

global error_hist;

global sim_mode_append;

%K_p=1.5;        %1.5          2
%K_i=0.05;       %0.05        0.1

global Kp;
global Ki;

%disp(['Nastawy: ' num2str(Kp) ' ' num2str(Ki)]);

if (MD_constant_values.sim_mode==0) || ((MD_constant_values.sim_mode==2) && (sim_mode_append==1))
    %load('FH_signals','mix_press');
    
    if t==0
        t=1;
    elseif t>length(mix_press)
        t=length(mix_press);
    end
    
    result=mix_press(ceil(t(1)))*ones(size(u));
    
    if MD_constant_values.sim_mode==2
        %error=temp_SP(ceil(t(1)))-u(end);
        
        if time_temp<t(1)
            time_temp=t(1);
            
            if prev_SP==temp_SP(ceil(t(1)));
                E_temp=temp_SP(ceil(t(1)))-u(end);
                if t(1)>1
                    E_int=E_int+E_temp*(t(1)-input_signal_applied(end,1));
                end
            end
            
            input_signal_applied=[input_signal_applied; [t(1) result(1)]];
        end
        
        prev_SP=temp_SP(ceil(t(1)));
        
    end
    
else
    
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
                E_int=E_int+E_temp*(t(1)-input_signal_applied(end,1));
            end
        else
            %E_int=0;
        end
        
        if ~isempty(DC_signal)
            result=Kp*error+Ki*E_int-DC_signal(ceil(t(1)))+control_offset;
            disp(['Control error: ' num2str(Kp*error) ' control integral: ' num2str(Ki*E_int)...
                ' Feed forward signal: ' num2str(DC_signal(ceil(t(1)))) ' Control signal: ' num2str(result) ]);
        else
            result=Kp*error+Ki*E_int;
        end
        
        input_signal_applied=[input_signal_applied; [t(1) result(1)]];
        
        disp(['Time: ' num2str(time_temp) ' error: ' num2str(error) ' integral: ' num2str(E_int) ' control signal: ' num2str(result(1))]);
           
    else
                
        if ~isempty(DC_signal)
            result=Kp*error+Ki*E_int-DC_signal(ceil(t(1)))+control_offset;
        else
            result=Kp*error+Ki*E_int;
        end
        
    end
    
    
    prev_SP=temp_SP(ceil(t(1)));
    
    error_hist=[error_hist; [t(1) error]];
    
  
    
    if length(error_hist)>1
        for i=1:length(error_hist)-1
            if i==length(error_hist)-1 && (error_hist(i,1)<t(1)) && (error_hist(i+1,1)>=t(1))
                error_hist=error_hist(i:end,:);
            end
        end
    end
    
    
    for i=1:length(result)
        if result(i)>6
            result(i)=6;
        elseif result(i)<0.6
            result(i)=0.6;
        end
    end   
    
end

%disp(['At time ' num2str(t(1)) ' ' num2str(result(end))]);

end