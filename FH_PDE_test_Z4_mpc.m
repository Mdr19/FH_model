clc
close all
clear all
warning('off')

global MPC_model

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

sample_time=10;
elements_nr=5;


% FH 3

% poprzednine
%{
FH3_data.k_1=0.000028383864091;
FH3_data.k_2=0.011572321477212;
FH3_data.k_3=0.000001360711208;
FH3_data.k_4=0.002548259469871;
%}

% 4 i 8

% 7 - spadek

data_set=8;

switch data_set
    case 1
        FH3_data.sim_date='02_17';
        FH3_data.start_index=5000;
        
        FH4_data.sim_date='02_17';
        FH4_data.start_index=5000;
        
        intervals_nr=50+15; %50;%+25; %45
    case 2
        FH_data.sim_date='01_24';
        FH_data.start_index=400;
        intervals_nr=50+4; %45;
    case 4
        %FH_data.sim_date='04_23';
        %FH_data.start_index=4500-500;
        %intervals_nr=24; %24; %7; %28;
        
        
        FH3_data.sim_date='04_23';
        FH3_data.start_index=4000;
        
        FH4_data.sim_date='04_23';
        FH4_data.start_index=4000;
        
        intervals_nr=24; %50;%+25; %45
        signals_len=7000;
        
    case 5
        FH_data.sim_date='03_26';
        FH_data.start_index=27400;
        intervals_nr=32; %7; %28;
    case 6
        FH_data.sim_date='05_04';
        FH_data.start_index=6000;
        intervals_nr=30; %7; %28;
    case 7
        %FH_data.sim_date='05_09';
        %FH_data.start_index=61000;
        %intervals_nr=30; %7; %28;
        
        FH3_data.sim_date='05_09';
        FH3_data.start_index=61000-1000;
        
        FH4_data.sim_date='05_09';
        FH4_data.start_index=61000-1000;
        
        intervals_nr=30+15-17; %+15; %50;%+25; %45
        signals_len=8000;
        
    case 8
        %FH_data.sim_date='05_31';
        %FH_data.start_index=27000+400;
        %intervals_nr=30; %7; %28;
        
        FH3_data.sim_date='05_31';
        FH3_data.start_index=27000;
        
        FH4_data.sim_date='05_31';
        FH4_data.start_index=27000;
        
        intervals_nr=24+4; %50;%+25; %45
        signals_len=7000;
        
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

MD_generate_signals_fnc(4,data_set,FH4_data.start_index,signals_len);

%{
FH3_data.k_1=0.000027935076328;
FH3_data.k_2=0.011686309211677;
FH3_data.k_3=0.000067270570993423;
FH3_data.k_4=-0.000650946422108992;

FH3_data.elements_nr=elements_nr; %/3;
FH3_data.section_len=1;
FH3_data.t_step=sample_time;
FH3_data.inputs_nr=3;
FH3_data.signals_names={'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV','FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'};
FH3_data.file_path='plikiCSV_Panevezys\FH11';
FH3_data.section_name='Z3';
FH3_data.Z3_input_signal_function_1='FH_Z3_ctrl_fnc_input_1(u,t)';
FH3_data.Z3_input_signal_function_2='FH_Z3_ctrl_fnc_input_2(u,t)';

FH3_data.pull_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.pull_saved_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.temp_SP_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.input_signal_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.temp_prev_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.temp_measured_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');

FH3_data.sim_mode=MD_constant_values.sim_mode_Z3;
FH3_data.pull_uncertain=MD_constant_values.pull_uncertain_Z3;
%}

% FH 4

% poprzednie
%{
FH4_data.k_1=0.000033192813737;
FH4_data.k_2=0.008788730063744;
%}

FH4_data.k_1=0.000033223648861;
FH4_data.k_2=0.008794579259217;

FH4_data.elements_nr=elements_nr; %/3;
FH4_data.section_len=1;
FH4_data.t_step=sample_time;
FH4_data.inputs_nr=2;
FH4_data.signals_names={'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV','FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'};
FH4_data.file_path='plikiCSV_Panevezys\FH11';
FH4_data.section_name='Z4';
FH4_data.Z4_input_signal_function='FH_Z4_ctrl_fnc_input(u,t)';

%FH4_data.pull_file=strcat(FH4_data.file_path,'\',FH4_data.sim_date,'\',FH4_data.section_name,'.csv');
%FH4_data.temp_SP_file=strcat(FH4_data.file_path,'\',FH4_data.sim_date,'\',FH4_data.section_name,'.csv');
FH4_data.pull_file='Z4_PULL_original.csv';
FH4_data.pull_saved_file='Z4_PULL_saved.csv';
FH4_data.temp_SP_file='Z4_temp_SP.csv';
FH4_data.input_signal_file=strcat(FH4_data.file_path,'\',FH4_data.sim_date,'\',FH4_data.section_name,'.csv');
FH4_data.temp_prev_file=strcat(FH4_data.file_path,'\',FH4_data.sim_date,'\',FH4_data.section_name,'.csv');
FH4_data.temp_measured_file=strcat(FH4_data.file_path,'\',FH4_data.sim_date,'\',FH4_data.section_name,'.csv');

FH4_data.sim_mode=MD_constant_values.sim_mode_Z4;
FH4_data.pull_uncertain=MD_constant_values.pull_uncertain_Z4;

%forehearth_name={'FH11'};
file_path=FH4_data.file_path;
sim_date=FH4_data.sim_date;
start_time=FH4_data.start_index;
temp_files_names={'Z1','Z1','Z2','Z3','Z4'};
variables_names={'WE_ZR_TEMP_PV','FH11_Z1_TEMP_PV','FH11_Z2C_TEMP_PV','FH11_Z3_TEMP_PV','FH11_Z4_TEMP_PV'};


for i=1:length(temp_files_names)
    temp(i)=MD_get_from_file(char(strcat(file_path,'\',sim_date,'\',temp_files_names(i),'.csv')) ,...
        variables_names(i),start_time,start_time,0,MD_constant_values.FH_message_display);
end

%sections_len_Z3=[-2.0468 -1.0783 0 1 1.4643];
sections_len_Z4=[-6.5412 -4.2190 -2.1536 0 1];

sections_len_=[0 1];

%start_index=5000;%+510;
%end_index=18000;

MPC_model.Z4=[];
MPC_model.Z4_new=[];

if sim_mode
    
    
    %FH3_section_sim=FH_section_sim(FH3_data);
    %FH3_section_sim.define_init_temp_function(temp,sections_len_Z3);
    %FH3_section_sim.define_init_temp_function(temp(2:4),[-1.0783 0 1]);
    %FH3_section_sim.init();
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    FH4_section_sim=FH_section_sim(FH4_data);
    %FH4_section_sim.define_init_temp_function(temp,sections_len_Z4);
    FH4_section_sim.define_init_temp_function(temp(3:5),[-2.1536 0 1]);
    FH4_section_sim.init();
    
    cnt_start=FH4_data.start_index;
    %interval=250;
    
else
    load('FH4_section_sim_repo');
end

zones_nr=1;
FH_sections=FH4_section_sim;
%FH_sections=[FH3_section_sim, FH4_section_sim];



%ident_section_Z3=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
%    'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,FH3_data.file_path,MD_constant_values_Z3_PDE_sim);

ident_section_Z4=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
    'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,FH4_data.file_path,MD_constant_values_Z4_PDE_sim);



interval=MD_constant_values.T_sim;

%sim_params.FF_control=;
%sim_params_
%sim_params.DC_mode=MD_constant_values.DC_mode;
%sim_params.PULL_uncertain=MD_constant_values.PULL_uncertain;
%sim_params.PULL_file_name='PULL_modified.csv';



%tic
tStart = clock;
for i=1:intervals_nr
    
    if sim_mode
        FH_sections(1).perform_simulation(cnt_start+i*interval);
        %FH_sections(2).perform_simulation(cnt_start+i*interval);
        %FH_sections(2).perform_simulation_multizone(cnt_start+i*interval,FH_sections(1));
    end
    
    ident_section_Z4.define_interval_plant(FH_sections(1),i);

    if i>3
        
        %{
        ident_section_Z3.define_interval_plant(FH_sections(1),i);
        ident_section_Z3.simulate_model_output_plant(FH_sections(1),(i-1)*interval,i*interval-1);
        ident_section_Z3.ident_model_plant(FH_sections(1));
        
        % nowy OP
        ident_section_Z3.ident_alternative_model_plant(FH_sections(1));
        ident_section_Z3.select_best_model();

        %------------------------------------------------------------------
        %}
        ident_section_Z4.simulate_model_output_plant(FH_sections(1),(i-1)*interval,i*interval-1);
        ident_section_Z4.ident_model_plant(FH_sections(1));
        
        % nowy OP
        ident_section_Z4.ident_alternative_model_plant(FH_sections(1));
        ident_section_Z4.select_best_model();
        
        if ~isempty(ident_section_Z4.current_model) &&...
                ~isempty(ident_section_Z4.ident_models(ident_section_Z4.current_model_nr).intervals(end-1).interval_type)
            
            if FH4_data.sim_mode==2
                ident_section_Z4.obtain_MPC_model(3,0.6,150/3,MD_constant_values.h_Z4);        %0.03 bylo N=3
                %FH_get_MPC_model(ident_section_Z4,'Z4');      
                FH_set_MPC_model(ident_section_Z4,'Z4');                     
            end
                
        elseif ~isempty(ident_section_Z4.MPC_model)
            %FH_update_state_MPC_model(ident_section_Z4,'Z4');
        end
        
    end
    %}
    
end

tEnd = clock;
disp(['Elapsed time is ' num2str(etime(tEnd,tStart)) ' s']);

%toc

FH_sections(1).plot_results(12);
%FH_sections(2).plot_results(13);

fig=figure(500);
fig.Color=[1 1 1];
for i=1:zones_nr
    if FH_sections(i).inputs_nr==2
        subplot(4,zones_nr,[i,zones_nr+i]);
        FH_sections(i).plot_inputs_multiplot()
        title(FH_sections(i).section_name);
    elseif FH_sections(i).inputs_nr==3
        title(FH_sections(i).section_name);
        subplot(4,zones_nr,i);
        FH_sections(i).plot_inputs_multiplot(1);
        title(FH_sections(i).section_name);
        subplot(4,zones_nr,zones_nr+i);
        FH_sections(i).plot_inputs_multiplot(2);
    end
    
    subplot(4,zones_nr,[2*zones_nr+i,3*zones_nr+i]);
    FH_sections(i).plot_results_multiplot();
end

%ident_section_Z3.plot_signals(122,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1);
ident_section_Z4.plot_signals(123,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1);
%ident_section.plot_signals_Strejc(1);

%FH4_section_sim.get_signal(1,20,750)
%FH4_section_sim.perform_simulation(5500);6
%FH4_section_sim.perform_simulation(6000);
%FH4_section_sim.perform_simulation(6500);
%FH4_section_sim.perform_simulation(7500);


if sim_mode && save_mode
    save('FH4_section_sim_repo', 'FH4_section_sim');
end