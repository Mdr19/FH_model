function MD_generate_signals_fnc(zone_nr,data_set,start_cnt,signal_len)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



switch(data_set)
    
    case 4
        
        pull_var_name='FH11_Z3_TEMP_PV';
        %file_path='plikiCSV_Panevezys\04_23\FH11\Z3.csv';
        
    case 7
        
        pull_var_name='FH11_PULL';
        
        pull_steps_original=[1 2400 2800 2900 4800];
        pull_values_original=[114 95 100 105 112];
        
        pull_steps_saved=[1 2900  5000];
        pull_values_saved=[114 100 112];
        
        if zone_nr==3
            %temp_SP_steps=[1 400+500 820+500 2000-400+500 2500+100+500 3500-100+500 4300+500 5400+500];
            %temp_SP_values=[1184 1181 1178 1175 1170 1163 1162 1160];
            
            % ex 1 
            %[temp_SP_steps,temp_SP_values]=MD_generate_SP_evenly(1000,7000,6,1184,1160);
            
            % ex 2
            [temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1600,7000,5,1184,1160);

            % ex 3 prob numeryczne
            %temp_SP_steps=[1 1600 2680 3760 4840 5920];
            %temp_SP_values=[1184 1176 1172 1168 1164 1160];
            
        elseif zone_nr==4
            %temp_SP_steps=[1 820 2000-400 2500+100 3500-100 4300 5400];
            %temp_SP_values=[1181 1178 1175 1170 1165 1160 1155];
            
            %exp 1
            %[temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1000,6200,5,1181,1155);
            
            % exp 2
            [temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1600,6200,5,1181,1155);
            
        end
        
    case 8
        
        pull_var_name='FH11_PULL';
        %file_path='plikiCSV_Panevezys\05_31\FH11\Z3.csv';
        
        pull_steps_original=[1 2500-100 2800 3000-100 4800];
        pull_values_original=[74 55 58 67 63];
        
        pull_steps_saved=[1 2800 3100 5200];
        pull_values_saved=[74 55 67 63];
        
        %pull_steps_saved=pull_steps_original;
        %pull_values_saved=pull_values_original;
        
        if zone_nr==3
            %temp_SP_steps=[1 1000 2500 4500];
            %temp_SP_values=[1158 1168 1175 1183];
                        
            %[temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(500,5000,4,1158+3,1183+3);

            % 1 exmp
            [temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1000,6000,5,1158,1183);
            
            %temp_SP_steps=[1 1020 2400 3200+500 4000+500 5000+500 5400+500];
            
            % 2 exmp
            %temp_SP_steps=[1 1020 2400 3200 4000 5000 5400+500];
            %temp_SP_values=[1158 1168 1173 1178 1183 1180 1178];

            % 3 exmp
            %temp_SP_steps=[1 1000 2000 3000 4000 5000];
            %temp_SP_values=[1158 1165 1170 1175 1180 1183];
            %%temp_SP_steps(2:end)=temp_SP_steps(2:end)+200;
            
        elseif zone_nr==4
            %temp_SP_steps=[1 1020 2000-100 2500+100 3500-100 4300 5400];
            %temp_SP_values=[1150 1160 1165 1170 1175 1179 1177];
            
            % 2 exmp
            %[temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1000+200,6000+200,5,1150,1177);
            
            % 3 exmp
            temp_SP_steps=[1 1200 2200 3200 4200 5200];
            temp_SP_values=[1150 1160 1165 1170 1174 1177];
        end
        
        
    case 60
        
        pull_var_name='FH11_PULL';
        %file_path='plikiCSV_Panevezys\05_31\FH11\Z3.csv';
        
        pull_steps_original=[1 2785 2850 4800 5250];
        %pull_steps_original(2:end)=pull_steps_original(2:end)+1500+1000;
        pull_values_original=[55 40 42 44 42];
        
        pull_steps_saved=[1 2800 3000];
        pull_values_saved=[55 40 42];
        
        if zone_nr==3
            
            % ex 0
            %temp_SP_steps=[1 1000 2000 2500 3500];
            %temp_SP_values=[1162 1170 1175 1180 1185];

            [temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1000,4500,5,1162,1185);
            
            % old
            %5temp_SP_steps=[1 1000 2500 3500 4500 6000];
            %temp_SP_steps(2:end)=temp_SP_steps(2:end)+500;
            %temp_SP_values=[1162 1170 1175 1180 1184 1182];
            
            %new
            
            %ex 1
            %temp_SP_steps=[1 1000 2500 3500 4500 6000];
            %temp_SP_values=[1162 1170 1175 1180 1184 1182];
            %temp_SP_steps(3:end)=temp_SP_steps(3:end)+400;
            
        elseif zone_nr==4
            %temp_SP_steps=[1 1020 2000-100 2500+100 3500-100 4300 5400];
            %temp_SP_values=[1150 1160 1165 1170 1175 1179 1177];
            %[temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(300,5000,4,1150+5,1177+3);
            
            %[temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1500,5500,4,1155,1178);
            %temp_SP_steps(2:end)=temp_SP_steps(2:end)-400;
            
            %temp_SP_steps=[1 1300 2800 3800 4800 6300];
            %temp_SP_steps=[1 1000 2500 3500 4500 6000];
            %temp_SP_steps(2:end)=temp_SP_steps(2:end)+300;
            %temp_SP_values=[1155 1163 1168 1173 1178 1176];
            
            % old
            temp_SP_steps=[1 1050 2700 3700 4700 6200];
            %temp_SP_steps(2:end)=temp_SP_steps(2:end)+500;
            temp_SP_values=[1155 1163 1168 1173 1178 1176];

            %new
            
            % ex 1
            %temp_SP_steps=[1 1150 2700 3700 4700 6200];
            %temp_SP_values=[1155 1163 1168 1173 1178 1176];
            %temp_SP_steps(3:end)=temp_SP_steps(3:end)+400;

        end
        
    case 80
        
        pull_var_name='FH11_PULL';
        %file_path='plikiCSV_Panevezys\05_31\FH11\Z3.csv';
        
        %{
        pull_steps_original=[1 2500-100 2800 3000-100 4800];
        pull_values_original=[74 55 58 67 63];
        
        pull_steps_saved=[1 2800 3100 5200];
        pull_values_saved=[74 55 67 63];
        %}
        
        pull_steps_original=[1 2600 2800 4200];
        pull_values_original=[74 55 58 67];
        
        pull_steps_saved=[1 2800 2950 4300];
        pull_values_saved=[74 55 58 67];
        
        %pull_steps_saved=[1 2850 3050 3300];
        %pull_values_saved=[74 55 67];
        
        if zone_nr==3
            [temp_SP_steps, temp_SP_values]=MD_generate_SP_evenly(1000,5000,4,1158,1183);
            temp_SP_steps(end+1)=6000;
            temp_SP_values(end+1)=1180;

        elseif zone_nr==4

            temp_SP_steps=[1 1000 2000 3000 4000 6000];
            temp_SP_values=[1150 1160 1165 1170 1177 1175];
            
        end
        
end

if zone_nr==3
    temp_SP_file='Z3_temp_SP.csv';
    temp_SP_var_name='FH11_Z3_TEMP_SP';
    original_pull_file='Z3_PULL_original.csv';
    saved_pull_file='Z3_PULL_saved.csv';
else
    original_pull_file='Z4_PULL_original.csv';
    saved_pull_file='Z4_PULL_saved.csv';
    temp_SP_file='Z4_temp_SP.csv';
    temp_SP_var_name='FH11_Z4_TEMP_SP';
end



pull_original=zeros(signal_len,1);
pull_saved=zeros(signal_len,1);
temp_SP=zeros(signal_len,1);

%steps=[1 1500 3000 4000 7000];
%values=[35 30 40 50];

for i=1:max(pull_steps_original)
    for j=1:length(pull_steps_original)-1
        if i>= pull_steps_original(j) && i<pull_steps_original(j+1)
            %disp(['interval ' num2str(steps_2(j)) ' ' num2str(steps_2(j+1))])
            pull_original(i)=pull_values_original(j);
        end
    end
end

pull_original(i:end)=pull_values_original(end);

for i=1:max(pull_steps_saved)
    for j=1:length(pull_steps_saved)-1
        if i>= pull_steps_saved(j) && i<pull_steps_saved(j+1)
            %disp(['interval ' num2str(steps_2(j)) ' ' num2str(steps_2(j+1))])
            pull_saved(i)=pull_values_saved(j);
        end
    end
end

pull_saved(i:end)=pull_values_saved(end);


for i=1:max(temp_SP_steps)
    for j=1:length(temp_SP_steps)-1
        if i>= temp_SP_steps(j) && i<temp_SP_steps(j+1)
            %disp(['interval ' num2str(steps_2(j)) ' ' num2str(steps_2(j+1))])
            temp_SP(i)=temp_SP_values(j);
        end
    end
end

temp_SP(i:end)=temp_SP_values(end);



figure(zone_nr*10+1);
subplot(3,1,1);

plot(pull_original);
hold on;
grid on;
title('Original pull signal');

subplot(3,1,2);

plot(pull_saved);
hold on;
grid on;
title('Saved pull signal');

subplot(3,1,3);
plot(temp_SP)
hold on;
grid on;
title('Temperature SP');

pull_original=[pull_original(1)*ones(start_cnt,1); pull_original];
pull_saved=[pull_saved(1)*ones(start_cnt,1); pull_saved];
temp_SP=[temp_SP(1)*ones(start_cnt,1); temp_SP];


fid = fopen(original_pull_file, 'w');
fprintf( fid, '%s\n', strcat('nr; ', pull_var_name));

for i=1:length(pull_original)
    fprintf( fid, '%d;%f\n', i, pull_original(i));
end

fclose(fid);


fid = fopen(saved_pull_file, 'w');
fprintf( fid, '%s\n', strcat('nr; ', pull_var_name));

for i=1:length(pull_saved)
    fprintf( fid, '%d;%f\n', i, pull_saved(i));
end

fclose(fid);


fid = fopen(temp_SP_file, 'w');
fprintf( fid, '%s\n', strcat('nr; ', temp_SP_var_name));

for i=1:length(temp_SP)
    fprintf( fid, '%d;%f\n', i, temp_SP(i));
end

fclose(fid);

end

