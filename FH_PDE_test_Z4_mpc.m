clc
close all
clear all
warning('off')

global MPC_model
global temp_zone_prev_inp
global temp_zone_prev_out

global time_horizon

sample_time=10;
elements_nr=5*2;

MPC_horizon=75;
T_p=250;
%time_horizon=250;

%MPC_model.Z4.T_p=MPC_horizon;

plot_str.font_size_1=30;     % 30
plot_str.font_size_2=25;     % 25
plot_str.lines_nr=2;
plot_str.offset_1=1;         % zero points
plot_str.offset_2=45;        % intervals sub.
plot_str.offset_3=500;       % initial int. sub.
plot_str.offset_4=5;         % gora
plot_str.offset_5=5;         % dol
plot_str.legend_loc=0;

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
        FH3_data.start_index=61000; %-1000
        
        FH4_data.sim_date='05_09';
        FH4_data.start_index=61000; %-1000
        
        intervals_nr=25; %+15; %50;%+25; %45
        signals_len=8000;
        
        plot_str.legend_loc=1;
        
    case 8
        %FH_data.sim_date='05_31';
        %FH_data.start_index=27000+400;
        %intervals_nr=30; %7; %28;
        
        FH3_data.sim_date='05_31';
        FH3_data.start_index=27000;
        
        FH4_data.sim_date='05_31';
        FH4_data.start_index=27000;
        
        intervals_nr=23; %+16; %+8; %50;%+25; %45
        signals_len=7000; %+4000;
        
    case 9
        FH_data.sim_date='01_23';
        FH_data.start_index=27000;
        intervals_nr=30; %7; %28;
        
    case 10
        % prezentacja
         FH3_data.sim_date='05_31';
        FH3_data.start_index=27000;
        
        FH4_data.sim_date='05_31';
        FH4_data.start_index=27000;
        
        intervals_nr=24+4; %50;%+25; %45
        signals_len=7000;
        
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
FH4_data.add_noise=MD_constant_values.add_noise;
FH4_data.snr=MD_constant_values.snr;
FH4_data.seed=5;

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FH4_section_sim=FH_section_sim(FH4_data);
%FH4_section_sim.define_init_temp_function(temp,sections_len_Z4);
FH4_section_sim.define_init_temp_function(temp(3:5),[-2.1536 0 1]);
FH4_section_sim.init();

cnt_start=FH4_data.start_index;
%interval=250;



zones_nr=1;
FH_sections=FH4_section_sim;


ident_section_Z4=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
    'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,FH4_data.file_path,MD_constant_values_Z4_PDE_sim);

interval=MD_constant_values.T_sim;
%prev_section_ctrl=MD_constant_values.Z4_prev_section_corr;

tStart = clock;
for i=1:intervals_nr
    
    if ~isempty(ident_section_Z4.MPC_model) && (FH4_data.sim_mode==3 || FH4_data.sim_mode==5)
        if ident_section_Z4.ident_models(end).inputs_to_ident(1)
            
            int_nr=1;
            
            prev_section_inp=FH_sections(1).get_signal(1,ident_section_Z4.signals_intervals(end).time_end_file-ident_section_Z4.signals_intervals(end).prev_section_del-int_nr*interval,...
            ident_section_Z4.signals_intervals(end).time_end_file-ident_section_Z4.signals_intervals(end).prev_section_del+interval)-ident_section_Z4.ident_models(end).offset_value(1);
        
            if FH4_data.sim_mode==3
                temp_zone_prev_inp=prev_section_inp(end-interval:end);
                MPC_model.Z4_eta_d=FH_define_prev_zone_eta(ident_section_Z4.MPC_model.Ap,ident_section_Z4.MPC_model.Lzerot,prev_section_inp(end-interval:end),T_p);
            elseif FH4_data.sim_mode==5
                %{
                X0=ident_section_Z4.current_initial_state(1,:);
                
                A=ident_section_Z4.current_model(1).A;
                C=zeros(1,size(A,1));
                C(end)=1;
                D=zeros(size(C,1),1);
                
                if length(ident_section_Z4.current_model)==1
                    B=ident_section_Z4.current_model.B(:,1);   
                else
                    B=ident_section_Z4.current_model(1).B;    
                end
                %}
                %temp_zone_prev=lsim(ss(A,B,C,D),prev_section_inp(end-interval:end),0:interval,X0);
                %temp_zone_prev_out=interp1(0:interval,temp_zone_prev,0:ident_section_Z4.MPC_model.h:interval);
                
                %temp_zone_prev_inp=prev_section_inp(end-interval:end);
                
                temp_zone_prev_inp=interp1(0:interval,prev_section_inp(end-interval:end),0:ident_section_Z4.MPC_model.h:interval);
                
                %eta_d=FH_calc_prev_zone_eta(MPC_model.Z4.A,MPC_model.Z4.Bd,h,MPC_model.Z4.X0,MPC_model.Z4.Ap,MPC_model.Z4.Lzerot,MPC_model.Z4.phi,MPC_model.Z4.phi_d,t,time_horizon,temp_zone_prev_inp);

                
                %FH_define_prev_zone_eta(MPC_model.Z4.Ap,MPC_model.Z4.Lzerot,signal,T_p)
            end
        else
            temp_zone_prev_out=[];
        end
    end
    
    FH_sections(1).perform_simulation(cnt_start+i*interval);
    ident_section_Z4.define_interval_plant(FH_sections(1),i);
    
    if i>3
        
        
        ident_section_Z4.simulate_model_output_plant(FH_sections(1),(i-1)*interval,i*interval-1);
        
        if isempty(ident_section_Z4.current_model) || FH_sections(1).get_last_SP_diff(MD_constant_values.model_diff_intervals)>MD_constant_values.new_OP_diff
            ident_section_Z4.ident_model_plant(FH_sections(1));
        end
        
        if FH_sections(1).get_last_SP_diff(MD_constant_values.model_diff_intervals)>MD_constant_values.new_OP_diff
            ident_section_Z4.ident_alternative_model_plant(FH_sections(1));
            ident_section_Z4.select_best_model();
        end
            
        if ~isempty(ident_section_Z4.current_model) &&...
                ((~isempty(ident_section_Z4.ident_models(ident_section_Z4.current_model_nr).intervals(end-1).interval_type) &&...
                ident_section_Z4.ident_models(ident_section_Z4.current_model_nr).intervals(end-1).interval_type=='I') ||...
                (~isempty(ident_section_Z4.ident_models(ident_section_Z4.current_model_nr).intervals(end).interval_type) &&...
                ident_section_Z4.ident_models(ident_section_Z4.current_model_nr).intervals(end).interval_type=='R'))
            
            if FH4_data.sim_mode==2
                 ident_section_Z4.obtain_MPC_model(5,0.6,MPC_horizon,MD_constant_values.h_Z4);        %0.03 bylo N=3
                FH_set_MPC_model(ident_section_Z4,'Z4');
            elseif FH4_data.sim_mode==3 
                ident_section_Z4.obtain_MPC_model_FF(5,0.6,MPC_horizon,MD_constant_values.h_Z4);        %0.03 bylo N=3
                FH_set_MPC_model_FF(ident_section_Z4,'Z4');
            elseif FH4_data.sim_mode==4
                 ident_section_Z4.obtain_DMPC_model(sample_time,5,50);        %0.03 bylo N=3      50 i 100       100 i 150
                 FH_set_DMPC_model(ident_section_Z4,'Z4');
            elseif FH4_data.sim_mode==5
                 ident_section_Z4.obtain_DMPC_model_FF(sample_time,5,20);        %0.03 bylo N=3      50 i 100       100 i 150
                 FH_set_DMPC_model(ident_section_Z4,'Z4');

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
        FH_sections(i).plot_inputs_multiplot(1,1,interval);
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

%ident_section_Z4.plot_signals(123,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1,plot_str);
%ident_section_Z4.plot_signals_praca(123,{'Temperatura w poprzedniej sekcji', 'Cisnienie mieszanki','Pozycja zaworu chlodzenia'},{'Temp. [$^\circ$C]','Cisn. [kPa]','Poz. [$\%$]'},1,0,0,plot_str);
ident_section_Z4.plot_signals_MMAR(124,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,plot_str,FH_sections(1));

ident_section_Z4.plot_output_praca(123,1,plot_str);
ident_section_Z4.plot_inputs_praca(125,{'Temperatura w poprzedniej sekcji', 'Cisnienie mieszanki','Pozycja zaworu chlodzenia'},{'Temp. [$^\circ$C]','Cisn. [kPa]','Poz. [$\%$]'},...
    1,0,plot_str,FH_sections(1),MD_constant_values.T_sim,MD_constant_values.Z4_model_delay);

ident_section_Z4.plot_eigenvalues(plot_str);
%ident_section_Z4.calculate_MSE()
FH_sections(1).get_SP_diff;


fig=figure(500);
fig.Color=[1 1 1];
for i=1:zones_nr
    if FH_sections(i).inputs_nr==2
        subplot(4,zones_nr,[i,zones_nr+i]);
        FH_sections(i).plot_inputs_multiplot(1,1,interval);
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

%ident_section_Z4.plot_signals(123,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [%]'},1,1,1,plot_str);
%ident_section_Z4.plot_signals_praca(123,{'Temperatura w poprzedniej sekcji', 'Cisnienie mieszanki','Pozycja zaworu chlodzenia'},{'Temp. [$^\circ$C]','Cisn. [kPa]','Poz. [$\%$]'},1,0,0,plot_str);
%ident_section_Z4.plot_eigenvalues(plot_str);