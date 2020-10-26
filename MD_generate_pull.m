clear all
close all

data_set=4;

switch(data_set)

case 4
   
    zone_name='Z4';
    var_name='FH11_PULL';
    start_time=4500-500;
    end_time=10000;

    original_file_name='';
    modified_file_name='';
    
case 8
   
    zone_name='Z4';
    var_name='FH11_PULL';
    start_time=27000+400;
    end_time=36000;
    
    new_file_name
    
end
    
new_file_name='PULL_modified.csv';


mode=0;             % 0 -modyfikacja istniejacych danych wydobycia, 1 - nowe towrzenie danych wydobycia

switch mode
    case 0
        pull_signal=MD_get_from_file(char(strcat(file_path,'\',date,'\',zone_name,'.csv')) ,...
            var_name,start_time,end_time,0,MD_constant_values.FH_message_display);
        
        steps=[1];
        values=[pull_signal(1)];
        delays=[500 300 100];
        
        for i=1:length(pull_signal)-1
            if pull_signal(i+1)~=pull_signal(i)
                %disp(['Skok ' num2str(i)]);
                steps=[steps i+1];
                values=[values pull_signal(i+1)];
            end
        end
        
        steps=[steps length(pull_signal)];
        
        steps_2=steps;
        
        for i=2:length(steps)-1
            steps_2(i)=steps(i)-delays(i-1);
        end
        
        for i=1:length(pull_signal)
            for j=1:length(steps_2)-1
                if i>= steps_2(j) && i<steps_2(j+1)
                    %disp(['interval ' num2str(steps_2(j)) ' ' num2str(steps_2(j+1))])
                    pull_signal_2(i)=values(j);
                end
            end
        end
        
        pull_signal_2(end+1)=pull_signal(end);
        
        f_size=25;
        
        fig=figure(101);
        fig.Color=[1 1 1];
        plot(pull_signal);
        hold on;
        plot(pull_signal_2);
        grid on;
        
        title('Forehearth pull', 'interpreter', 'latex');
        xlabel('Time [s]', 'interpreter', 'latex');
        set(gca,'fontsize',f_size)
        y=ylabel(['Pull [t/24h]'], 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
        set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
        
        legend('Original','PDE model');
        %title('Modified glass pull');
        xlim([1 max(steps)]);
        

        %csvwrite('myFile.csv',{'FH11_PULL'},0,0);
        %csvwrite('myFile.csv',pull_signal_2',1,0);
        
    case 1
        
        %steps=[1 1500 3000 4000 7000];
        %values=[35 30 40 50];
        
        steps=[1 2000 2100 4500 7000];
        values=[56 40 43 45];
        
        for i=1:max(steps)
            for j=1:length(steps)-1
                if i>= steps(j) && i<steps(j+1)
                    %disp(['interval ' num2str(steps_2(j)) ' ' num2str(steps_2(j+1))])
                    pull_signal_2(i)=values(j);
                end
            end
        end
        
        
        
        figure(101);
        plot(pull_signal_2);
        hold on;
        %plot(pull_signal_2);
        grid on;
        %legend('Created');
        title('Created pull signal');
end

pull_signal_2=[pull_signal_2(1)*ones(1,start_time-1) pull_signal_2];

%{
figure(103)
plot(pull_signal_2);
grid on;
%}

fid = fopen(new_file_name, 'w');
fprintf( fid, '%s\n', strcat('nr; ', var_name));

for i=1:length(pull_signal_2)
    fprintf( fid, '%d;%f\n', i, pull_signal_2(i));
end

fclose(fid);

%pull_signal_3=MD_get_from_file(new_file_name ,var_name,1,20,0,1);


%{
figure(101);
plot(pull_signal);
hold on;
plot(pull_signal_2);
grid on;

figure(102);
plot(pull_signal_2);
%grid on;

signals_delays=[];
    %}
