classdef MD_constant_values
    properties (Constant)
        %% Ogólne parametry
        T_sim=250;                                               % szerokoœæ interwa³u syulacji
        message_display=0;
        
        %% forehearth parameters PDE
        FH_PDE_display=[];              % do rozwi¹zywania PDE 1 dla wyœwietlania, inaczej []
        FH_message_display=0;            % do czytania z pliku - wyœwietlanie informacji diagnostycznych
        
        %% Parametry symulacji dla PDE
        sim_mode=0;                      % 0 - czytanie danych historycznych, 1 - symulacja z dzialaniem regulatora, 2 - tryb mieszany
        sim_mode_Z3=5;                   % 0 - , 1- PID, 2 - MPC, 3 - MPC z FF, 4 - DMPC, 5 - DMPC z FF
        sim_mode_Z4=3;
        
        add_noise=1;
        snr=20;
        
        pull_uncertain_Z3=1;
        pull_uncertain_Z4=1;
        
        temp_poly_rank=2;                  % 4 pocz., potem 6   2 ostatnio
          
        %% Strejc model ident params
        %Strejc_ident_time=500*6;
        %Strejc_signal_nr=2;
        %Strejc_rank_constraint=0;        % Strejc model with the same rank as SS model 
        
        Kp=1.0;     % 1.0
        Ki=0.01;    % 0.01
               
        Kp_cln=30;  % 30
        Ki_cln=0.1; % 0.1
        
        %% MPC model params
        h_Z3=0.1;      %0.0002       0.01
        h_Z4=0.01;      %0.01
        
        Z3_model_delay=50;      %50
        Z4_model_delay=50;
        
        model_diff_intervals=4;
        new_OP_diff=250*4;      % 1000 lub 1500
        
        PID_max_int=(6/3)*2;
        PID_max_cln_int=(75/3)*2;
        
        mix_press_max=6;
        mix_press_min=0.6;
        mix_press_d=0.05*3; %10/10;
        
        cln_vlv_max=75;
        cln_vlv_min=5;
        cln_vlv_d=MD_constant_values.mix_press_d;
        
        %% Prev section params
        
        %Z3_prev_section_corr=0;
        %Z4_prev_section_corr=0;
        %Z4_prev_delta=2;
        
        %mpc_tau=0.1;
        
    end
end