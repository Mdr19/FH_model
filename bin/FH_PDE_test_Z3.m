clc
close all
clear all
warning('off')

%{
date='02_17';
k_1=0.000035308009951444;
k_2=0.000831923886697805;
elements_nr=15;
glass_vel=0.003096;
%}

%{
nowe
k_1=0.000034735233678004;
k_2=0.000813764203449597;
%}

sim_mode=1;
save_mode=0;

%stare
%FH_data.k_1=0.000035320876450;                   %0.000034735233678004;
%FH_data.k_2=0.012490048627167;                   %0.000813764203449597*15;

%{
%nowe
FH_data.k_1=0.000028383864091;
FH_data.k_2=0.011572321477212;

% dla Z3
FH_data.k_3=0.00006855419806339316;
FH_data.k_4=0.0007982832406319652;
%}

FH_data.k_1=0.000027935076328;
FH_data.k_2=0.011686309211677;
FH_data.k_3=0.000067270570993423;
FH_data.k_4=-0.000650946422108992;



%FH_data.k_1=0.000035320876450;                   %0.000034735233678004;
%FH_data.k_2=0.012490048627167;                   %0.000813764203449597*15;
FH_data.elements_nr=15/3; %/3;
%FH_data.glass_vel=0.003096;
FH_data.section_len=1;
FH_data.t_step=20;
FH_data.file_path='plikiCSV_Panevezys\FH11';
FH_data.section_name='Z3';

FH_data.Z3_input_signal_function_1_name='FH_Z3_ctrl_fnc_input_1(u,t)';
FH_data.Z3_input_signal_function_2_name='FH_Z3_ctrl_fnc_input_2(u,t)';

% 4 i 8

% 7 - spadek

data_set=7;

switch data_set
    case 1
        FH_data.sim_date='02_17';
        FH_data.start_index=5000;
        intervals_nr=50; %45;
    case 2
        FH_data.sim_date='01_24';
        FH_data.start_index=400;
        intervals_nr=50+4; %45;
    case 4
        FH_data.sim_date='04_23';
        FH_data.start_index=4500-500;
        intervals_nr=24; %24; %7; %28;
    case 5
        FH_data.sim_date='03_26';
        FH_data.start_index=27400;
        intervals_nr=32; %7; %28;
    case 6
        FH_data.sim_date='05_04';
        FH_data.start_index=6000;
        intervals_nr=30; %7; %28;
    case 7
        FH_data.sim_date='05_09';
        FH_data.start_index=61000;
        intervals_nr=30; %7; %28;
    case 8
        FH_data.sim_date='05_31';
        FH_data.start_index=27000+400;
        intervals_nr=30; %7; %28;
    case 9
        FH_data.sim_date='01_23';
        FH_data.start_index=27000;
        intervals_nr=30; %7; %28;
    case 15
        FH_data.sim_date='02_12';
        FH_data.start_index=26000;
        intervals_nr=40; %7; %28;
    case 16
        FH_data.sim_date='03_01';
        FH_data.start_index=16000;
        intervals_nr=30; %7; %28;
    case 18
        FH_data.sim_date='03_16';
        FH_data.start_index=25600;
        intervals_nr=30; %7; %28;
        
        
end

FH_data.inputs_nr=3;
FH_data.signals_names={'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV','FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'};



%forehearth_name={'FH11'};
file_path=FH_data.file_path;
sim_date=FH_data.sim_date;
start_time=FH_data.start_index;
temp_files_names={'Z1','Z1','Z2','Z3','Z4'};
variables_names={'WE_ZR_TEMP_PV','FH11_Z1_TEMP_PV','FH11_Z2C_TEMP_PV','FH11_Z3_TEMP_PV','FH11_Z4_TEMP_PV'};


for i=1:length(temp_files_names)
    temp(i)=MD_get_from_file(char(strcat(file_path,'\',sim_date,'\',temp_files_names(i),'.csv')) ,...
        variables_names(i),start_time,start_time,0,MD_constant_values.FH_message_display);
end

sections_len=[-2.0468 -1.0783 0 1 1.4643];
%start_index=5000;%+510;
%end_index=18000;

if sim_mode
    
    FH4_section_sim=FH_section_sim(FH_data);
    %FH4_section_sim.define_init_temp_function(temp,sections_len);
    FH4_section_sim.define_init_temp_function(temp(2:4),[-1.0783 0 1]);
    
    FH4_section_sim.init();
    
    cnt_start=FH_data.start_index;
    %interval=250;
    
else
    %load('FH4_section_sim_repo');
end

ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV'...
    'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,FH_data.file_path,MD_constant_values_Z3_short);


interval=MD_constant_values.T_sim;

%sim_params.FF_control=;
%sim_params_
sim_params.sim_mode=MD_constant_values.sim_mode;
sim_params.DC_mode=MD_constant_values.DC_mode;
sim_params.PULL_uncertain=MD_constant_values.PULL_uncertain;
sim_params.PULL_file_name='PULL_modified.csv';

tic
for i=1:intervals_nr
    
    if sim_mode
        FH4_section_sim.perform_simulation(cnt_start+i*interval,sim_params);
    end
    
    
    if i>1
        
        ident_section.define_interval_plant(FH4_section_sim,i);
        %ident_section.simulate_model_output_plant(FH4_section_sim,(i-1)*interval,i*interval-1);
        %ident_section.simulate_Strejc_model_output_plant(FH4_section_sim,(i-1)*interval,i*interval-1);
        
        %{
        ident_section.ident_model_plant(FH4_section_sim);
    
        % nowy OP
        %ident_section.ident_alternative_model_plant(FH4_section_sim);
        %ident_section.select_best_model();
        
        if ~isempty(ident_section.current_model) &&...
            ~isempty(ident_section.ident_models(ident_section.current_model_nr).intervals(end-1).interval_type)
            
            ident_section.ident_Strejc_model_plant(MD_constant_values.Strejc_rank_constraint);
            ident_section.ident_model_FF();
            FH_PID_tune_Strejc(ident_section);
            FH_get_DC_model(ident_section);
        end
        %}
    end
    %}
    
end
toc

FH4_section_sim.plot_results();
ident_section.plot_signals(123,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1);
%ident_section.plot_signals_Strejc(1);

%FH4_section_sim.get_signal(1,20,750)
%FH4_section_sim.perform_simulation(5500);6
%FH4_section_sim.perform_simulation(6000);
%FH4_section_sim.perform_simulation(6500);
%FH4_section_sim.perform_simulation(7500);

if sim_mode && save_mode
    save('FH4_section_sim_repo', 'FH4_section_sim');
end