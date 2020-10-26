classdef MD_constant_values
    properties (Constant)
        %% forehearth parameters PDE
        FH_PDE_display=[ ];              % do rozwi�zywania PDE 1 dla wy�wietlania
        FH_message_display=0;            % do czytania z pliku - wy�wietlanie informacji diagnostycznych
        
        %% Parametry symulacji dla PDE
        sim_mode=0;                      % 0 - czytanie danych historycznych, 1 - symulacja z dzialaniem regulatora, 2 - tryb mieszany
        sim_mode_Z3=2;
        sim_mode_Z4=2;
        
        temp_poly_rank=2;                  % 4 pocz., potem 6
        
        %DC_mode=0;                       % dodatkowe sterowanie FF
        %PULL_uncertain=0;                % niepewno�� pomiaru wydobycia
        
        %% Strejc model ident params
        Strejc_ident_time=500*4;
        Strejc_signal_nr=2;
        Strejc_rank_constraint=0;        % Strejc model with the same rank as SS model 
        
        Kp=1.0;
        Ki=0.01;
               
        Kp_cln=30;
        Ki_cln=0.1;
        
        %% MPC model params
        
        %mpc_tau=0.1;
        
        %% Og�lne parametry
        T_sim=250;                                               % szeroko�� interwa�u syulacji
        message_display=0;
        
    end
end