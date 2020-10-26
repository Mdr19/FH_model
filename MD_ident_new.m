clc
clear all
close all
format long

warning('off','all');

T=MD_constant_values.T_sim; %1000


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1 - stale wydobycie
% 2 - male zmiany temp
% 3 - skok temp Z3
% 4 - skok temp Z4
% 5 - du¿e zmiany wydobycia
% 6 - stale wydobycie zanik gazu
% 7 - duzy spadek temp.
% 8 - duzy skok temp.
% 9 - duzy skok temp.

% 10 - s³abe ale opóŸnienia widoczne

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 12 - duzy skok temp. du¿a zmiana wyd.
% 13 - duzy skok temp. du¿a zmiana wyd.
% 14 - duzy apadek temp. bez zmian ciœnienia
% 15 - 3 wejœcia, s³abe wyniki
% 16 - duzy skok temp., s³abe wyniki
% 17 - duzy skok temp., sensowne wyniki
% 18 - du¿y spadek temp., sensowne wyniki

sim_data=17;

switch sim_data
    case 1
        filename='plikiCSV_Panevezys\FH11\02_17\Z4.csv';'rt'; % 20000 35000
        t_start=5000;
        t_end=16500;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename);
    case 2
        filename='plikiCSV_Panevezys\FH11\01_24\Z4.csv';'rt'; % 20000 35000
        t_start=4500;  %+16000;  %dla ostatninego fragmentu
        t_end=21150+4500;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 2.5
        filename='plikiCSV_Panevezys\FH11\01_24\Z3.csv';'rt'; % 20000 35000
        t_start=4000;  %+16000;  %dla ostatninego fragmentu
        t_end=21000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
        
    case 3
        filename='plikiCSV_Panevezys\FH11\04_23\Z3.csv';'rt'; % 20000 35000
        t_start=4000+500; %bylo 4000+500;
        t_end=11000;
        %,'FH11_Z3_CLN_VLV_POS_PV',...
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3); %2272
    case 4
        filename='plikiCSV_Panevezys\FH11\04_23\Z4.csv';'rt'; % 20000 35000
        t_start=4500;
        t_end=11000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
    case 5
        filename='plikiCSV_Panevezys\FH11\03_26\Z4.csv';'rt'; % 20000 35000
        t_start=27000;
        t_end=40000-5000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 5.5
        filename='plikiCSV_Panevezys\FH11\03_26\Z3.csv';'rt'; % 20000 35000
        t_start=27000-3500;
        t_end=40000-5000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4); %2272
        
    case 6
        filename='plikiCSV_Panevezys\FH11\05_04\Z4.csv';'rt'; % 20000 35000
        t_start=6000;
        t_end=15000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 7
        filename='plikiCSV_Panevezys\FH11\05_09\Z4.csv';'rt'; % 20000 35000
        t_start=61000;
        t_end=72000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 7.5
        filename='plikiCSV_Panevezys\FH11\05_09\Z3.csv';'rt'; % 20000 35000
        t_start=61000;
        t_end=72000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4); %2272
        
        
        
    case 8
        filename='plikiCSV_Panevezys\FH11\05_31\Z4.csv';'rt'; % 20000 35000
        t_start=27000;
        t_end=36000-2000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
    case 9
        filename='plikiCSV_Panevezys\FH11\01_23\Z4.csv';'rt'; % 20000 35000
        t_start=27000;
        t_end=31000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 9.5
        filename='plikiCSV_Panevezys\FH11\01_23\Z3.csv';'rt'; % 20000 35000
        t_start=27000;
        t_end=31000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
        
        %-------------------------------------------------------------------------------------
        
    case 10
        filename='plikiCSV_Panevezys\FH11\01_09\Z4.csv';'rt'; % 20000 35000
        t_start=37000+1250;
        t_end=50000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 11
        filename='plikiCSV_Panevezys\FH11\01_26\Z4.csv';'rt'; % 20000 35000
        t_start=37000;
        t_end=50000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 12
        filename='plikiCSV_Panevezys\FH11\01_29\Z3.csv';'rt'; % 20000 35000
        t_start=26000+1000+750;
        t_end=39000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
        
    case 13
        filename='plikiCSV_Panevezys\FH11\01_29\Z4.csv';'rt'; % 20000 35000
        t_start=26000+1000;
        t_end=43000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
    case 14
        filename='plikiCSV_Panevezys\FH11\02_12\Z4.csv';'rt'; % 20000 35000
        t_start=25000+1000+500;
        t_end=43000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 15
        filename='plikiCSV_Panevezys\FH11\02_12\Z3.csv';'rt'; % 20000 35000
        t_start=25000+1500;
        t_end=43000; %-6000;%-10000; %-12000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
        
    case 16
        filename='plikiCSV_Panevezys\FH11\03_01\Z3.csv';'rt'; % 20000 35000
        t_start=25000+2000;
        t_end=38000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
    case 17
        filename='plikiCSV_Panevezys\FH11\03_01\Z4.csv';'rt'; % 20000 35000
        t_start=16000;
        t_end=20000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
    case 18
        filename='plikiCSV_Panevezys\FH11\03_16\Z4.csv';'rt'; % 20000 35000
        t_start=16000+8000+1750;
        t_end=35000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        %-------------------------------------------------------------------------------------
        
    case 31
        filename='plikiCSV_Panevezys\FH11\05_31\Z3.csv';'rt'; % 20000 35000
        t_start=27000;
        t_end=36000-2000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
        
    case 32
        filename='plikiCSV_Panevezys\FH11\03_16\Z3.csv';'rt'; % 20000 35000
        t_start=16000+8000+1750;
        t_end=35000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 33
        filename='plikiCSV_Panevezys\FH11\01_18\Z4.csv';'rt'; % 20000 35000
        t_start=27000+1500;
        t_end=35000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 34
        filename='plikiCSV_Panevezys\FH11\01_18\Z3.csv';'rt'; % 20000 35000
        t_start=27000+1500;
        t_end=35000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 35
        filename='plikiCSV_Panevezys\FH11\03_22\Z3.csv';'rt'; % 20000 35000
        t_start=26500;
        t_end=35000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
        
    case 36
        filename='plikiCSV_Panevezys\FH11\03_22\Z4.csv';'rt'; % 20000 35000
        t_start=26500;
        t_end=35000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 41
        filename='plikiCSV_Panevezys\FH11\06_04\Z4.csv';'rt'; % 20000 35000
        t_start=40000;
        t_end=50000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 42
        filename='plikiCSV_Panevezys\FH11\06_04\Z3.csv';'rt'; % 20000 35000
        t_start=40000;
        t_end=50000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);        
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 43
        filename='plikiCSV_Panevezys\FH11\06_26\Z4.csv';'rt'; % 20000 35000
        t_start=28500;
        t_end=33500;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 44
        filename='plikiCSV_Panevezys\FH11\06_26\Z3.csv';'rt'; % 20000 35000
        t_start=28500;
        t_end=33500;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);        
        
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
   case 45
        filename='plikiCSV_Panevezys\FH11\17_08_30\Z4.csv';'rt'; % 20000 35000
        t_start=40500;
        t_end=40500+10000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 46
        filename='plikiCSV_Panevezys\FH11\17_08_30\Z3.csv';'rt'; % 20000 35000
        t_start=43000;
        t_end=40500+10000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);      
   
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
   case 47
        filename='plikiCSV_Panevezys\FH11\17_09_05\Z4.csv';'rt'; % 20000 35000
        t_start=26500;
        t_end=26500+10000;
        
        ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
            'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
        
        
    case 48
        filename='plikiCSV_Panevezys\FH11\17_09_05\Z3.csv';'rt'; % 20000 35000
           t_start=26500+250;
        t_end=26500+10000;
        
        ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
            'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);      

        
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnt=1;
cnt_file=t_start;
message=MD_constant_values.message_display;

tic

while 1
    
    %disp('--------------------------------------------------------------');
    %disp(['Interval start ' num2str(cnt) ' end ' num2str(cnt+T-1)])
    
    if cnt_file+T<t_end
        
        %ident_section.get_current_pull(cnt_file,cnt_file+T,message);
        
        ident_section.define_interval(cnt_file,cnt_file+T-1,message);
        ident_section.simulate_model_output(cnt_file,cnt_file+T-1);
        ident_section.ident_model();
        ident_section.ident_alternative_model();
        
        ident_section.select_best_model();
        
    else
        
        %ident_section.get_signals_from_file(filename,cnt_file,t_end,message);
        cnt_file,t_end
        ident_section.define_interval(cnt_file,t_end-1,message);
        ident_section.simulate_model_output(cnt_file,cnt_file+T-1);
        ident_section.ident_model();
        %ident_section.find_operating_point_interval();
        
        %ident_section.get_current_pull(cnt_file,cnt_file+T,message);
        
        %{
        ident_section.get_signals_from_file(filename,cnt_file,t_end,message);
        ident_section.define_intervals(cnt,t_end-t_start);
        
        ident_section.ident_model(cnt_file);
        %}
        
        %ident_section.find_operating_points(cnt1,cnt1+T);
        %get last interval
        %output=[output; MD_get_from_file('plikiCSV\06_05\FH61Z1_05_06.csv',...
        %    'FH61_Z1_TEMP_PV',cnt_file,t_end,0)];
        break;
    end
    
    cnt=cnt+T;
    cnt_file=cnt_file+T;
    
    
    %{
    for i=1:inputs_nr
        input_signals_current(i,:)=
    end
    %}
end

toc


%ident_section.plot_signals(cnt,{'Previous section temperature', 'Mixture pressure'},{'Temp. [$^\circ$C]','Press. [kPa]'},1,1,1);
ident_section.plot_signals(cnt,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [$\%$]'},1,1,1);