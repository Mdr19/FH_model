function [ read_signal ] = MD_get_from_file( file_name, signal_name, start_index, end_index, signal_delay,message)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(file_name);
varNames = strsplit(fgetl(fid), ';');
fclose(fid);
i=1;

signal_cnt=0;

if exist(file_name)==2
    
    if message
        disp(['File ' file_name ' exists.']);
    end
    
    while i<=length(varNames)
        
        if strcmp(varNames{i},signal_name)
            if message
                disp(['Signal ' signal_name ' found']);
            end
            signal_cnt=i-1;
            break;
        end
        
        i=i+1;
    end
    
    if signal_cnt>0
        if message
            disp(['Variable ' signal_name ' exists !!!']);
        end
        read_signal=dlmread(file_name,';',[start_index-signal_delay,...
            signal_cnt end_index-signal_delay signal_cnt]);
    else
        if message
            disp(['Variable ' signal_name ' does not exist !!!']);
        end
        read_signal=[];
    end
    
else
    if message
        disp(['File ' file_name ' does not exist !!!']);
    end
end

end

