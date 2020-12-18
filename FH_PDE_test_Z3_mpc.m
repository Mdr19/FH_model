clc
close all
clear all
warning('off')

global MPC_model

%stare
%FH_data.k_1=0.000035320876450;                   %0.000034735233678004;
%FH_data.k_2=0.012490048627167;                   %0.000813764203449597*15;

sample_time=10;
elements_nr=5;

plot_str.font_size_1=25;
plot_str.font_size_2=20;
plot_str.lines_nr=2;
plot_str.offset_1=1;         % zero points
plot_str.offset_2=45;        % intervals sub.
plot_str.offset_3=500;       % initial int. sub.
plot_str.offset_4=5;         % gora
plot_str.offset_5=5;         % dol
plot_str.legend_loc=0;

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

data_set=7;

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
        FH3_data.start_index=61000;
        
        FH4_data.sim_date='05_09';
        FH4_data.start_index=61000;
        
        intervals_nr=30-3; %+15; %50;%+25; %45
        signals_len=10000;
        plot_str.legend_loc=1;
        
        
    case 8
        %FH_data.sim_date='05_31';
        %FH_data.start_index=27000+400;
        %intervals_nr=30; %7; %28;
        
        FH3_data.sim_date='05_31';
        %FH3_data.start_index=27000+1000;
        FH3_data.start_index=27000;
        
        
        FH4_data.sim_date='05_31';
        %FH4_data.start_index=27000+1000;
        
        intervals_nr=24+4; %50;%+25; %45  -12
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

MD_generate_signals_fnc(3,data_set,FH3_data.start_index,signals_len);

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

%FH3_data.pull_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
%FH3_data.pull_saved_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');

%FH3_data.temp_SP_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.pull_file='Z3_PULL_original.csv';
FH3_data.pull_saved_file='Z3_PULL_saved.csv';
FH3_data.temp_SP_file='Z3_temp_SP.csv';
FH3_data.input_signal_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.temp_prev_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');
FH3_data.temp_measured_file=strcat(FH3_data.file_path,'\',FH3_data.sim_date,'\',FH3_data.section_name,'.csv');

FH3_data.sim_mode=MD_constant_values.sim_mode_Z3;
FH3_data.pull_uncertain=MD_constant_values.pull_uncertain_Z3;
FH3_data.add_noise=MD_constant_values.add_noise;
FH3_data.snr=MD_constant_values.snr;
FH3_data.seed=5;

%forehearth_name={'FH11'};
file_path=FH3_data.file_path;
sim_date=FH3_data.sim_date;
start_time=FH3_data.start_index;
temp_files_names={'Z1','Z1','Z2','Z3','Z4'};
variables_names={'WE_ZR_TEMP_PV','FH11_Z1_TEMP_PV','FH11_Z2C_TEMP_PV','FH11_Z3_TEMP_PV','FH11_Z4_TEMP_PV'};


for i=1:length(temp_files_names)
    temp(i)=MD_get_from_file(char(strcat(file_path,'\',sim_date,'\',temp_files_names(i),'.csv')) ,...
        variables_names(i),start_time,start_time,0,MD_constant_values.FH_message_display);
end

sections_len_Z3=[-2.0468 -1.0783 0 1 1.4643];
%sections_len_Z4=[-6.5412 -4.2190 -2.1536 0 1];

sections_len_=[0 1];

%start_index=5000;%+510;
%end_index=18000;

MPC_model.Z3=[];
MPC_model.Z3_new=[];




FH3_section_sim=FH_section_sim(FH3_data);
%FH3_section_sim.define_init_temp_function(temp,sections_len_Z3);
FH3_section_sim.define_init_temp_function(temp(2:4),[-1.0783 0 1]);
FH3_section_sim.init();

cnt_start=FH3_data.start_index;



zones_nr=1;
FH_sections=FH3_section_sim;
%FH_sections=[FH3_section_sim, FH4_section_sim];



ident_section_Z3=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
    'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,FH3_data.file_path,MD_constant_values_Z3_PDE_sim);
interval=MD_constant_values.T_sim;


tStart = clock;
for i=1:intervals_nr
    
    FH_sections(1).perform_simulation(cnt_start+i*interval);
    %FH_sections(2).perform_simulation(cnt_start+i*interval);
    %FH_sections(2).perform_simulation_multizone(cnt_start+i*interval,FH_sections(1));
    
    ident_section_Z3.define_interval_plant(FH_sections(1),i);
    ident_section_Z3.simulate_model_output_plant(FH_sections(1),(i-1)*interval,i*interval-1);
    ident_section_Z3.ident_model_plant(FH_sections(1));
    
    % nowy OP
    if FH_sections(1).get_last_SP_diff(4)>MD_constant_values.new_OP_diff %&& 0==1
        ident_section_Z3.ident_alternative_model_plant(FH_sections(1));
        ident_section_Z3.select_best_model();
    end
    
    if ~isempty(ident_section_Z3.current_model) &&...
                ((~isempty(ident_section_Z3.ident_models(ident_section_Z3.current_model_nr).intervals(end-1).interval_type) &&...
                ident_section_Z3.ident_models(ident_section_Z3.current_model_nr).intervals(end-1).interval_type=='I') ||...
                (~isempty(ident_section_Z3.ident_models(ident_section_Z3.current_model_nr).intervals(end).interval_type) &&...
                ident_section_Z3.ident_models(ident_section_Z3.current_model_nr).intervals(end).interval_type=='R'))
        
        %ident_section_Z3.obtain_MPC_model(0.03);        %bylo 0.03
        ident_section_Z3.obtain_MPC_model(5,0.6,150/2,MD_constant_values.h_Z3);        %0.03
        %FH_get_MPC_model(ident_section_Z3,'Z3');
        FH_set_MPC_model(ident_section_Z3,'Z3',0);
        
        
    elseif ~isempty(ident_section_Z3.MPC_model)
        %FH_update_state_MPC_model(ident_section_Z3,'Z3');
    end
    
    
end
%toc
tEnd = clock;
disp(['Elapsed time is ' num2str(etime(tEnd,tStart)) ' s']);


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
        FH_sections(i).plot_inputs_multiplot(1,1,interval);
        title(FH_sections(i).section_name);
        subplot(4,zones_nr,zones_nr+i);
        FH_sections(i).plot_inputs_multiplot(2,1,interval);
    end
    
    subplot(4,zones_nr,[2*zones_nr+i,3*zones_nr+i]);
    FH_sections(i).plot_results_multiplot();
end

ident_section_Z3.plot_signals(123,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1,plot_str);
ident_section_Z3.plot_eigenvalues(plot_str);