classdef MD_constant_values
    properties (Constant)
        %% forehearth parameters PDE
        FH_PDE_display=[ ];              % do rozwi¹zywania PDE 1 dla wyœwietlania
        FH_message_display=0;            % do czytania z pliku - wyœwietlanie informacji diagnostycznych
        
        %% Parametry symulacji dla PDE
        sim_mode=1;                      % 0 - czytanie danych historycznych, 1 - symulacja z dzialaniem regulatora, 2 - tryb mieszany
        DC_mode=1;                       % dodatkowe sterowanie FF
        PULL_uncertain=0;                % niepewnoœæ pomiaru wydobycia
        
        %% Strejc model ident params
        Strejc_ident_time=500*4;
        Strejc_signal_nr=2;
        Strejc_rank_constraint=0;        % Strejc model with the same rank as SS model 
        
        Kp=0.5;
        Ki=0.001;
               
        %% MPC model params
        
        
        %% Ogólne parametry
        ident_message_display=0;
        G_length=10000;                  % w praktyce nie zmieniane uzywane tylko w procedurze MFM
        pull_signal_len=100;

        %% linearization
        threshold_lin=1e-1*0.4;          %1e-1*0.2 bylo dobrze   zwiekszone 5 razy 1e-1*0.3*10       11.05 bylo 1e-1*0.4*100
        mean_interval_lin=100;
        h_lin=50;
        MFM_step=1;
        cn_lin=100;
        m_lin=4;
        N_lin=4;
        M_lin=5;
        min_op_diff=6;                   % minimalny przedzia³ pomiêdzy dwoma linearyzacjami
        
        %% signals plot
        plot_offset1=400;
        plot_offset2=250;
        font_size=25;
        message_display=0;
        
        %% identification params
        init_model_intervals=4+2+2; %*2+2; % by³o 6
        new_model_intervals=4;           % by³o 4
        new_model_min_inputs=1;          % minimalna liczba wejsc z duzymi zmianami dla identyfikacji
        ident_intervals=4*2*2;           % by³o 16
        min_inputs_ident=2;              % minimalna liczba wejsæ dla modelu
        T_ob=MD_constant_values.T_sim*2; % szerokœæ interwa³u obserwacji  %%!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych (2*250)
        T_sim=250;                                               % szerokoœæ interwa³u syulacji
        model_change_threshold=MD_constant_values.T_sim*0.2;     % próg od którego re-identyfikacja - bylo MD_constant_values.T_sim*0.2
        var_threshold=0.01;              % minimalna wariancja dla wejœcia    % bylo 0.01
        change_model=0;                  % update modelu podczas symulacji
        model_reident=1;                 % re-identyfikacja modelu GS
        sum_sqr_difference=1;            % ró¿nica model-obiekt abs/sqr
        
        %identyfikacja dla nowego punktu pracy
        alternative_model_method=1;            % 0 - nowy interwal zerowy pierwszy, 1 - nowy interwa³ zerowy w srodku
        
        % opcje
        ident_method=2;             % dotyczy MFM - 1 eigenvector, others - ograniczenie liniowe
        initial_model_method=2;     % 1 - oryginalne, 2-LSM, 3 LSM out
        initial_state_method=1;     % 0 - symulacja , 1- obserwator
        ident_mode=7;               % 1 -, 2 -, 3- LSM model single 4- LSM model GS 5-LSM model GS 2 6- LSM mode GS popr
                                    % 7 - LSM mode GS nowe
        
        %% parametry dla metody GS
        sim_max_iters=10;          %10
        GS_max_iters=5;
        disp_message=1;
        method_exact_mode=0;      %0
        GS_threshold=0.25;
        model_diff_par=1;
        constraints=1;
        diff_mode=0;
      
        %% Parametry dla identyfikowanych modeli
        ident_models_nr=7;

        ident_models1_N=3;
        ident_models1_M=4;
        ident_models1_h=50
        ident_models1_n=1;
        ident_models1_m=3;
        ident_models1_eta=[1 1 1 1 1];
        
        ident_models2_N=5;
        ident_models2_M=6;
        ident_models2_h=150;
        ident_models2_n=1;
        ident_models2_m=4;                  %bylo 4
        ident_models2_eta=[1 1 1 1 1 1];
        
        ident_models3_N=5;
        ident_models3_M=6;
        ident_models3_h=500;            %!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych
        ident_models3_n=1;
        ident_models3_m=4;
        ident_models3_eta=[1 1 1 1 1 1];
        
        ident_models4_N=3;
        ident_models4_M=4;
        ident_models4_h=100;        %100
        ident_models4_n=1;
        ident_models4_m=3;
        ident_models4_eta=[1 1 1 1 1];
        
        ident_models5_N=3;
        ident_models5_M=4;
        ident_models5_h=750;         %25
        ident_models5_n=1;
        ident_models5_m=3;
        ident_models5_eta=[1 1 1 1 1];
        
        ident_models6_N=3;
        ident_models6_M=4;
        ident_models6_h=50;
        ident_models6_n=1;
        ident_models6_m=4;
        ident_models6_eta=[1 1 1 1 1 1];
        
        ident_models7_N=5;
        ident_models7_M=6;
        ident_models7_h=35;
        ident_models7_n=1;
        ident_models7_m=3;
        ident_models7_eta=[1 1 1 1 1];
        
        %{
        ident_models3_N=6;
        ident_models3_M=7;
        ident_models3_h=35;
        ident_models3_n=1;
        ident_models3_m=4;
        %}
        
    end
end

% OLD PARAMS
%{
        ident_models_nr=7;

        ident_models1_N=3;
        ident_models1_M=4;
        ident_models1_h=50
        ident_models1_n=1;
        ident_models1_m=3;
        ident_models1_eta=[1 1 1 1 1];
        
        ident_models2_N=5;
        ident_models2_M=6;
        ident_models2_h=150;
        ident_models2_n=1;
        ident_models2_m=4;
        ident_models2_eta=[1 1 1 1 1 1];
        
        ident_models3_N=5;
        ident_models3_M=6;
        ident_models3_h=200;            %!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych
        ident_models3_n=1;
        ident_models3_m=4;
        ident_models3_eta=[1 1 1 1 1 1];
        
        ident_models4_N=3;
        ident_models4_M=4;
        ident_models4_h=100;        %100
        ident_models4_n=1;
        ident_models4_m=3;
        ident_models4_eta=[1 1 1 1 1];
        
        ident_models5_N=3;
        ident_models5_M=4;
        ident_models5_h=750;         %25
        ident_models5_n=1;
        ident_models5_m=3;
        ident_models5_eta=[1 1 1 1 1];
        
        ident_models6_N=3;
        ident_models6_M=4;
        ident_models6_h=500;
        ident_models6_n=1;
        ident_models6_m=3;
        ident_models6_eta=[1 1 1 1 1];
        
        ident_models7_N=5;
        ident_models7_M=6;
        ident_models7_h=50;
        ident_models7_n=1;
        ident_models7_m=4;
        ident_models7_eta=[1 1 1 1 1 1];
        %{
        ident_models3_N=6;
        ident_models3_M=7;
        ident_models3_h=35;
        ident_models3_n=1;
        ident_models3_m=4;
        %}
%}