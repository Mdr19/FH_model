classdef MD_constant_values
    properties (Constant)
        %% forehearth parameters PDE
        FH_PDE_display=[ ];              % do rozwi¹zywania PDE 1 dla wyœwietlania
        FH_message_display=0;            % do czytania z pliku - wyœwietlanie informacji diagnostycznych
        
        %% Parametry symulacji dla PDE
        sim_mode=0;                      % 0 - czytanie danych historycznych, 1 - symulacja z dzialaniem regulatora, 2 - tryb mieszany
        sim_mode_Z3=2;
        sim_mode_Z4=2;
        
        pull_uncertain_Z3=0;
        pull_uncertain_Z4=1;
        
        temp_poly_rank=2;                  % 4 pocz., potem 6
        
        %DC_mode=0;                       % dodatkowe sterowanie FF
        %PULL_uncertain=0;                % niepewnoœæ pomiaru wydobycia
        
        %% Strejc model ident params
        Strejc_ident_time=500*4;
        Strejc_signal_nr=2;
        Strejc_rank_constraint=0;        % Strejc model with the same rank as SS model 
        
        Kp=1.0;
        Ki=0.01;
               
        Kp_cln=30;
        Ki_cln=0.1;
        
        %% MPC model params
        h_Z3=0.01;      %0.0005       0.01
        h_Z4=0.001;      %0.01
        
        Z3_model_delay=50;
        Z4_model_delay=50;
        
        PID_max_int=6;
        PID_max_cln_int=75;
        
        mix_press_max=6;
        mix_press_min=0.6;
        mix_press_d=0.05;
        
        cln_vlv_max=75;
        cln_vlv_min=5;
        cln_vlv_d=0.05;
        
        %mpc_tau=0.1;
        
        %% Ogólne parametry
        T_sim=250;                                               % szerokoœæ interwa³u syulacji
        message_display=0;
        
    end
end