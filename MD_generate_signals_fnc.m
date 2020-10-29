function MD_generate_signals_fnc(zone_nr,data_set,start_cnt,signal_len)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



switch(data_set)
    
    case 4
        
        pull_var_name='FH11_Z3_TEMP_PV';
        file_path='plikiCSV_Panevezys\04_23\FH11\Z3.csv';
        
    case 7
        
        pull_var_name='FH11_PULL';
        
        pull_steps_original=[1 2400 2800 2900 4800];
        pull_values_original=[114 95 100 105 112];
        
        pull_steps_saved=[1 2400 2800 2900 4800];
        pull_values_saved=[114 95 100 105 112];
        
        if zone_nr==3
            temp_SP_steps=[1 1000 2500 4500];
            temp_SP_values=[1158 1168 1175 1183];
            temp_SP_file='Z3_temp_SP.csv';
            temp_SP_var_name='FH11_Z3_TEMP_SP';
        elseif zone_nr==4
            temp_SP_steps=[1 820 2000-400 2500+100 3500-100 4300 5400];
            temp_SP_values=[1181 1178 1175 1170 1165 1160 1155];
            temp_SP_file='Z4_temp_SP.csv';
            temp_SP_var_name='FH11_Z4_TEMP_SP';
        end
        
    case 8
        
        
        pull_var_name='FH11_PULL';
        file_path='plikiCSV_Panevezys\05_31\FH11\Z3.csv';
        
        pull_steps_original=[1 2500-100 2800 3000-100 4800];
        pull_values_original=[74 55 58 67 63];
        
        pull_steps_saved=[1 2800 3100 5200];
        pull_values_saved=[74 55 67 63];
        
        if zone_nr==3
            temp_SP_steps=[1 1000 2500 4500];
            temp_SP_values=[1158 1168 1175 1183];
            temp_SP_file='Z3_temp_SP.csv';
            temp_SP_var_name='FH11_Z3_TEMP_SP';
        elseif zone_nr==4
            temp_SP_steps=[1 1020 2000-100 2500+100 3500-100 4300 5400];
            temp_SP_values=[1150 1160 1165 1170 1175 1179 1177];
            temp_SP_file='Z4_temp_SP.csv';
            temp_SP_var_name='FH11_Z4_TEMP_SP';
        end
        
end

original_pull_file='Z4_PULL_original.csv';
saved_pull_file='Z4_PULL_saved.csv';




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

