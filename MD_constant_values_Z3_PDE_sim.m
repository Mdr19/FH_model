classdef MD_constant_values_Z3_PDE_sim
 properties (Constant)
        
        %% Ogólne parametry
        ident_message_display=0;
        G_length=10000;                  % w praktyce nie zmieniane uzywane tylko w procedurze MFM
        pull_signal_len=100;
        
        %% Wykresy dla reidentyfikacji
        plot_reident=0;
        plot_new_model=1;

        %% linearization
        threshold_lin=1e-1*0.2;          %1e-1*0.2 bylo dobrze   zwiekszone 5 razy 1e-1*0.3*10       11.05 bylo 1e-1*0.4*100
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
        init_model_intervals=6; %*2+2; % by³o 6
        new_model_intervals=4;           % by³o 4
        new_model_min_inputs=1;          % minimalna liczba wejsc z duzymi zmianami dla identyfikacji - bylo 1
        ident_intervals=4*2*2;           % by³o 16
        min_inputs_ident=2;              % minimalna liczba wejsæ dla modelu
        T_ob=MD_constant_values_Z3_PDE_sim.T_sim*2; % szerokœæ interwa³u obserwacji  %%!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych (2*250)
        T_sim=250;                                               % szerokoœæ interwa³u syulacji
        model_change_threshold=MD_constant_values_Z3.T_sim;     % próg od którego re-identyfikacja - bylo MD_constant_values.T_sim*0.2
        var_threshold=0.01;              % minimalna wariancja dla wejœcia    % bylo 0.01
        corr_threshold=0.5;
        change_model=1;                  % update modelu podczas symulacji
        model_reident=1;                 % re-identyfikacja modelu GS
        sum_sqr_difference=1;            % ró¿nica model-obiekt abs/sqr
        
        %sprawdznie interwa³ów (wariancja/korelacja)
        var_corr_method=1;               % 0 - var, 1 - corr
        
        %identyfikacja dla nowego punktu pracy
        alternative_model_method=1;            % 0 - nowy interwal zerowy pierwszy, 1 - nowy interwa³ zerowy w srodku
        
        %% opcje
        ident_method=2;             % dotyczy MFM - 1 eigenvector, others - ograniczenie liniowe
        initial_model_method=2;     % 1 - oryginalne, 2-LSM, 3 LSM out
        initial_state_method=1;     % 0 - symulacja , 1- obserwator
        ident_mode=1;               % 0 - separate models, 1 - single model for controlled inputs
        
        %% uncertain pull
        pull_uncertain=0;
        
        
        %% parametry dla metody GS
        sim_max_iters=10;          %10
        GS_max_iters=5;
        disp_message=0;
        method_exact_mode=0;      %0
        %GS_threshold=0.25;
        model_diff_par=1;
        diff_mode=0;
      
        %% Parametry dla identyfikowanych modeli
          %% Parametry dla identyfikowanych modeli
        ident_models_nr=5;                              % bylo 7

        ident_models1_N=5;
        ident_models1_M=6;
        ident_models1_h=150;
        ident_models1_n=1;
        ident_models1_m=4;                  %bylo 4
        ident_models1_eta=[1 1 1 1 1 1];
        
        ident_models2_N=5;
        ident_models2_M=6;
        ident_models2_h=100;            %!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych
        ident_models2_n=1;
        ident_models2_m=4;
        ident_models2_eta=[1 1 1 1 1 1];
        
        ident_models3_N=3;
        ident_models3_M=4;
        ident_models3_h=100;        %100
        ident_models3_n=1;
        ident_models3_m=3;
        ident_models3_eta=[1 1 1 1 1];
        
        ident_models4_N=3;
        ident_models4_M=4;
        ident_models4_h=150;         %25
        ident_models4_n=1;
        ident_models4_m=3;
        ident_models4_eta=[1 1 1 1 1];
        
        ident_models5_N=5;
        ident_models5_M=6;
        ident_models5_h=200;
        ident_models5_n=1;
        ident_models5_m=3;
        ident_models5_eta=[1 1 1 1 1];
        
        ident_models6_N=5;
        ident_models6_M=6;
        ident_models6_h=150;
        ident_models6_n=2;
        ident_models6_m=4;                  %bylo 4
        ident_models6_eta=[1 1 1 1 1 1 1];
        
        ident_models7_N=5;
        ident_models7_M=6;
        ident_models7_h=100;            %!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych
        ident_models7_n=2;
        ident_models7_m=4;
        ident_models7_eta=[1 1 1 1 1 1 1];
        
        ident_models8_N=3;
        ident_models8_M=4;
        ident_models8_h=100;        %100
        ident_models8_n=2;
        ident_models8_m=3;
        ident_models8_eta=[1 1 1 1 1 1];
        
        ident_models9_N=3;
        ident_models9_M=4;
        ident_models9_h=150;         %25
        ident_models9_n=2;
        ident_models9_m=3;
        ident_models9_eta=[1 1 1 1 1 1];
        
        ident_models10_N=5;
        ident_models10_M=6;
        ident_models10_h=200;
        ident_models10_n=2;
        ident_models10_m=3;
        ident_models10_eta=[1 1 1 1 1 1];
        
        
    end
end


%{
      ident_models1_N=3;
        ident_models1_M=4;
        ident_models1_h=250
        ident_models1_n=1;
        ident_models1_m=3;
        ident_models1_eta=[1 1 1 1 1];
        
        ident_models2_N=5;
        ident_models2_M=6;
        ident_models2_h=250;
        ident_models2_n=1;
        ident_models2_m=4;                  %bylo 4
        ident_models2_eta=[1 1 1 1 1 1];
        
        ident_models3_N=3;
        ident_models3_M=4;
        ident_models3_h=500;            %!!!!!!!!!!!!!!!!!! 500 dla rzeczywistych
        ident_models3_n=1;
        ident_models3_m=3;
        ident_models3_eta=[1 1 1 1 1];
        
        ident_models4_N=3;
        ident_models4_M=4;
        ident_models4_h=100;        %100
        ident_models4_n=1;
        ident_models4_m=3;
        ident_models4_eta=[1 1 1 1 1];
        
        ident_models5_N=5;
        ident_models5_M=6;
        ident_models5_h=100;         %25
        ident_models5_n=1;
        ident_models5_m=4;
        ident_models5_eta=[1 1 1 1 1 1];
%}