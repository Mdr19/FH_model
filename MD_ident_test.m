clc
clear all
close all
format long

%warning('off','all');

T=MD_constant_values.T_sim; %1000

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% strojenie

% 0 - 02.17     - problem obs. 1. interwa³ dla Z4

% skok

% 101 - 04.23    - OK dla Z4, OK dla Z3
% 102 - 05.31    - OK dla Z4, BAD dla Z3 (Z4 - problem dla nowego zestawu modeli)
% 103 - 06.26    - BAD dla Z4, OK dla Z3 (Z4 - problem dla nowego zestawu modeli, krótki czas sterowania Z3)
% 104 - 01.23    - OK dla Z4, OK dla Z3
% 105 - 03.01    - OK dla Z4, BAD dla Z3  (kilkukrotny skok 2. art)
% 106 - 17.09.27 - OK dla Z4, BAD dla Z3 (zmiana wydobycia dla Z4 niewidoczna)
% 107 - 01.04    - OK dla Z4, BAD dla Z3 (dla Z4 przyk³ad na dziwne zachowanie - temp. spada mimo ciœnienia, nie do identyfikacji - za krótkie, FH12)
% 108 - 02.23    - OK dla Z4, (Z4 - nowy zestaw modeli)
% 109 - 05.18    - OK dla Z4, (Z4 - nowy zestaw modeli, FH12)
% 110 - 17.08.15 - OK dla Z4,
% 111 - 04.09    - OK dla Z4 (Z4 - nowy zestaw modeli bardzo krótki przedzia³, FH 12)

% spadek

% 201 - 02.12    - OK dla Z4 (BAD dla Z4 new), , (Z4 - tylko jeden model, problem dla nowego zestawu)
% 202 - 03.16    - OK dla Z4, OK dla Z3
% 203 - 03.22    - BAD dla Z4, (praktycznie bez sterowania dla Z4, w miare dobrze dla nowego zestawu modeli Z4)
% 204 - 05.09    - OK dla Z4, OK dla Z3
% 205 - 06.04    - OK dla Z4, OK dla Z3
% 206 - 17.09.05 - BAD dla Z4, (brak sterowania Z4)
% 207 - 17.10.10 - OK dla Z4 new,
% 208 - 17.11.07 - OK dla Z4 new,
% 209 - 04.02    - BAD dla Z4 new (FH 12)
% 210 - 02.28    - OK dla Z4 new, (dla Z4 praktycznie bez sterowania, FH 12)

% inne

% 501 - 01.24    - ma³e zmiany skok/spadek - OK dla Z3
% 502 - 03.26    - ma³e zmiany skok - OK dla Z4 nowe, BAD dla Z3
% 503 - 05.04    - zanik gazu - BAD dla Z4 nowe
% 504 - 08.30.17 - skok nieudane - BAD dla Z4 nowe, OK w miare dla Z3
% 505 - 17.10.24 - skoki nieudane, BAD dla Z4 new,


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

section_nr=3;           % 3 lub 4
data_nr=106;

if section_nr==3
    
    switch data_nr
        
        %% STROJENIE
        case 0
            filename='plikiCSV_Panevezys\FH11\02_17\Z3.csv';'rt'; % 20000 35000
            t_start=5000;
            t_end=16500;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
            
            %% SKOKI
        case 101
            
            filename='plikiCSV_Panevezys\FH11\04_23\Z3.csv';'rt'; % 20000 35000
            t_start=4500;
            t_end=11000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 102
            
            filename='plikiCSV_Panevezys\FH11\05_31\Z3.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=36000-2000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 103
            
            filename='plikiCSV_Panevezys\FH11\06_26\Z3.csv';'rt'; % 20000 35000
            t_start=28500-500;
            t_end=33500;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
            
        case 104
            
            filename='plikiCSV_Panevezys\FH11\01_23\Z3.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=31000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
            
            
        case 105
            
            filename='plikiCSV_Panevezys\FH11\03_01\Z3.csv';'rt'; % 20000 35000
            t_start=27000-500;
            t_end=35000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 106
            
            filename='plikiCSV_Panevezys\FH11\17_09_27\Z3.csv';'rt'; % 20000 35000
            t_start=27000+250; %+500;
            t_end=33000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 107
            
            filename='plikiCSV_Panevezys\FH12\01_04\Z3.csv';'rt'; % 20000 35000
            t_start=32000+500;
            t_end=35000;
            
            ident_section=MD_ident_section(3,{'FH12_Z2C_TEMP_PV','FH12_Z3_MIX_PRES_PV','FH12_Z3_CLN_VLV_POS_PV',...
                'FH12_Z3_TEMP_PV','FH12_Z3_TEMP_SP','FH12_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 108
            
            filename='plikiCSV_Panevezys\FH12\02_23\Z3.csv';'rt'; % 20000 35000
            t_start=29000+1500;
            t_end=42000;
            
            ident_section=MD_ident_section(3,{'FH12_Z2C_TEMP_PV','FH12_Z3_MIX_PRES_PV','FH12_Z3_CLN_VLV_POS_PV',...
                'FH12_Z3_TEMP_PV','FH12_Z3_TEMP_SP','FH12_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
            
            
        case 109
            
            filename='plikiCSV_Panevezys\FH12\05_18\Z3.csv';'rt'; % 20000 35000
            t_start=27000;%-500;
            t_end=34000;
            
            ident_section=MD_ident_section(3,{'FH12_Z2C_TEMP_PV','FH12_Z3_MIX_PRES_PV','FH12_Z3_CLN_VLV_POS_PV',...
                'FH12_Z3_TEMP_PV','FH12_Z3_TEMP_SP','FH12_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 110
            
            filename='plikiCSV_Panevezys\FH11\17_08_15\Z3.csv';'rt'; % 20000 35000
            t_start=48500;
            t_end=53000;
            
            ident_section=MD_ident_section(3,{'FH12_Z2C_TEMP_PV','FH12_Z3_MIX_PRES_PV','FH12_Z3_CLN_VLV_POS_PV',...
                'FH12_Z3_TEMP_PV','FH12_Z3_TEMP_SP','FH12_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
            
            
        case 111
            
            filename='plikiCSV_Panevezys\FH12\04_09\Z3.csv';'rt'; % 20000 35000
            t_start=4000;
            t_end=10000;
            
            ident_section=MD_ident_section(3,{'FH12_Z2C_TEMP_PV','FH12_Z3_MIX_PRES_PV','FH12_Z3_CLN_VLV_POS_PV',...
                'FH12_Z3_TEMP_PV','FH12_Z3_TEMP_SP','FH12_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z4);
            
            
            
            %% SPADKI
        case 201
            
            filename='plikiCSV_Panevezys\FH11\02_12\Z3.csv';'rt'; % 20000 35000
            t_start=25000+1000+500;
            t_end=43000;%-5000; %-10000
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 202
            filename='plikiCSV_Panevezys\FH11\03_16\Z3.csv';'rt';
            t_start=16000+8000+1750;
            t_end=34000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 203
            filename='plikiCSV_Panevezys\FH11\03_22\Z3.csv';'rt'; % 20000 35000
            t_start=26500;
            t_end=35000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 204
            filename='plikiCSV_Panevezys\FH11\05_09\Z3.csv';'rt'; % 20000 35000
            t_start=61000;
            t_end=72000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 205
            
            filename='plikiCSV_Panevezys\FH11\06_04\Z3.csv';'rt'; % 20000 35000
            t_start=40000;
            t_end=50000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 206
            
            filename='plikiCSV_Panevezys\FH11\17_09_05\Z3.csv';'rt'; % 20000 35000
            t_start=26500;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 207
            
            filename='plikiCSV_Panevezys\FH11\17_10_10\Z3.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 208
            
            filename='plikiCSV_Panevezys\FH11\17_11_07\Z3.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 209
            
            filename='plikiCSV_Panevezys\FH12\04_02\Z3.csv';'rt'; % 20000 35000
            t_start=25500;
            t_end=35000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 210
            
            filename='plikiCSV_Panevezys\FH12\02_28\Z3.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=35000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
            
            
            
            %% INNE
            
        case 501
            
            filename='plikiCSV_Panevezys\FH11\01_24\Z3.csv';'rt'; % 20000 35000
            t_start=4500;  %+16000;  %dla ostatninego fragmentu
            t_end=21150+4500;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 502
            
            filename='plikiCSV_Panevezys\FH11\03_26\Z3.csv';'rt'; % 20000 35000
            t_start=27000+500;
            t_end=40000-5000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
            
        case 503
            
            filename='plikiCSV_Panevezys\FH11\05_04\Z3.csv';'rt'; % 20000 35000
            t_start=6000;
            t_end=15000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        case 504
            
            filename='plikiCSV_Panevezys\FH11\17_08_30\Z3.csv';'rt'; % 20000 35000
            t_start=40500;
            t_end=40500+10000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3);
            
        
        case 505
            
            filename='plikiCSV_Panevezys\FH11\17_10_24\Z3.csv';'rt'; % 20000 35000
            t_start=27000+250;
            t_end=40000;
            
            ident_section=MD_ident_section(3,{'FH11_Z2C_TEMP_PV','FH11_Z3_MIX_PRES_PV','FH11_Z3_CLN_VLV_POS_PV',...
                'FH11_Z3_TEMP_PV','FH11_Z3_TEMP_SP','FH11_PULL'},[0.0344 1.236],2272,filename,MD_constant_values_Z3_short);
                   
    end
    
elseif section_nr==4
    
    switch(data_nr)
        
        %% STROJENIE
        
        case 0
            filename='plikiCSV_Panevezys\FH11\02_17\Z4.csv';'rt'; % 20000 35000
            t_start=5000;
            t_end=16500;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            %% SKOKI
            
        case 101
            
            filename='plikiCSV_Panevezys\FH11\04_23\Z4.csv';'rt'; % 20000 35000
            t_start=4500;
            t_end=11000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
        case 102
            
            filename='plikiCSV_Panevezys\FH11\05_31\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=36000-2000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
        case 103
            
            filename='plikiCSV_Panevezys\FH11\06_26\Z4.csv';'rt'; % 20000 35000
            t_start=28500;
            t_end=33500;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
        case 104
            
            filename='plikiCSV_Panevezys\FH11\01_23\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=31000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
        case 105
            
            filename='plikiCSV_Panevezys\FH11\03_01\Z4.csv';'rt'; % 20000 35000
            t_start=16000;
            t_end=20000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 106
            
            filename='plikiCSV_Panevezys\FH11\17_09_27\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=33000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 107
            
            filename='plikiCSV_Panevezys\FH12\01_04\Z4.csv';'rt'; % 20000 35000
            t_start=32000-500;
            t_end=35000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 108
            
            filename='plikiCSV_Panevezys\FH12\02_23\Z4.csv';'rt'; % 20000 35000
            t_start=29000+1000;
            t_end=42000-3000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 109
            
            filename='plikiCSV_Panevezys\FH12\05_18\Z4.csv';'rt'; % 20000 35000
            t_start=27000-500; %-250;%-500;
            t_end=34000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 110
            
            filename='plikiCSV_Panevezys\FH11\17_08_15\Z4.csv';'rt'; % 20000 35000
            t_start=48500;
            t_end=53000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
        case 111
            
            filename='plikiCSV_Panevezys\FH12\04_09\Z4.csv';'rt'; % 20000 35000
            t_start=4000;
            t_end=10000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
            
            
            
            
            %% SPADKI
            
        case 201
            
            filename='plikiCSV_Panevezys\FH11\02_12\Z4.csv';'rt'; % 20000 35000
            t_start=25000+1000+500;
            t_end=43000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 202
            filename='plikiCSV_Panevezys\FH11\03_16\Z4.csv';'rt';
            t_start=16000+8000+1750;
            t_end=35000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 203
            filename='plikiCSV_Panevezys\FH11\03_22\Z4.csv';'rt'; % 20000 35000
            t_start=26500;
            t_end=35000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 204
            filename='plikiCSV_Panevezys\FH11\05_09\Z4.csv';'rt'; % 20000 35000
            t_start=61000;
            t_end=72000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 205
            
            filename='plikiCSV_Panevezys\FH11\06_04\Z4.csv';'rt'; % 20000 35000
            t_start=40000;
            t_end=50000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 206
            
            filename='plikiCSV_Panevezys\FH11\17_09_05\Z4.csv';'rt'; % 20000 35000
            t_start=26500;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 207
            
            filename='plikiCSV_Panevezys\FH11\17_10_10\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 208
            
            filename='plikiCSV_Panevezys\FH11\17_11_07\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=26500+10000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 209
            
            filename='plikiCSV_Panevezys\FH12\04_02\Z4.csv';'rt'; % 20000 35000
            t_start=25500;
            t_end=35000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 210
            
            filename='plikiCSV_Panevezys\FH12\02_28\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=35000;
            
            ident_section=MD_ident_section(2,{'FH12_Z3_TEMP_PV','FH12_Z4_MIX_PRES_PV',...
                'FH12_Z4_TEMP_PV','FH12_Z4_TEMP_SP','FH12_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
            %% INNE
            
        case 501
            
            filename='plikiCSV_Panevezys\FH11\01_24\Z4.csv';'rt'; % 20000 35000
            t_start=4500;  %+16000;  %dla ostatninego fragmentu
            t_end=21150+4500;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z3);
            
        case 502
            
            filename='plikiCSV_Panevezys\FH11\03_26\Z4.csv';'rt'; % 20000 35000
            t_start=27000;
            t_end=40000-5000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 503
            
            filename='plikiCSV_Panevezys\FH11\05_04\Z4.csv';'rt'; % 20000 35000
            t_start=6000;
            t_end=15000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 504
            
            filename='plikiCSV_Panevezys\FH11\17_08_30\Z4.csv';'rt'; % 20000 35000
            t_start=40500; %-2000;
            t_end=50500; %-8000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
        case 505
            
            filename='plikiCSV_Panevezys\FH11\17_10_24\Z4.csv';'rt'; % 20000 35000
            t_start=27000+250;
            t_end=40000;
            
            ident_section=MD_ident_section(2,{'FH11_Z3_TEMP_PV','FH11_Z4_MIX_PRES_PV',...
                'FH11_Z4_TEMP_PV','FH11_Z4_TEMP_SP','FH11_PULL'},[0.0344 1.236],1055,filename,MD_constant_values_Z4);
            
            
    end
    
else
    disp('No section');
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
        
        ident_section.define_interval(cnt_file,cnt_file+T-1,message);
        ident_section.simulate_model_output(cnt_file,cnt_file+T-1);
        ident_section.ident_model();
        
        ident_section.ident_alternative_model();
        ident_section.select_best_model();
        
    else
        
        ident_section.define_interval(cnt_file,t_end-1,message);
        ident_section.simulate_model_output(cnt_file,cnt_file+T-1);
        ident_section.ident_model();
        
        break;
    end
    
    cnt=cnt+T;
    cnt_file=cnt_file+T;
    
end

toc

ident_section.plot_signals(cnt,{'Previous section temperature', 'Mixture pressure','Cln. vlv. position'},{'Temp. [$^\circ$C]','Press. [kPa]','Pos. [$\%$]'},1,1,1);