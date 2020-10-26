classdef MD_ident_section < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        inputs_nr;
        signals_names;
        signals_intervals;
        
        ident_models;
        
        current_delay;
        section_length;
        delay_poly;
        
        filename;
        
        current_interval;
        current_model_nr;
        
        current_model;
        current_model_params;
        
        current_initial_state;
        %initial_states;
        
        current_zero_point_interval;
        
        alternative_model;
        %alternative_model_params;
        alternative_model_zero_interval;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        current_model_Strejc;
        current_model_Strejc_initial_state;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_model_FF;
        current_model_FF_state;
    end
    
    methods
        
        % class constructor
        
        function obj = MD_ident_section(inputs_nr_,signals_names_,poly_coef,section_length_,filename_)
            if nargin > 0
                obj.inputs_nr = inputs_nr_;
                obj.signals_names=signals_names_;
                obj.signals_intervals=[];
                %obj.pull_var_name=pull_var_name_;
                obj.section_length=section_length_;
                obj.delay_poly=poly_coef;
                obj.filename=filename_;
                obj.current_interval=1;
                obj.current_model_nr=1;
            end
        end
        
        %%
        
        function define_interval(obj,start_index,end_index,message)
            
            disp('------------------------------------------------------------------------------------------------------------------------');
            disp(['Model ' num2str(obj.current_model_nr) ' interval ' num2str(obj.current_interval) ' Interval start: ' num2str(start_index) ' end: ' num2str(end_index)])
            disp('------------------------------------------------------------------------------------------------------------------------');
            
            get_signals_from_file_ident_interval(obj,start_index,end_index,message);
            %obj.signals_intervals(obj.current_interval).time=start_index:end_index;
            if end_index-start_index<MD_constant_values.T_sim
                obj.signals_intervals(obj.current_interval).time=MD_constant_values.T_sim*(obj.current_interval-1)+...
                    1:MD_constant_values.T_sim*(obj.current_interval-1)+end_index-start_index+1;
                
                obj.signals_intervals(obj.current_interval).time_start_file=start_index;
                obj.signals_intervals(obj.current_interval).time_end_file=end_index;
                
                
                if length(obj.signals_intervals(obj.current_interval).original_signals(end,:))>=MD_constant_values.pull_signal_len
                    mean_pull=mean(obj.signals_intervals(obj.current_interval).original_signals(end,end-MD_constant_values.pull_signal_len:end));
                else
                    mean_pull=mean(obj.signals_intervals(obj.current_interval).original_signals(end,:));
                end
                
                obj.signals_intervals(obj.current_interval).glass_vel=obj.delay_poly(1)*mean_pull+obj.delay_poly(2);
                obj.signals_intervals(obj.current_interval).prev_section_del=round(obj.section_length/obj.signals_intervals(obj.current_interval).glass_vel);
                obj.current_delay=obj.signals_intervals(obj.current_interval).prev_section_del;
                %pull_signal_len
                
            else
                obj.signals_intervals(obj.current_interval).time=MD_constant_values.T_sim*(obj.current_interval-1)+1:MD_constant_values.T_sim*obj.current_interval+1;
            end
            
            obj.find_operating_point_interval();
            obj.define_model_inputs_intervals();
            obj.current_interval=obj.current_interval+1;
            
        end
        
        %%
        
        function define_interval_plant(obj,section_sim,interval_nr)
            
            disp('-------------------------------------------------------------------------------------------------------');
            
            get_signals_from_plant_ident_interval(obj,section_sim,interval_nr);
            
            if length(obj.signals_intervals(obj.current_interval).original_signals(end,:))>=MD_constant_values.pull_signal_len
                mean_pull=mean(obj.signals_intervals(obj.current_interval).original_signals(end,end-MD_constant_values.pull_signal_len:end));
            else
                mean_pull=mean(obj.signals_intervals(obj.current_interval).original_signals(end,:));
            end
            
            obj.signals_intervals(obj.current_interval).glass_vel=obj.delay_poly(1)*mean_pull+obj.delay_poly(2);
            obj.signals_intervals(obj.current_interval).prev_section_del=round(obj.section_length/obj.signals_intervals(obj.current_interval).glass_vel);
            obj.current_delay=obj.signals_intervals(obj.current_interval).prev_section_del;
            
            obj.signals_intervals(obj.current_interval).op_interval=false;
            
            obj.find_operating_point_interval();
            obj.define_model_inputs_intervals();
            obj.current_interval=obj.current_interval+1;
            
        end
        
        %%
        % Getting multiple signals from the plant
        
        function get_signals_from_plant_ident_interval(obj,section_sim,interval_nr)
            
            for i=1:obj.inputs_nr
                obj.signals_intervals(obj.current_interval).original_signals(i,:)=section_sim.intervals(interval_nr).signals(i,:);
                
            end
            
            obj.signals_intervals(obj.current_interval).original_signals(obj.inputs_nr+1,:)=section_sim.intervals(interval_nr).simulated_temp_resampled;
            obj.signals_intervals(obj.current_interval).original_signals(obj.inputs_nr+2,:)=section_sim.intervals(interval_nr).signals(obj.inputs_nr+2,:);
            obj.signals_intervals(obj.current_interval).original_signals(obj.inputs_nr+3,:)=section_sim.intervals(interval_nr).signals(obj.inputs_nr+3,:);
            
            obj.signals_intervals(obj.current_interval).time=section_sim.intervals(interval_nr).time;
            
            obj.signals_intervals(obj.current_interval).time_start_file=obj.signals_intervals(obj.current_interval).time(1);
            obj.signals_intervals(obj.current_interval).time_end_file=obj.signals_intervals(obj.current_interval).time(end);
            
            
        end
        
        %%
        function ident_model_plant(obj,section_sim)
            if isempty(obj.current_model)
                % identifying the first model
                
                % check if operating point can be found
                
                if obj.current_interval-1>=MD_constant_values.init_model_intervals
                    
                    op_found=0;
                    
                    for i=1:obj.current_interval-1
                        if obj.signals_intervals(i).op_interval==true
                            %disp(['OP found ' num2str(i)]);
                            disp('---------------------------------------------------');
                            disp(['OP found ' num2str(i)]);
                            disp('---------------------------------------------------');
                            op_found=1;
                            %op_time=obj.signals_intervals(i).op_time;
                            op_time_file=obj.signals_intervals(i).op_time_file;
                            prev_section_del=obj.signals_intervals(i).prev_section_del;
                            obj.current_zero_point_interval=i;
                            break;
                        elseif i==obj.current_interval-1
                            disp('OP not found');
                            op_found=0;
                        end
                    end
                    
                    if op_found && (obj.current_interval-obj.current_zero_point_interval)>=MD_constant_values.init_model_intervals
                        
                        %check which inputs can be identified
                        obj.ident_models(1).inputs_to_ident=zeros(obj.inputs_nr,1);
                        
                        sum_temp=0;
                        %sum_temp_prev=0;
                        ident_offset_intervals=0;
                        
                        for i=obj.current_zero_point_interval:obj.current_interval-1
                            
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    obj.ident_models(1).inputs_to_ident(j)=1;
                                end
                            end
                            
                            sum_temp=sum_temp+sum(obj.ident_models(1).inputs_to_ident);
                            
                            if sum_temp==0 %&& sum_temp_prev==0
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                            %sum_temp_prev=sum_temp;
                        end
                        
                        obj.ident_models(1).inputs_to_ident
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        for i=obj.current_zero_point_interval:obj.current_interval-1
                            
                            mod_int_nr=i-obj.current_zero_point_interval+1;
                            
                            if obj.signals_intervals(i).time_end_file>op_time_file
                                if obj.signals_intervals(i).time_start_file>op_time_file
                                    start_time_file=obj.signals_intervals(i).time_start_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).time(1);
                                    end_time=obj.signals_intervals(i).time(end);
                                else
                                    start_time_file=op_time_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).op_time;
                                    end_time=obj.signals_intervals(i).time(end);
                                end
                            end
                            
                            input_signals=[];
                            
                            if sum(obj.ident_models(1).inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                n=1;
                                disp('------------------------------------------------------------');
                                for j=1:obj.inputs_nr
                                    if obj.ident_models(1).inputs_to_ident(j)
                                        if j==1
                                            %disp(['-------------------- GETTING SIGNAL ' num2str(j)]);
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file-prev_section_del,...
                                                end_time_file-prev_section_del);
                                            
                                            if i==obj.current_zero_point_interval
                                                obj.ident_models(1).offset_value(n)=input_signals(1,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(1).offset_value(n);
                                            
                                        else
                                            %disp(['-------------------- GETTING SIGNAL ' num2str(j)]);
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file,end_time_file);
                                            
                                            if i==obj.current_zero_point_interval
                                                obj.ident_models(1).offset_value(n)=input_signals(n,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(1).offset_value(n);
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                
                                obj.ident_models(1).intervals(mod_int_nr).input_signals=input_signals;
                                output_signal=section_sim.get_output_signal(start_time_file,end_time_file);
                                
                                if i==obj.current_zero_point_interval
                                    obj.ident_models(1).offset_value(n)=output_signal(1);
                                end
                                
                                output_signal=output_signal-obj.ident_models(1).offset_value(n);
                                
                                obj.ident_models(1).intervals(mod_int_nr).output_signal=output_signal;
                                obj.ident_models(1).intervals(mod_int_nr).time=start_time:end_time;
                                obj.ident_models(1).intervals(mod_int_nr).interval_type='I';
                                
                            end
                        end
                        
                        if sum(obj.ident_models(1).inputs_to_ident)>=MD_constant_values.min_inputs_ident
                            
                            obj.ident_models(1).prev_section_del=prev_section_del;
                            obj.current_delay=obj.ident_models(1).prev_section_del;
                            
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.ident_models(1).intervals)
                                input_signals_ident=[input_signals_ident obj.ident_models(1).intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident obj.ident_models(1).intervals(i).output_signal];
                            end
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.current_model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,obj.current_model_nr*100);
                                case 2
                                case 3
                                    obj.current_model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 4
                                    obj.current_model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 5
                                    obj.current_model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 6
                                    obj.current_model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 7
                                    [obj.current_model, obj.current_model_params]=MD_model_ident_LSM_GS4(input_signals_ident,output_signal_ident',obj.current_model_nr*100);
                                otherwise
                                    obj.current_model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,obj.current_model_nr*100);
                            end
                            
                            
                            obj.ident_models(1).intervals(1).initial_state=[];
                            obj.current_initial_state=zeros(size(obj.current_model,2),obj.current_model_params.m-1);
                            
                            for i=1:length(obj.ident_models(1).intervals)
                                obj.ident_models(1).intervals(i).initial_state=obj.current_initial_state;
                                [obj.ident_models(1).intervals(i).simulated_output, obj.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.ident_models(1).intervals(i).input_signals,obj.current_initial_state,obj.current_model,0); %+obj.ident_models(1).offset_value;
                                %obj.initial_states=[obj.initial_states obj.current_initial_state];
                                
                                obj.ident_models(1).intervals(i).model_diff=sumsqr(obj.ident_models(1).intervals(i).simulated_output-...
                                    obj.ident_models(1).intervals(i).output_signal);
                                
                                obj.ident_models(1).intervals(i).model=obj.current_model;
                                %obj.ident_models(1).intervals(i).model_params=obj.current_model_params;
                                
                            end
                            
                            % zmiana model params
                            obj.ident_models(1).model_params=obj.current_model_params;
                            
                            % zmiana 11.06.2020
                            if MD_constant_values.initial_state_method
                                obj.current_initial_state=obj.obtain_system_state(input_signals_ident,output_signal_ident,MD_constant_values.T_ob);
                                obj.ident_models(1).intervals(i+1).initial_state=obj.current_initial_state;
                            else
                                obj.ident_models(1).intervals(i+1).initial_state=obj.current_initial_state;
                            end
                            
                        end
                        
                    end
                    
                end
            else
                
                % updating the current model parameters
                
                if MD_constant_values.change_model
                    
                    % check if the difference between model and system is
                    % greater than change threshold
                    
                    if obj.ident_models(obj.current_model_nr).intervals(end-1).model_diff>MD_constant_values.model_change_threshold
                        
                        initial_int=max(1,length(obj.ident_models(obj.current_model_nr).intervals)-MD_constant_values.ident_intervals);
                        
                        ident_initial_state=obj.ident_models(obj.current_model_nr).intervals(initial_int).initial_state;
                        
                        input_signals_ident=[];
                        output_signal_ident=[];
                        
                        for i=initial_int:length(obj.ident_models(obj.current_model_nr).intervals)-1
                            input_signals_ident=[input_signals_ident obj.ident_models(obj.current_model_nr).intervals(i).input_signals];
                            output_signal_ident=[output_signal_ident obj.ident_models(obj.current_model_nr).intervals(i).output_signal];
                        end
                        
                        %MISO_eta=ones(MD_constant_values.m+MD_constant_values.n*sum(obj.ident_models(1).inputs_to_ident),1);
                        MISO_eta=[1 1 1 1];
                        
                        iter=100*obj.current_model_nr+length(obj.ident_models(obj.current_model_nr).intervals);
                        
                        switch MD_constant_values.ident_mode
                            case 1
                                [interval_type, reident_model]=MD_MISO_model_reident(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,MISO_eta,ident_initial_state,iter);
                            case 2
                            case 3
                                ident_initial_state=ident_initial_state(1,:);
                                [interval_type, reident_model]=MD_model_reident_LSM(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,ident_initial_state,iter);
                            case 4
                                %ident_initial_state=ident_initial_state(1,:);
                                [interval_type, reident_model]=MD_model_reident_LSM_GS(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,ident_initial_state,iter);
                            case 5
                                
                            case 6
                                
                            case 7
                                
                                if(size(ident_initial_state,1))~=size(obj.current_model,2)
                                    disp('OTHER INITIAL STATE NEEDED');
                                    %interval_type='N';
                                    
                                    if sum(ident_initial_state(1,:))==0
                                        ident_initial_state=zeros(size(obj.current_model,2),obj.current_model_params.m-1);
                                        [interval_type, reident_model]=MD_model_reident_LSM_GS4(obj.current_model,obj.current_model_params,...
                                            obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                            input_signals_ident,output_signal_ident',ident_initial_state,iter);
                                    elseif MD_constant_values.initial_state_method
                                        interval_type='N';
                                    else
                                        interval_type='N';
                                    end
                                    
                                else
                                    [interval_type reident_model]=MD_model_reident_LSM_GS4(obj.current_model,obj.current_model_params,...
                                        obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                        input_signals_ident,output_signal_ident',ident_initial_state,iter);
                                end
                                
                                
                                
                            otherwise
                                [interval_type reident_model]=MD_MISO_model_reident(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,MISO_eta,ident_initial_state,iter);
                        end
                        
                        if interval_type~='N'
                            disp('---------------------------------------------------');
                            disp('MODEL UPDATE');
                            disp('---------------------------------------------------');
                            obj.ident_models(obj.current_model_nr).intervals(end).interval_type='R';
                            obj.current_model=reident_model;
                            obj.current_initial_state=obj.obtain_system_state(input_signals_ident,output_signal_ident,MD_constant_values.T_ob);
                            obj.ident_models(obj.current_model_nr).intervals(end).initial_state=obj.current_initial_state;
                            obj.ident_models(obj.current_model_nr).intervals(end).model=reident_model;
                            %obj.ident_models(obj.current_model_nr).intervals(end).model_params=obj.current_model_params;
                        end
                        
                        %zmiana model params
                        obj.ident_models(obj.current_model_nr).model_params=obj.current_model_params;
                        
                    else
                        
                    end
                    
                end
            end
        end
        
        %%
        function ident_model_FF(obj)
            
            if ~isempty(obj.current_model)
                disp('Obtaining FF model');
                n=obj.current_model_params.n;
                m=obj.current_model_params.m;
                
                if size(obj.current_model)==1
                    
                    num_d=obj.current_model.vector(m+1:m+n);
                    num_u=obj.current_model.vector(m+1+n:end);
                    
                    obj.current_model_FF.A=0;
                    obj.current_model_FF.B=0;
                    obj.current_model_FF.C=0;
                    obj.current_model_FF.D=deconv(num_d,num_u);  % tylko dla przypadku 0 stopnia licznika
                else
                    
                    disp('I am here');
                    input_signal=[];
                    
                    for i=1:length(obj.ident_models(obj.current_model_nr).intervals)-1
                        input_signal=[input_signal obj.ident_models(obj.current_model_nr).intervals(i).input_signals(1,:)];
                    end
                    
                    num_d=obj.current_model(1).vector(m+1:end);
                    den_d=obj.current_model(1).vector(1:m);
                    
                    num_u=obj.current_model(MD_constant_values.Strejc_signal_nr).vector(m+1:end);
                    den_u=obj.current_model(MD_constant_values.Strejc_signal_nr).vector(1:m);
                    
                    num=conv(num_d, den_u);
                    den=conv(num_u, den_d);
                    
                    [A,B,C,D]=tf2ss(num',den);
                    
                    %[D num_a]=deconv(num,den)
                    obj.current_model_FF.A=A;
                    obj.current_model_FF.B=B;
                    obj.current_model_FF.C=C;
                    obj.current_model_FF.D=D;  % tylko dla przypadku 0 stopnia licznika
                    
                    C=eye(rank(A));
                    D=zeros(rank(A),1);
                    t=0:length(input_signal)-1;
                    
                    sim_out=lsim(ss(obj.current_model_FF.A,obj.current_model_FF.B,C,D),input_signal,t);
                    
                    if isempty(obj.current_model_FF_state)
                        obj.current_model_FF_state=sim_out(end,:);
                    end
                end
                
            end
        end
        
        %%
        
        function simulate_model_output_plant(obj,section_sim,time_start,time_end)
            
            if ~isempty(obj.current_model)
                n=1;
                
                time_start_ob=time_end-MD_constant_values.T_ob+1;
                
                for j=1:obj.inputs_nr
                    if obj.ident_models(obj.current_model_nr).inputs_to_ident(j)
                        if j==1
                            input_signals(n,:)=section_sim.get_signal(1,time_start-obj.ident_models(obj.current_model_nr).prev_section_del,...
                                time_end-obj.ident_models(obj.current_model_nr).prev_section_del);
                            
                            
                            
                            input_signals_ob(n,:)=section_sim.get_signal(1,time_start_ob-obj.ident_models(obj.current_model_nr).prev_section_del,...
                                time_end-obj.ident_models(obj.current_model_nr).prev_section_del);
                            %disp(['rozmiar ob ' num2str(size(input_signals_ob)) ' a roznica ' num2str(time_end-time_start_ob)]);
                            
                            
                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            input_signals_ob(n,:)=input_signals_ob(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                        else
                            input_signals(n,:)=section_sim.get_signal(j,time_start,time_end);
                            
                            
                            
                            input_signals_ob(n,:)=section_sim.get_signal(j,time_start_ob,time_end);
                            
                            
                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            input_signals_ob(n,:)=input_signals_ob(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            
                        end
                        n=n+1;
                    end
                end
                
                pos=length(obj.ident_models(obj.current_model_nr).intervals);
                
                obj.ident_models(obj.current_model_nr).intervals(pos).input_signals=input_signals;
                obj.ident_models(obj.current_model_nr).intervals(pos).time=...
                    obj.ident_models(obj.current_model_nr).intervals(end-1).time(end)+1:obj.ident_models(obj.current_model_nr).intervals(end-1).time(end)+time_end-time_start+1;
                
                output_signal=section_sim.get_output_signal(time_start,time_end);
                output_signal_ob=section_sim.get_output_signal(time_start_ob,time_end);
                
                output_signal=output_signal-obj.ident_models(obj.current_model_nr).offset_value(end);
                output_signal_ob=output_signal_ob-obj.ident_models(obj.current_model_nr).offset_value(end);
                
                obj.ident_models(obj.current_model_nr).intervals(pos).output_signal=output_signal;
                
                [simulated_output, obj.current_initial_state]=...
                    MD_simulate_MISO_system_output(input_signals,obj.current_initial_state,obj.current_model,0); %+obj.ident_intervals(1).offset_value;
                
                if MD_constant_values.initial_state_method
                    obj.current_initial_state=obj.obtain_system_state(input_signals_ob,output_signal_ob',MD_constant_values.T_ob);
                end
                
                obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output=simulated_output;
                obj.ident_models(obj.current_model_nr).intervals(pos).model_diff=sumsqr(obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output-...
                    obj.ident_models(obj.current_model_nr).intervals(pos).output_signal);
                obj.ident_models(obj.current_model_nr).intervals(end+1).initial_state=obj.current_initial_state;
                
            end
            
        end
        
        %%
        
        function simulate_Strejc_model_output_plant(obj,section_sim,time_start,time_end)
            
            if ~isempty(obj.current_model_Strejc)
                
                %time_start_ob=time_end-MD_constant_values.T_ob+1;
                
                input_signal_Strejc=section_sim.get_signal(MD_constant_values.Strejc_signal_nr,time_start-obj.current_model_Strejc.del,...
                    time_end-obj.current_model_Strejc.del);
                
                %input_signal_Strejc_ob=section_sim.get_signal(MD_constant_values.Strejc_signal_nr,time_start_ob-obj.ident_models(obj.current_model_nr).prev_section_del,...
                %    time_end-obj.ident_models(obj.current_model_nr).prev_section_del);
                
                
                input_signal_Strejc=input_signal_Strejc-obj.ident_models(obj.current_model_nr).offset_value(MD_constant_values.Strejc_signal_nr);
                %input_signal_Strejc_ob=input_signal_Strejc_ob-obj.ident_models(obj.current_model_nr).offset_value(MD_constant_values.Strejc_signal_nr);
                
                t=0:length(input_signal_Strejc)-1;
                n=rank(obj.current_model_Strejc.A);
                
                C=zeros(1,n);
                C(end)=1;
                D=0;
                
                time_ob_len=60;
                
                if isempty(obj.current_model_Strejc_initial_state) % the first Strejc model
                    % simulate the pressure response
                    y=MD_simulate_system_output_selected(input_signal_Strejc,obj.current_initial_state,obj.current_model,MD_constant_values.Strejc_signal_nr,0);
                    % obtain the initial state
                    %time_ob_len=70;
                    
                    X0=MD_exact_state_observer_initial(ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,C,D),t(1:time_ob_len),input_signal_Strejc(1:time_ob_len),y(1:time_ob_len)');
                    %X0=obj.ident_models(obj.current_model_nr).intervals(end-1).initial_state(MD_constant_values.Strejc_signal_nr,:);
                    [simulated_output, obj.current_model_Strejc_initial_state]=...
                        MD_simulate_SISO_system_output(input_signal_Strejc,X0,ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,...
                        obj.current_model_Strejc.C,obj.current_model_Strejc.D),0);
                else
                    
                    if length(obj.current_model_Strejc_initial_state)~=rank(obj.current_model_Strejc.A)
                        disp('bad state');
                        %time_ob_len=70;
                        y=MD_simulate_system_output_selected(input_signal_Strejc,obj.current_initial_state,obj.current_model,MD_constant_values.Strejc_signal_nr,0);
                        X0=MD_exact_state_observer_initial(ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,C,D),t(1:time_ob_len),input_signal_Strejc(1:time_ob_len),y(1:time_ob_len)');
                    else
                        X0=obj.current_model_Strejc_initial_state;
                    end
                    
                    %X0=obj.ident_models(obj.current_model_nr).intervals(end-1).initial_state(MD_constant_values.Strejc_signal_nr,:);
                    [simulated_output, obj.current_model_Strejc_initial_state]=...
                        MD_simulate_SISO_system_output(input_signal_Strejc,X0,ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,...
                        obj.current_model_Strejc.C,obj.current_model_Strejc.D),0);
                end
                
                
                % zakomentowana ca³a sekcja do X0 !!!!!!!!!!!!!!!!!!
                %{
                y=MD_simulate_system_output_selected(input_signal_Strejc,obj.current_initial_state,obj.current_model,MD_constant_values.Strejc_signal_nr,0);
                % obtain the initial state
                X0=MD_exact_state_observer_initial(ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,C,D),t(1:50),input_signal_Strejc(1:50),y(1:50));
                    [simulated_output, obj.current_model_Strejc_initial_state]=...
                MD_simulate_SISO_system_output(input_signal_Strejc,X0,ss(obj.current_model_Strejc.A,obj.current_model_Strejc.B,...
                        obj.current_model_Strejc.C,obj.current_model_Strejc.D),0);
                
                
                pos=length(obj.ident_models(obj.current_model_nr).intervals)-1;
                simulated_output_rest=MD_simulate_MISO_system_output_without_sel(obj.ident_models(obj.current_model_nr).intervals(pos).input_signals,...
                    obj.ident_models(obj.current_model_nr).intervals(pos).initial_state,obj.current_model,MD_constant_values.Strejc_signal_nr,0);
                
                %simulated_output_rest_2=MD_simulate_MISO_system_output_without_sel(obj.ident_models(obj.current_model_nr).intervals(pos).input_signals,...
                %    obj.ident_models(obj.current_model_nr).intervals(pos).initial_state,obj.current_model,1,0);

                obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output_Strejc=simulated_output_rest+simulated_output';
                
                disp('STREJC ZERO STATE');
                X0
                %}
                
                pos=length(obj.ident_models(obj.current_model_nr).intervals)-1;
                
                %simulated_output_rest_2=MD_simulate_MISO_system_output_without_sel(obj.ident_models(obj.current_model_nr).intervals(pos).input_signals,...
                %    obj.ident_models(obj.current_model_nr).intervals(pos).initial_state,obj.current_model,1,0);
                
                simulated_output_rest=MD_simulate_MISO_system_output_without_sel(obj.ident_models(obj.current_model_nr).intervals(pos).input_signals,...
                    obj.ident_models(obj.current_model_nr).intervals(pos).initial_state,obj.current_model,MD_constant_values.Strejc_signal_nr,0);
                
                obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output_Strejc=simulated_output_rest+simulated_output';
                
            end
            
        end
        
        %%
        
        function ident_alternative_model_plant(obj,section_sim)
            if ~isempty(obj.current_model) && isempty(obj.alternative_model)
                
                %find the new operating point
                op_found=0;
                
                disp(['Finding OP alternative ' num2str(obj.current_interval-MD_constant_values.new_model_intervals) ' ' num2str(obj.current_interval-1)]);
                for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                    if obj.signals_intervals(i).op_interval==true && i~=obj.current_zero_point_interval
                        disp('---------------------------------------------------');
                        disp(['OP alternative found ' num2str(i)]);
                        disp('---------------------------------------------------');
                        op_found=1;
                        op_time=obj.signals_intervals(i).op_time;
                        op_time_file=obj.signals_intervals(i).op_time_file;
                        prev_section_del=obj.signals_intervals(i).prev_section_del;
                        obj.alternative_model_zero_interval=i;
                        break;
                    elseif i==obj.current_interval-1
                        disp('OP alternative not found');
                        op_found=0;
                    end
                end
                
                if MD_constant_values.alternative_model_method==0
                    
                    % zero interval first
                    if op_found && (obj.current_interval-obj.alternative_model_zero_interval)>=MD_constant_values.new_model_intervals
                        
                        inputs_to_ident=zeros(obj.inputs_nr,1);
                        sum_temp=0;
                        ident_offset_intervals=0;
                        
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    inputs_to_ident(j)=1;
                                end
                            end
                            
                            sum_temp=sum_temp+sum(obj.ident_models(1).inputs_to_ident);
                            if sum_temp==0
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                            
                        end
                        
                        for i=obj.alternative_model_zero_interval:obj.current_interval-1
                            mod_int_nr=i-obj.alternative_model_zero_interval+1;
                            
                            if obj.signals_intervals(i).time_end_file>op_time_file
                                if obj.signals_intervals(i).time_start_file>op_time_file
                                    start_time_file=obj.signals_intervals(i).time_start_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).time(1);
                                    end_time=obj.signals_intervals(i).time(end);
                                else
                                    start_time_file=op_time_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).op_time;
                                    end_time=obj.signals_intervals(i).time(end);
                                end
                            end
                            
                            input_signals=[];
                            
                            if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                
                                obj.alternative_model.inputs_to_ident=inputs_to_ident;
                                n=1;
                                
                                for j=1:obj.inputs_nr
                                    if obj.alternative_model.inputs_to_ident(j)
                                        if j==1
                                            
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file-prev_section_del,...
                                                end_time_file-prev_section_del);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(1,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.alternative_model.offset_value(n);
                                            
                                        else
                                            
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file,end_time_file);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(n,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.alternative_model.offset_value(n);
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                
                                obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                output_signal=section_sim.get_output_signal(start_time_file,end_time_file);
                                
                                if i==obj.alternative_model_zero_interval
                                    obj.alternative_model.offset_value(n)=output_signal(1);
                                end
                                
                                output_signal=output_signal-obj.alternative_model.offset_value(n);
                                
                                obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                
                            end
                        end
                        
                        if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                            
                            obj.alternative_model.prev_section_del=prev_section_del;
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.alternative_model.intervals)
                                input_signals_ident=[input_signals_ident obj.alternative_model.intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident obj.alternative_model.intervals(i).output_signal];
                            end
                            
                            plot_cnt=1000+obj.current_model_nr*100+length(obj.ident_models(obj.current_model_nr).intervals);
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                                case 2
                                case 3
                                    obj.alternative_model.model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,plot_cnt);
                                case 4
                                    obj.alternative_model.model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,plot_cnt);
                                case 5
                                    obj.alternative_model.model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,plot_cnt);
                                case 6
                                    obj.alternative_model.model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,plot_cnt);
                                case 7
                                    [obj.alternative_model.model, obj.alternative_model.model_params]=MD_model_ident_LSM_GS4(input_signals_ident,output_signal_ident',plot_cnt);
                                otherwise
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                            end
                            
                            obj.alternative_model.intervals(1).initial_state=[];
                            obj.alternative_model.current_initial_state=zeros(sum(obj.ident_models(1).inputs_to_ident),obj.alternative_model.model_params.m-1);
                            
                            for i=1:length(obj.alternative_model.intervals)
                                obj.alternative_model.intervals(i).initial_state=obj.alternative_model.current_initial_state;
                                [obj.alternative_model.intervals(i).simulated_output, obj.alternative_model.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.alternative_model.intervals(i).input_signals,obj.alternative_model.current_initial_state,obj.alternative_model.model,0); %+obj.ident_models(1).offset_value;
                                
                                obj.alternative_model.intervals(i).model_diff=sumsqr(obj.alternative_model.intervals(i).simulated_output-...
                                    obj.alternative_model.intervals(i).output_signal);
                                obj.alternative_model.intervals(i).model=obj.alternative_model.model;
                                %obj.alternative_model.intervals(i).model_params=obj.alternative_model.model_params;
                            end
                            
                            % stan pocz¹tkowy jest ustawiany w pêtli
                            % sukcesywnie dla kolejnych interwa³ów
                            obj.alternative_model.intervals(i+1).initial_state=obj.alternative_model.current_initial_state;
                            
                        end
                        
                    end
                    
                else
                    
                    % zero interval w srodku
                    if op_found && obj.current_interval>=MD_constant_values.new_model_intervals
                        
                        inputs_to_ident=zeros(obj.inputs_nr,1);
                        sum_temp=0;
                        ident_offset_intervals=0;
                        
                        % sprawdŸ wejscia dla nowego modelu i ewentualnie
                        % interwa³y w których nie ma zmian (ident_offset_intervals)
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    inputs_to_ident(j)=1;
                                end
                            end
                            
                            sum_temp=sum_temp+sum(obj.ident_models(1).inputs_to_ident);
                            if sum_temp==0
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                        end
                        
                        ident_offset_intervals=0; % bez interwa³ów offsetowych
                        % pobierz sygnaly wejœciowe i wyjœciowe do
                        % identyfikacji
                        mod_int_nr=1;
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            
                            start_time_file=obj.signals_intervals(i).time_start_file;
                            end_time_file=obj.signals_intervals(i).time_end_file;
                            
                            start_time=obj.signals_intervals(i).time(1);
                            end_time=obj.signals_intervals(i).time(end);
                            
                            
                            input_signals=[];
                            
                            if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                
                                obj.alternative_model.inputs_to_ident=inputs_to_ident;
                                n=1;
                                
                                for j=1:obj.inputs_nr
                                    if obj.alternative_model.inputs_to_ident(j)
                                        if j==1
                                            
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file-prev_section_del,...
                                                end_time_file-prev_section_del);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(1,op_time-start_time);
                                            end
                                            
                                        else
                                            
                                            input_signals(n,:)=section_sim.get_signal(j,start_time_file,end_time_file);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(n,op_time-start_time);
                                            end
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                output_signal=section_sim.get_output_signal(start_time_file,end_time_file);
                                
                                if i==obj.alternative_model_zero_interval
                                    obj.alternative_model.offset_value(n)=output_signal(op_time-start_time);
                                    obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                    obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                    obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                    obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                else
                                    obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                    obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                    obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                    obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                end
                                
                            end
                            
                            mod_int_nr=mod_int_nr+1;
                        end
                        
                        if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                            obj.alternative_model.offset_value
                            
                            %odejmij offset od sygna³ów
                            for i=1:mod_int_nr-1
                                k=1;
                                for j=1:obj.inputs_nr+1
                                    if j<=obj.inputs_nr
                                        if obj.alternative_model.inputs_to_ident(j)==1
                                            obj.alternative_model.intervals(i).input_signals(k,:)=...
                                                obj.alternative_model.intervals(i).input_signals(k,:)-obj.alternative_model.offset_value(k);
                                            k=k+1;
                                        end
                                    else
                                        obj.alternative_model.intervals(i).output_signal=...
                                            obj.alternative_model.intervals(i).output_signal-obj.alternative_model.offset_value(end);
                                    end
                                end
                                
                            end
                            
                            % opóŸnienie i ograniczenia
                            
                            obj.alternative_model.prev_section_del=prev_section_del;
                            
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.alternative_model.intervals)
                                input_signals_ident=[input_signals_ident obj.alternative_model.intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident obj.alternative_model.intervals(i).output_signal];
                            end
                            
                            plot_cnt=1000+obj.current_model_nr*100+length(obj.ident_models(obj.current_model_nr).intervals);
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                                case 2
                                case 3
                                    obj.alternative_model.model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,plot_cnt);
                                case 4
                                    obj.alternative_model.model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,plot_cnt);
                                case 5
                                    obj.alternative_model.model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,plot_cnt);
                                case 6
                                    obj.alternative_model.model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,plot_cnt);
                                case 7
                                    % oprócz modelu i parametru zwracany
                                    % jest niezerowy stan poczatkowy
                                    [obj.alternative_model.model, obj.alternative_model.model_params, obj.alternative_model.current_initial_state]=...
                                        MD_model_ident_LSM_GS4_nonzero(input_signals_ident,output_signal_ident',plot_cnt);
                                otherwise
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                            end
                            
                            % który w kolejnoœci jest interwa³ z punktem
                            % zerowym
                            op_interval_index=obj.alternative_model_zero_interval-(obj.current_interval-MD_constant_values.new_model_intervals)+1;
                            obj.alternative_model.op_interval_index=op_interval_index;
                            obj.alternative_model.intervals(op_interval_index).initial_state=[];
                            %obj.alternative_model.current_initial_state=zeros(sum(obj.ident_models(1).inputs_to_ident),obj.alternative_model.model_params.m-1);
                            
                            % stan pocz¹tkowy jest ustawiany w pêtli
                            % sukcesywnie dla kolejnych interwa³ów
                            
                            for i=1:length(obj.alternative_model.intervals)
                                
                                if i==op_interval_index
                                    obj.alternative_model.intervals(i).initial_state=zeros(1,obj.alternative_model.model_params.m-1);
                                else
                                    obj.alternative_model.intervals(i).initial_state=obj.alternative_model.current_initial_state;
                                end
                                [obj.alternative_model.intervals(i).simulated_output, obj.alternative_model.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.alternative_model.intervals(i).input_signals,...
                                    obj.alternative_model.intervals(i).initial_state,obj.alternative_model.model); %+obj.ident_models(1).offset_value;
                                
                                obj.alternative_model.intervals(i).model_diff=sumsqr(obj.alternative_model.intervals(i).simulated_output-...
                                    obj.alternative_model.intervals(i).output_signal);
                                obj.alternative_model.intervals(i).model=obj.alternative_model.model;
                                %obj.alternative_model.intervals(i).model_params=obj.alternative_model.model_params;
                            end
                            
                            obj.alternative_model.intervals(op_interval_index)
                            
                            %obj.alternative_model.intervals=obj.alternative_model.intervals(op_interval_index:end);
                            obj.alternative_model.intervals(end+1).initial_state=obj.alternative_model.current_initial_state;
                        end
                        
                    end
                    
                    
                end
                
            end
            
        end
        
        %%
        % Strejc model identification
        
        function ident_Strejc_model_plant(obj,rank_constraint)
            if ~isempty(obj.current_model)
                
                T_end=MD_constant_values.Strejc_ident_time;
                %Strejc_rank=2;
                %n_u=1;
                u=ones(1,T_end+1);
                
                if length(obj.current_model)==1
                    A=obj.current_model.A;
                    B=obj.current_model.B(:,MD_constant_values.Strejc_signal_nr);
                    n=length(A);
                    C=zeros(1,n);
                    C(n)=1;
                    D=0;
                else
                    A=obj.current_model(MD_constant_values.Strejc_signal_nr).A;
                    B=obj.current_model(MD_constant_values.Strejc_signal_nr).B;
                    n=length(A);
                    C=zeros(1,n);
                    C(n)=1;
                    D=0;
                end
                
                state_space=ss(A,B,C,D);
                t=0:1:T_end;
                pv_temp=lsim(state_space,u,t);
                
                signal=pv_temp/pv_temp(end);
                k=pv_temp(end);
                
                figure(8);
                plot(signal);
                
                for i=2:length(signal)-1
                    
                    if signal(i-1)<0.264 && signal(i+1)>0.264
                        t02=i;
                    end
                    
                    if signal(i-1)<0.3233 && signal(i+1)>0.3233
                        t03=i;
                    end
                    
                    if signal(i-1)<0.3527 && signal(i+1)>0.3527
                        t04=i;
                    end
                    
                    if signal(i-1)<0.9 && signal(i+1)>0.9
                        T_90=i;
                    end
                    
                end
                
                T2=0.346054*(T_90-t02);
                tau_2=1.346054*t02-0.346054*T_90;
                %tau_2
                
                T3=0.30099*(T_90-t03);
                tau_3=1.60199*t03-0.60199*T_90;
                %tau_3
                %Strejc_model=tf([1],[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4);
                
                T4=0.27168*(T_90-t04);
                tau_4=1.81504*t04-0.81504*T_90;
                %tau_4
                %Strejc_model=tf([1],[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4);
                
                Strejc_rank=0;
                
                if rank_constraint
                    
                    original_rank=length(A);
                    
                    switch(original_rank)
                        
                        case 2
                            if tau_2>0
                                disp('Strejc model rank 2');
                                Strejc_model=tf(k,[T2^2 2*T2 1],'ioDelay',tau_2)
                                Strejc_rank=2;
                                Strejc_delay=tau_2;
                                Strejc_T=T2;
                                
                                figure(obj.current_interval)
                                plot(t,signal);
                                grid on;
                                hold on;
                                signal_ref=step(tf(1,[T2^2 2*T2 1],'ioDelay',tau_2),t);
                                plot(signal_ref,'r');
                                xlim([0 T_end]);
                                plot(t02,0.264,'r.','MarkerSize',30);
                                plot([0 t02], [0.264 0.264], '--r');
                                plot([t02 t02], [0 0.264], '--r');
                                text(t02,0.264-0.05,('(t_{0n},h_n)'),'FontSize',15);
                                
                                plot([0 T_90], [0.9 0.9], '--r');
                                plot([T_90 T_90], [0 0.9], '--r');
                                text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                                
                                plot(T_90,0.9,'r.','MarkerSize',30);
                                set(gca,'fontsize',15)
                                xlabel('Time [s]','fontsize',15);
                                ylabel('h(t)','fontsize',15);
                                lgd=legend('Identified system','Strejc model',...
                                    'Location','southeast');
                                lgd.FontSize=15;
                                grid on;
                                hold off;
                            else
                                disp('No Strejc model');
                            end
                            
                        case 3
                            
                            if tau_3>0
                                disp('Strejc model rank 3');
                                Strejc_model=tf(k,[T3^3 3*T3^2 3*T3 1],'ioDelay',tau_3)
                                Strejc_rank=3;
                                Strejc_delay=tau_3;
                                Strejc_T=T3;
                                
                                figure(obj.current_interval)
                                plot(t,signal);
                                grid on;
                                hold on;
                                signal_ref=step(tf(1,[T3^3 3*T3^2 3*T3 1],'ioDelay',tau_3),t);
                                plot(signal_ref,'r');
                                xlim([0 T_end]);
                                plot(t03,0.3233,'r.','MarkerSize',30);
                                plot([0 t03], [0.3233 0.3233], '--r');
                                plot([t03 t03], [0 0.3233], '--r');
                                text(t03,0.3233-0.05,('(t_{0n},h_n)'),'FontSize',15);
                                
                                plot([0 T_90], [0.9 0.9], '--r');
                                plot([T_90 T_90], [0 0.9], '--r');
                                text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                                
                                plot(T_90,0.9,'r.','MarkerSize',30);
                                set(gca,'fontsize',15)
                                xlabel('Time [s]','fontsize',15);
                                ylabel('h(t)','fontsize',15);
                                lgd=legend('Identified system','Strejc model',...
                                    'Location','southeast');
                                lgd.FontSize=15;
                                grid on;
                                hold off;
                            else
                                disp('No Strejc model');
                            end
                            
                        case 4
                            
                            if tau_4>0
                                disp('Strejc model rank 4');
                                Strejc_model=tf(k,[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4)
                                Strejc_rank=4;
                                Strejc_delay=tau_4;
                                Strejc_T=T4;
                                
                                figure(obj.current_interval)
                                plot(t,signal);
                                grid on;
                                hold on;
                                signal_ref=step(tf(1,[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4),t);
                                plot(signal_ref,'r');
                                xlim([0 T_end]);
                                plot(t04,0.3527,'r.','MarkerSize',30);
                                plot([0 t04], [0.3527 0.3527], '--r');
                                plot([t04 t04], [0 0.3527], '--r');
                                text(t04,0.3527-0.05,('(t_{0n},h_n)'),'FontSize',15);
                                
                                plot([0 T_90], [0.9 0.9], '--r');
                                plot([T_90 T_90], [0 0.9], '--r');
                                text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                                
                                plot(T_90,0.9,'r.','MarkerSize',30);
                                set(gca,'fontsize',15)
                                xlabel('Time [s]','fontsize',15);
                                ylabel('h(t)','fontsize',15);
                                lgd=legend('Identified system','Strejc model',...
                                    'Location','southeast');
                                lgd.FontSize=15;
                                grid on;
                                hold off;
                            else
                                disp('No Strejc model');
                            end
                            
                        otherwise
                            disp('No Strejc model');
                    end
                    
                else
                    if tau_4>0
                        disp('Strejc model rank 4');
                        Strejc_model=tf(k,[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4)
                        Strejc_rank=4;
                        Strejc_delay=tau_4;
                        Strejc_T=T4;
                        
                        figure(obj.current_interval)
                        plot(t,signal);
                        grid on;
                        hold on;
                        signal_ref=step(tf(1,[T4^4 4*T4^3 6*T4^2 4*T4 1],'ioDelay',tau_4),t);
                        plot(signal_ref,'r');
                        xlim([0 T_end]);
                        plot(t04,0.3527,'r.','MarkerSize',30);
                        plot([0 t04], [0.3527 0.3527], '--r');
                        plot([t04 t04], [0 0.3527], '--r');
                        text(t04,0.3527-0.05,('(t_{0n},h_n)'),'FontSize',15);
                        
                        plot([0 T_90], [0.9 0.9], '--r');
                        plot([T_90 T_90], [0 0.9], '--r');
                        text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                        
                        plot(T_90,0.9,'r.','MarkerSize',30);
                        set(gca,'fontsize',15)
                        xlabel('Time [s]','fontsize',15);
                        ylabel('h(t)','fontsize',15);
                        lgd=legend('Identified system','Strejc model',...
                            'Location','southeast');
                        lgd.FontSize=15;
                        grid on;
                        hold off;
                        
                    elseif tau_3>0
                        disp('Strejc model rank 3');
                        Strejc_model=tf(k,[T3^3 3*T3^2 3*T3 1],'ioDelay',tau_3)
                        Strejc_rank=3;
                        Strejc_delay=tau_3;
                        Strejc_T=T3;
                        
                        figure(obj.current_interval)
                        plot(t,signal);
                        grid on;
                        hold on;
                        signal_ref=step(tf(1,[T3^3 3*T3^2 3*T3 1],'ioDelay',tau_3),t);
                        plot(signal_ref,'r');
                        xlim([0 T_end]);
                        plot(t03,0.3233,'r.','MarkerSize',30);
                        plot([0 t03], [0.3233 0.3233], '--r');
                        plot([t03 t03], [0 0.3233], '--r');
                        text(t03,0.3233-0.05,('(t_{0n},h_n)'),'FontSize',15);
                        
                        plot([0 T_90], [0.9 0.9], '--r');
                        plot([T_90 T_90], [0 0.9], '--r');
                        text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                        
                        plot(T_90,0.9,'r.','MarkerSize',30);
                        set(gca,'fontsize',15)
                        xlabel('Time [s]','fontsize',15);
                        ylabel('h(t)','fontsize',15);
                        lgd=legend('Identified system','Strejc model',...
                            'Location','southeast');
                        lgd.FontSize=15;
                        grid on;
                        hold off;
                        
                        
                    elseif tau_2>0
                        disp('Strejc model rank 2');
                        Strejc_model=tf(k,[T2^2 2*T2 1],'ioDelay',tau_2)
                        Strejc_rank=2;
                        Strejc_delay=tau_2;
                        Strejc_T=T2;
                        
                        figure(obj.current_interval)
                        plot(t,signal);
                        grid on;
                        hold on;
                        signal_ref=step(tf(1,[T2^2 2*T2 1],'ioDelay',tau_2),t);
                        plot(signal_ref,'r');
                        xlim([0 T_end]);
                        plot(t02,0.264,'r.','MarkerSize',30);
                        plot([0 t02], [0.264 0.264], '--r');
                        plot([t02 t02], [0 0.264], '--r');
                        text(t02,0.264-0.05,('(t_{0n},h_n)'),'FontSize',15);
                        
                        plot([0 T_90], [0.9 0.9], '--r');
                        plot([T_90 T_90], [0 0.9], '--r');
                        text(T_90,0.9-0.05,('(T_{90},0.9)'),'FontSize',15);
                        
                        plot(T_90,0.9,'r.','MarkerSize',30);
                        set(gca,'fontsize',15)
                        xlabel('Time [s]','fontsize',15);
                        ylabel('h(t)','fontsize',15);
                        lgd=legend('Identified system','Strejc model',...
                            'Location','southeast');
                        lgd.FontSize=15;
                        grid on;
                        hold off;
                        
                    else
                        disp('No Strejc model');
                    end
                end
                
                if Strejc_rank~=0
                    
                    [num, den]=tfdata(Strejc_model,'v');
                    den=fliplr(den);
                    
                    for i=1:Strejc_rank
                        for j=1:Strejc_rank
                            if i==Strejc_rank
                                A(j,i)=-den(j)/den(Strejc_rank+1);
                            elseif j==i+1
                                A(j,i)=1;
                            else
                                A(j,i)=0;
                            end
                        end
                    end
                    
                    disp('Budowa B');
                    B=zeros(Strejc_rank,1);
                    B(1)=num(end)/den(Strejc_rank+1);
                    
                    disp('Budowa C');
                    for i=1:Strejc_rank
                        for j=1:Strejc_rank
                            if i==j
                                C(i,j)=1;
                            else
                                C(i,j)=0;
                            end
                        end
                    end
                    %C=zeros(1,m-1);
                    %C(end)=1;
                    
                    disp('Budowa D');
                    %D=[0];
                    D=zeros(Strejc_rank,1);
                    
                    obj.current_model_Strejc.A=A;
                    obj.current_model_Strejc.B=B;
                    obj.current_model_Strejc.C=C;
                    obj.current_model_Strejc.D=D;
                    obj.current_model_Strejc.del=round(Strejc_delay);
                    
                    obj.current_model_Strejc.k=k;
                    obj.current_model_Strejc.T=Strejc_T;
                    obj.current_model_Strejc.n=Strejc_rank;
                end
                
            end
        end
        
        %%
        function delete_first_intervals(obj,number_of_intervals_to_delete)
            if length(obj.signals_intervals)>number_of_intervals_to_delete
                obj.signals_intervals=obj.signals_intervals(number_of_intervals_to_delete+1:end);
                obj.current_interval=length(obj.signals_intervals)+1;
            end
        end
        
        %%
        function get_last_intervals(obj,number_of_intervals)
            if length(obj.signals_intervals)>number_of_intervals
                obj.signals_intervals=obj.signals_intervals(end-number_of_intervals+1:end);
                obj.current_interval=length(obj.signals_intervals)+1;
            end
        end
        
        %%
        % Getting multiple signals from file
        
        function get_signals_from_file_ident_interval(obj,start_index,end_index,message)
            
            for i=1:obj.inputs_nr+3
                %obj.signals(i,:)=get_signal_from_file(obj,file_name,start_index,end_index);
                get_signal_from_file_ident_interval(obj,obj.filename,i,start_index,end_index,message);
            end
            
        end
        
        %%
        % Getting single signal from file for ident intervals
        
        function get_signal_from_file_ident_interval(obj,file_name,signal_nr,start_index,end_index,message)
            fid = fopen(file_name);
            varNames = strsplit(fgetl(fid), ';');
            fclose(fid);
            i=1;
            
            signal_name=obj.signals_names(signal_nr);
            signal_cnt=0;
            
            if exist(file_name)==2
                
                if message
                    disp(['File ' file_name ' exists.']);
                end
                
                while i<=length(varNames)
                    if strcmp(varNames{i},signal_name)
                        if message
                            disp(['Signal ' signal_name 'found']);
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
                    
                    obj.signals_intervals(obj.current_interval).original_signals(signal_nr,:)=dlmread(file_name,';',[start_index,...
                        signal_cnt end_index signal_cnt]);
                    obj.signals_intervals(obj.current_interval).op_interval=false;
                    
                else
                    
                    if message
                        disp(['Variable ' signal_name ' does not exist !!!']);
                    end
                end
                
            else
                if meessage
                    disp(['File ' file_name ' does not exist !!!']);
                end
            end
            
        end
        
        %%
        % Getting single signal from file
        
        function read_signal = get_signal_from_file(obj,file_name,signal_nr,start_index,end_index,message)
            fid = fopen(file_name);
            varNames = strsplit(fgetl(fid), ';');
            fclose(fid);
            i=1;
            
            signal_name=obj.signals_names(signal_nr);
            signal_cnt=0;
            
            if exist(file_name,'file')==2
                
                if message
                    disp(['File ' file_name ' exists.']);
                end
                
                while i<=length(varNames)
                    if strcmp(varNames{i},signal_name)
                        if message
                            disp(['Signal ' signal_name 'found']);
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
                    
                    % tu by³ problem !!!!!!!!!!!!!!!!!
                    %signal_cnt
                    %round(start_index)
                    %end_index
                    read_signal=dlmread(file_name,';',[start_index,signal_cnt end_index signal_cnt]);
                    
                else
                    
                    if message
                        disp(['Variable ' signal_name ' does not exist !!!']);
                    end
                end
                
            else
                if meessage
                    disp(['File ' file_name ' does not exist !!!']);
                end
            end
            
        end
        
        
        %%
        function find_operating_point_interval(obj)
            
            threshold=MD_constant_values.threshold_lin;
            mean_interval=MD_constant_values.mean_interval_lin;
            h_lin=MD_constant_values.h_lin;
            step_=MD_constant_values.MFM_step;
            m_lin=MD_constant_values.m_lin;
            N_lin=MD_constant_values.N_lin;
            M_lin=MD_constant_values.M_lin;
            
            
            mod_func_lin=MD_modulating_func(0:step_:h_lin,h_lin,N_lin,M_lin);
            mod_func_lin=mod_func_lin(2:end);
            max_mod_lin=max(mod_func_lin);
            mod_func_lin=mod_func_lin/max_mod_lin;
            
            for i=1:m_lin-1
                mod_func_d_lin(i,:)=(1/max_mod_lin)*MD_modulating_func_d(i,0:step_:h_lin,h_lin,N_lin,M_lin);
            end
            
            mod_func_d_lin=mod_func_d_lin(:,2:end);
            
            current_out=obj.signals_intervals(obj.current_interval).original_signals(end-2,1:end);
            
            cnt1=1;
            y_dot_lin=[];
            
            while cnt1<length(current_out)
                cnt1=cnt1+1;
                
                if cnt1 > h_lin/step_
                    
                    current_out_lin=current_out(cnt1-h_lin/step_:cnt1);
                    
                    for i=1:m_lin
                        if i==1
                            con=conv(current_out_lin,mod_func_lin);
                            con=con(1:floor(length(con)/2));
                            s(i)=con(end);
                        else
                            con=conv(current_out_lin,mod_func_d_lin(i-1,:));
                            con=con(1:floor(length(con)/2));
                            s(i)=con(end);
                        end
                    end
                    
                    y_dot_lin=[y_dot_lin s'];
                    
                    if length(y_dot_lin)>mean_interval &&...
                            (mean(abs(y_dot_lin(2,end-mean_interval:end)))<threshold) &&...
                            (mean(abs(y_dot_lin(3,end-mean_interval:end)))<threshold) %&&...
                        %(mean(abs(y_dot_lin(4,end-mean_interval:end)))<threshold) %&&...
                        %(mean(abs(y_dot_lin(5,end-mean_interval:end)))<threshold);
                        
                        lin_point=cnt1-floor(mean_interval/2);
                        start_int=max(1,obj.current_interval-MD_constant_values.min_op_diff);
                        
                        prev_interval=zeros(1,MD_constant_values.min_op_diff);
                        
                        for i=start_int:obj.current_interval
                            if obj.signals_intervals(i).op_interval
                                prev_interval(i-start_int+1)=1;
                            end
                        end
                        
                        if sum(prev_interval)==0
                            obj.signals_intervals(obj.current_interval).op_interval=true;
                            obj.signals_intervals(obj.current_interval).op_time=obj.signals_intervals(obj.current_interval).time(1)+lin_point;
                            obj.signals_intervals(obj.current_interval).op_time_file=obj.signals_intervals(obj.current_interval).time_start_file+lin_point;
                        end
                        
                        break;
                    end
                end
            end
        end
        
        %%
        function define_model_inputs_intervals(obj)
            obj.signals_intervals(obj.current_interval).model_inputs=zeros(1,obj.inputs_nr);
            for i=1:obj.inputs_nr
                if var(obj.signals_intervals(obj.current_interval).original_signals(i,:))>MD_constant_values.var_threshold;
                    obj.signals_intervals(obj.current_interval).model_inputs(i)=1;
                end
            end
        end
        
        %%
        function delete_current_model(obj)
            obj.current_model=[];
        end
        
        %%
        function ident_model(obj)
            if isempty(obj.current_model)
                % identifying the first model
                
                % check if operating point can be found
                
                if obj.current_interval-1>=MD_constant_values.init_model_intervals
                    
                    op_found=0;
                    
                    for i=1:obj.current_interval-1
                        if obj.signals_intervals(i).op_interval==true
                            %disp(['OP found ' num2str(i)]);
                            disp('---------------------------------------------------');
                            disp(['OP found ' num2str(i)]);
                            disp('---------------------------------------------------');
                            op_found=1;
                            %op_time=obj.signals_intervals(i).op_time;
                            op_time_file=obj.signals_intervals(i).op_time_file;
                            prev_section_del=obj.signals_intervals(i).prev_section_del;
                            obj.current_zero_point_interval=i;
                            break;
                        elseif i==obj.current_interval-1
                            disp('OP not found');
                            op_found=0;
                        end
                    end
                    
                    if op_found && obj.current_interval-obj.current_zero_point_interval>=MD_constant_values.init_model_intervals  %tutaj zmiana przy ewentualnym innym sposobie initial point
                        
                        %check which inputs can be identified
                        obj.ident_models(1).intervals_sim=[];
                        obj.ident_models(1).inputs_to_ident=zeros(obj.inputs_nr,1);
                        
                        sum_temp=0;
                        %sum_temp_prev=0;
                        ident_offset_intervals=0;
                        
                        %zmiana 13.09
                        ident_intervals=zeros(obj.inputs_nr,1);
                        
                        for i=obj.current_zero_point_interval:obj.current_interval-1
                            
                            %obj.ident_models(1).inputs_to_ident
                            
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    %obj.ident_models(1).inputs_to_ident(j)=1;
                                    ident_intervals(j)=ident_intervals(j)+1;
                                end
                            end
                            
                            %{
                            if sum(obj.signals_intervals(i).model_inputs)==MD_constant_values.min_inputs_ident
                                ident_intervals=ident_intervals+1;
                            end
                            %}
                            
                            sum_temp=sum_temp+sum(ident_intervals);
                            
                            %obj.ident_models(1).inputs_to_ident
                            %sum_temp
                            
                            if sum_temp==0 %&& sum_temp_prev==0;
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                            %sum_temp_prev=sum_temp;
                        end
                        
                        %enough_ident_intervals=true;
                        
                        %zmiana 13.09
                        for j=1:obj.inputs_nr
                            if ident_intervals(j)>=MD_constant_values.new_model_min_inputs
                                obj.ident_models(1).inputs_to_ident(j)=1;
                            end
                            
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        for i=obj.current_zero_point_interval:obj.current_interval-1
                            
                            mod_int_nr=i-obj.current_zero_point_interval+1;
                            
                            if obj.signals_intervals(i).time_end_file>op_time_file
                                if obj.signals_intervals(i).time_start_file>op_time_file
                                    start_time_file=obj.signals_intervals(i).time_start_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).time(1);
                                    end_time=obj.signals_intervals(i).time(end);
                                else
                                    start_time_file=op_time_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).op_time;
                                    end_time=obj.signals_intervals(i).time(end);
                                end
                            end
                            
                            input_signals=[];
                            
                            if sum(obj.ident_models(1).inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                n=1;
                                for j=1:obj.inputs_nr
                                    if obj.ident_models(1).inputs_to_ident(j)
                                        if j==1
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,1,...
                                                start_time_file-prev_section_del,end_time_file-prev_section_del,MD_constant_values.message_display);
                                            
                                            if i==obj.current_zero_point_interval
                                                obj.ident_models(1).offset_value(n)=input_signals(1,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(1).offset_value(n);
                                            
                                        else
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,j,...
                                                start_time_file,end_time_file,MD_constant_values.message_display);
                                            
                                            if i==obj.current_zero_point_interval
                                                obj.ident_models(1).offset_value(n)=input_signals(n,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(1).offset_value(n);
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                
                                obj.ident_models(1).intervals(mod_int_nr).input_signals=input_signals;
                                
                                output_signal=obj.get_signal_from_file(obj.filename,obj.inputs_nr+1,...
                                    start_time_file,end_time_file,MD_constant_values.message_display);
                                
                                if i==obj.current_zero_point_interval
                                    obj.ident_models(1).offset_value(n)=output_signal(1);
                                end
                                
                                output_signal=output_signal-obj.ident_models(1).offset_value(n);
                                
                                obj.ident_models(1).intervals(mod_int_nr).output_signal=output_signal;
                                obj.ident_models(1).intervals(mod_int_nr).time=start_time:end_time;
                                obj.ident_models(1).intervals(mod_int_nr).interval_type='I';
                                
                            end
                        end
                        
                        % enough_ident_intervals %tylko bylo
                        if sum(obj.ident_models(1).inputs_to_ident)>=MD_constant_values.min_inputs_ident %&& ident_intervals>2
                            
                            %ident_intervals
                            
                            obj.ident_models(1).prev_section_del=prev_section_del;
                            obj.current_delay=obj.ident_models(1).prev_section_del;
                            %MISO_eta=ones(MD_constant_values.m+MD_constant_values.n*sum(obj.ident_models(1).inputs_to_ident),1);
                            
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.ident_models(1).intervals)
                                input_signals_ident=[input_signals_ident obj.ident_models(1).intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident; obj.ident_models(1).intervals(i).output_signal];
                            end
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.current_model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,obj.current_model_nr*100);
                                case 2
                                case 3
                                    obj.current_model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 4
                                    obj.current_model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 5
                                    obj.current_model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 6
                                    obj.current_model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                case 7
                                    %[obj.current_model, obj.current_model_params]=MD_model_ident_LSM_GS4(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                    [obj.current_model, obj.current_model_params]=MD_model_ident_LSM_GS5(input_signals_ident,output_signal_ident,obj.current_model_nr*100);
                                otherwise
                                    obj.current_model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,obj.current_model_nr*100);
                            end
                            
                            
                            obj.ident_models(1).intervals(1).initial_state=[];
                            obj.current_initial_state=zeros(size(obj.current_model,2),obj.current_model_params.m-1);
                            
                            for i=1:length(obj.ident_models(1).intervals)
                                obj.ident_models(1).intervals(i).initial_state=obj.current_initial_state;
                                [obj.ident_models(1).intervals(i).simulated_output, obj.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.ident_models(1).intervals(i).input_signals,obj.current_initial_state,obj.current_model,0); %+obj.ident_models(1).offset_value;
                                %obj.initial_states=[obj.initial_states obj.current_initial_state];
                                
                                obj.ident_models(1).intervals(i).model_diff=sumsqr(obj.ident_models(1).intervals(i).simulated_output-...
                                    obj.ident_models(1).intervals(i).output_signal');
                                
                                obj.ident_models(1).intervals(i).model=obj.current_model;
                                %obj.ident_models(1).intervals(i).model_params=obj.current_model_params;
                                
                            end
                            
                            %zmiana model params
                            obj.ident_models(1).model_params=obj.current_model_params;
                            
                            % zmiana 11.06.2020
                            if MD_constant_values.initial_state_method
                                obj.current_initial_state=obj.obtain_system_state(input_signals_ident,output_signal_ident,MD_constant_values.T_ob);
                                obj.ident_models(1).intervals(i+1).initial_state=obj.current_initial_state;
                            else
                                obj.ident_models(1).intervals(i+1).initial_state=obj.current_initial_state;
                            end
                            
                        end
                        
                    end
                    
                end
            else
                
                % updating the current model parameters
                
                if MD_constant_values.change_model
                    
                    % check if the difference between model and system is
                    % greater than change threshold
                    
                    if obj.ident_models(obj.current_model_nr).intervals(end-1).model_diff>MD_constant_values.model_change_threshold
                        
                        initial_int=max(1,length(obj.ident_models(obj.current_model_nr).intervals)-MD_constant_values.ident_intervals);
                        
                        ident_initial_state=obj.ident_models(obj.current_model_nr).intervals(initial_int).initial_state;
                        
                        input_signals_ident=[];
                        output_signal_ident=[];
                        
                        for i=initial_int:length(obj.ident_models(obj.current_model_nr).intervals)-1
                            input_signals_ident=[input_signals_ident obj.ident_models(obj.current_model_nr).intervals(i).input_signals];
                            output_signal_ident=[output_signal_ident; obj.ident_models(obj.current_model_nr).intervals(i).output_signal];
                        end
                        
                        %MISO_eta=ones(MD_constant_values.m+MD_constant_values.n*sum(obj.ident_models(1).inputs_to_ident),1);
                        
                        iter=100*obj.current_model_nr+length(obj.ident_models(obj.current_model_nr).intervals);
                        
                        switch MD_constant_values.ident_mode
                            case 1
                                [interval_type, reident_model]=MD_MISO_model_reident(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,MISO_eta,ident_initial_state,iter);
                            case 2
                            case 3
                                ident_initial_state=ident_initial_state(1,:);
                                [interval_type, reident_model]=MD_model_reident_LSM(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,ident_initial_state,iter);
                            case 4
                                %ident_initial_state=ident_initial_state(1,:);
                                [interval_type, reident_model]=MD_model_reident_LSM_GS(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,ident_initial_state,iter);
                            case 5
                                
                            case 6
                                
                            case 7
                                
                                if(size(ident_initial_state,1))~=size(obj.current_model,2)
                                    disp('OTHER INITIAL STATE NEEDED');
                                    %interval_type='N';
                                    
                                    if sum(ident_initial_state(1,:))==0
                                        ident_initial_state=zeros(size(obj.current_model,2),obj.current_model_params.m-1);
                                        [interval_type, reident_model]=MD_model_reident_LSM_GS4(obj.current_model,obj.current_model_params,...
                                            obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                            input_signals_ident,output_signal_ident,ident_initial_state,iter);
                                    elseif MD_constant_values.initial_state_method
                                        interval_type='N';
                                    else
                                        interval_type='N';
                                    end
                                    
                                else
                                    [interval_type, reident_model]=MD_model_reident_LSM_GS4(obj.current_model,obj.current_model_params,...
                                        obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                        input_signals_ident,output_signal_ident,ident_initial_state,iter);
                                end
                                
                                
                                
                            otherwise
                                [interval_type, reident_model]=MD_MISO_model_reident(obj.current_model,obj.ident_models(obj.current_model_nr).inputs_to_ident,...
                                    input_signals_ident,output_signal_ident,MISO_eta,ident_initial_state,iter);
                        end
                        
                        if interval_type~='N'
                            disp('---------------------------------------------------');
                            disp('MODEL UPDATE');
                            disp('---------------------------------------------------');
                            obj.ident_models(obj.current_model_nr).intervals(end).interval_type='R';
                            obj.current_model=reident_model;
                            obj.current_initial_state=obj.obtain_system_state(input_signals_ident,output_signal_ident,MD_constant_values.T_ob);
                            obj.ident_models(obj.current_model_nr).intervals(end).initial_state=obj.current_initial_state;
                            obj.ident_models(obj.current_model_nr).intervals(end).model=reident_model;
                            %obj.ident_models(obj.current_model_nr).intervals(end).model_params=obj.current_model_params;
                        end
                        
                        %zmiana model params
                        obj.ident_models(obj.current_model_nr).model_params=obj.current_model_params;
                        
                    else
                        
                    end
                    
                end
            end
        end
        
        %%
        function ident_alternative_model(obj)
            if ~isempty(obj.current_model) && isempty(obj.alternative_model)
                
                %find the new operating point
                op_found=0;
                
                sum_temp=0;
                ident_offset_intervals=0;
                ident_intervals=0;
                
                disp(['Finding OP alternative ' num2str(obj.current_interval-MD_constant_values.new_model_intervals) ' ' num2str(obj.current_interval-1)]);
                for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                    if obj.signals_intervals(i).op_interval==true && i~=obj.current_zero_point_interval
                        disp('---------------------------------------------------');
                        disp(['OP alternative found ' num2str(i)]);
                        disp('---------------------------------------------------');
                        op_found=1;
                        op_time=obj.signals_intervals(i).op_time;
                        op_time_file=obj.signals_intervals(i).op_time_file;
                        prev_section_del=obj.signals_intervals(i).prev_section_del;
                        obj.alternative_model_zero_interval=i;
                        break;
                    elseif i==obj.current_interval-1
                        disp('OP alternative not found');
                        op_found=0;
                    end
                end
                
                if MD_constant_values.alternative_model_method==0
                    
                    % zero interval jako pierwszy
                    
                    if op_found && (obj.current_interval-obj.alternative_model_zero_interval)>=MD_constant_values.new_model_intervals
                        %obj.alternative_model=1;
                        
                        inputs_to_ident=zeros(obj.inputs_nr,1);
                        sum_temp=0;
                        ident_offset_intervals=0;
                        
                        %zmiana 13.09
                        ident_intervals=zeros(obj.inputs_nr,1);
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    %inputs_to_ident(j)=1;
                                    ident_intervals(j)=ident_intervals(j)+1;
                                end
                                %ident_intervals(j)=ident_intervals(j)+1;
                            end
                            
                            sum_temp=sum_temp+sum(ident_intervals);
                            if sum_temp==0
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                        end
                        
                        %enough_ident_intervals=true;
                        
                        %zmiana 13.09
                        %zmiana 13.09
                        for j=1:obj.inputs_nr
                            if ident_intervals(j)>=MD_constant_values.new_model_min_inputs
                                inputs_to_ident(j)=1;
                            end
                        end
                        
                        for i=obj.alternative_model_zero_interval:obj.current_interval-1
                            mod_int_nr=i-obj.alternative_model_zero_interval+1;
                            
                            if obj.signals_intervals(i).time_end_file>op_time_file
                                if obj.signals_intervals(i).time_start_file>op_time_file
                                    start_time_file=obj.signals_intervals(i).time_start_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).time(1);
                                    end_time=obj.signals_intervals(i).time(end);
                                else
                                    start_time_file=op_time_file;
                                    end_time_file=obj.signals_intervals(i).time_end_file;
                                    
                                    start_time=obj.signals_intervals(i).op_time;
                                    end_time=obj.signals_intervals(i).time(end);
                                end
                            end
                            
                            input_signals=[];
                            
                            
                            if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                
                                obj.alternative_model.inputs_to_ident=inputs_to_ident;
                                n=1;
                                
                                for j=1:obj.inputs_nr
                                    if obj.alternative_model.inputs_to_ident(j)
                                        if j==1
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,1,...
                                                start_time_file-prev_section_del,end_time_file-prev_section_del,MD_constant_values.message_display);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(1,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.alternative_model.offset_value(n);
                                            
                                        else
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,j,...
                                                start_time_file,end_time_file,MD_constant_values.message_display);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(n,1);
                                            end
                                            
                                            input_signals(n,:)=input_signals(n,:)-obj.alternative_model.offset_value(n);
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                
                                obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                
                                output_signal=obj.get_signal_from_file(obj.filename,obj.inputs_nr+1,...
                                    start_time_file,end_time_file,MD_constant_values.message_display);
                                
                                if i==obj.alternative_model_zero_interval
                                    obj.alternative_model.offset_value(n)=output_signal(1);
                                end
                                
                                output_signal=output_signal-obj.alternative_model.offset_value(n);
                                
                                obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                %}
                                
                            end
                        end
                        
                        if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident %&& enough_ident_intervals  %ident_intervals>=MD_constant_values.init_model_intervals %enough_ident_intervals
                            
                            obj.alternative_model.prev_section_del=prev_section_del;
                            %MISO_eta=ones(MD_constant_values.m+MD_constant_values.n*sum(obj.alternative_model.inputs_to_ident),1);
                            
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.alternative_model.intervals)
                                input_signals_ident=[input_signals_ident obj.alternative_model.intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident; obj.alternative_model.intervals(i).output_signal];
                            end
                            
                            %obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,1111);
                            plot_cnt=1000+obj.current_model_nr*100+length(obj.ident_models(obj.current_model_nr).intervals);
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                                case 2
                                case 3
                                    obj.alternative_model.model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,plot_cnt);
                                case 4
                                    obj.alternative_model.model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,plot_cnt);
                                case 5
                                    obj.alternative_model.model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,plot_cnt);
                                case 6
                                    obj.alternative_model.model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,plot_cnt);
                                case 7
                                    [obj.alternative_model.model, obj.alternative_model.model_params]=MD_model_ident_LSM_GS4(input_signals_ident,output_signal_ident,plot_cnt);
                                otherwise
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                            end
                            
                            obj.alternative_model.intervals(1).initial_state=[];
                            obj.alternative_model.current_initial_state=zeros(sum(obj.ident_models(1).inputs_to_ident),obj.alternative_model.model_params.m-1);
                            
                            for i=1:length(obj.alternative_model.intervals)
                                obj.alternative_model.intervals(i).initial_state=obj.alternative_model.current_initial_state;
                                [obj.alternative_model.intervals(i).simulated_output, obj.alternative_model.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.alternative_model.intervals(i).input_signals,obj.alternative_model.current_initial_state,obj.alternative_model.model,0); %+obj.ident_models(1).offset_value;
                                
                                obj.alternative_model.intervals(i).model_diff=sumsqr(obj.alternative_model.intervals(i).simulated_output-...
                                    obj.alternative_model.intervals(i).output_signal');
                                obj.alternative_model.intervals(i).model=obj.alternative_model.model;
                                %obj.alternative_model.intervals(i).model_params=obj.alternative_model.model_params;
                            end
                            
                            % stan pocz¹tkowy jest ustawiany w pêtli
                            % sukcesywnie dla kolejnych interwa³ów
                            obj.alternative_model.intervals(i+1).initial_state=obj.alternative_model.current_initial_state;
                            
                            % zmiana 12.09
                            obj.alternative_model.intervals_sim=[];
                            
                        end
                        
                    end
                    
                else
                    
                    % zero interval w srodku
                    if op_found %&& obj.current_interval>=MD_constant_values.new_model_intervals
                        
                        inputs_to_ident=zeros(obj.inputs_nr,1);
                        sum_temp=0;
                        ident_offset_intervals=0;
                        
                        %zmiana 13.09
                        ident_intervals=zeros(obj.inputs_nr,1);
                        
                        
                        % sprawdŸ wejscia dla nowego modelu i ewentualnie
                        % interwa³y w których nie ma zmian (ident_offset_intervals)
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            for j=1:obj.inputs_nr
                                if obj.signals_intervals(i).model_inputs(j)
                                    %inputs_to_ident(j)=1;
                                    ident_intervals(j)=ident_intervals(j)+1;
                                end
                            end
                            
                            sum_temp=sum_temp+sum(ident_intervals);
                            if sum_temp==0
                                ident_offset_intervals=ident_offset_intervals+1;
                            end
                            
                            
                            
                        end
                        
                        %{
                        enough_ident_intervals=true;
                        %zmiana 13.09
                        for j=1:obj.inputs_nr
                            if ident_intervals(j)<MD_constant_values.new_model_min_inputs
                                enough_ident_intervals=false;
                                break;
                            end
                            
                        end
                        %}
                        
                        %zmiana 13.09
                        for j=1:obj.inputs_nr
                            if ident_intervals(j)>=MD_constant_values.new_model_min_inputs
                                inputs_to_ident(j)=1;
                            end
                            
                        end
                        
                        ident_offset_intervals=0; % bez interwa³ów offsetowych
                        % pobierz sygnaly wejœciowe i wyjœciowe do
                        % identyfikacji
                        mod_int_nr=1;
                        
                        for i=obj.current_interval-MD_constant_values.new_model_intervals:obj.current_interval-1
                            
                            start_time_file=obj.signals_intervals(i).time_start_file;
                            end_time_file=obj.signals_intervals(i).time_end_file;
                            
                            start_time=obj.signals_intervals(i).time(1);
                            end_time=obj.signals_intervals(i).time(end);
                            
                            
                            input_signals=[];
                            
                            if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident  % sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                                
                                obj.alternative_model.inputs_to_ident=inputs_to_ident;
                                n=1;
                                
                                for j=1:obj.inputs_nr
                                    if obj.alternative_model.inputs_to_ident(j)
                                        if j==1
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,1,...
                                                start_time_file-prev_section_del,end_time_file-prev_section_del,MD_constant_values.message_display);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(1,op_time-start_time);
                                            end
                                            
                                        else
                                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,j,...
                                                start_time_file,end_time_file,MD_constant_values.message_display);
                                            
                                            if i==obj.alternative_model_zero_interval
                                                obj.alternative_model.offset_value(n)=input_signals(n,op_time-start_time);
                                            end
                                            
                                        end
                                        n=n+1;
                                    end
                                end
                                
                                
                                
                                output_signal=obj.get_signal_from_file(obj.filename,obj.inputs_nr+1,...
                                    start_time_file,end_time_file,MD_constant_values.message_display);
                                
                                if i==obj.alternative_model_zero_interval
                                    obj.alternative_model.offset_value(n)=output_signal(op_time-start_time);
                                    obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                    obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                    obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                    obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                else
                                    obj.alternative_model.intervals(mod_int_nr).input_signals=input_signals;
                                    obj.alternative_model.intervals(mod_int_nr).output_signal=output_signal;
                                    obj.alternative_model.intervals(mod_int_nr).time=start_time:end_time;
                                    obj.alternative_model.intervals(mod_int_nr).interval_type='I';
                                end
                                
                            end
                            
                            mod_int_nr=mod_int_nr+1;
                        end
                        
                        if sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident && length(obj.alternative_model.intervals) %ident_intervals>=MD_constant_values.new_model_min_inputs  % sum(inputs_to_ident)>=MD_constant_values.min_inputs_ident
                            obj.alternative_model.offset_value
                            
                            for i=1:mod_int_nr-1
                                k=1;
                                for j=1:obj.inputs_nr+1
                                    if j<=obj.inputs_nr
                                        if obj.alternative_model.inputs_to_ident(j)==1
                                            obj.alternative_model.intervals(i).input_signals(k,:)=...
                                                obj.alternative_model.intervals(i).input_signals(k,:)-obj.alternative_model.offset_value(k);
                                            k=k+1;
                                        end
                                    else
                                        obj.alternative_model.intervals(i).output_signal=...
                                            obj.alternative_model.intervals(i).output_signal-obj.alternative_model.offset_value(end);
                                    end
                                end
                                
                            end
                            
                            % opóŸnienie i ograniczenia
                            
                            obj.alternative_model.prev_section_del=prev_section_del;
                            
                            input_signals_ident=[];
                            output_signal_ident=[];
                            
                            % build long signals for model identification
                            for i=1+ident_offset_intervals:length(obj.alternative_model.intervals)
                                input_signals_ident=[input_signals_ident obj.alternative_model.intervals(i).input_signals];
                                output_signal_ident=[output_signal_ident; obj.alternative_model.intervals(i).output_signal];
                            end
                            
                            %obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,1111);
                            plot_cnt=1000+obj.current_model_nr*100+length(obj.ident_models(obj.current_model_nr).intervals);
                            
                            
                            switch MD_constant_values.ident_mode
                                case 1
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                                case 2
                                case 3
                                    obj.alternative_model.model=MD_model_ident_LSM(input_signals_ident,output_signal_ident,plot_cnt);
                                case 4
                                    obj.alternative_model.model=MD_model_ident_LSM_GS(input_signals_ident,output_signal_ident,plot_cnt);
                                case 5
                                    obj.alternative_model.model=MD_model_ident_LSM_GS2(input_signals_ident,output_signal_ident,plot_cnt);
                                case 6
                                    obj.alternative_model.model=MD_model_ident_LSM_GS3(input_signals_ident,output_signal_ident,plot_cnt);
                                case 7
                                    % oprócz modelu i parametru zwracany
                                    % jest niezerowy stan poczatkowy
                                    [obj.alternative_model.model, obj.alternative_model.model_params, obj.alternative_model.current_initial_state]=...
                                        MD_model_ident_LSM_GS4_nonzero(input_signals_ident,output_signal_ident,plot_cnt);
                                otherwise
                                    obj.alternative_model.model=MD_MISO_model_ident(input_signals_ident,output_signal_ident,MISO_eta,plot_cnt);
                            end
                            
                            % który w kolejnoœci jest interwa³ z punktem
                            % zerowym
                            op_interval_index=obj.alternative_model_zero_interval-(obj.current_interval-MD_constant_values.new_model_intervals)+1;
                            obj.alternative_model.op_interval_index=op_interval_index;
                            obj.alternative_model.intervals(op_interval_index).initial_state=[];
                            %obj.alternative_model.current_initial_state=zeros(sum(obj.ident_models(1).inputs_to_ident),obj.alternative_model.model_params.m-1);
                            
                            % stan pocz¹tkowy jest ustawiany w pêtli
                            % sukcesywnie dla kolejnych interwa³ów
                            
                            for i=1:length(obj.alternative_model.intervals)
                                
                                if i==op_interval_index
                                    obj.alternative_model.intervals(i).initial_state=zeros(1,obj.alternative_model.model_params.m-1);
                                else
                                    obj.alternative_model.intervals(i).initial_state=obj.alternative_model.current_initial_state;
                                end
                                [obj.alternative_model.intervals(i).simulated_output, obj.alternative_model.current_initial_state]=...
                                    MD_simulate_MISO_system_output(obj.alternative_model.intervals(i).input_signals,...
                                    obj.alternative_model.intervals(i).initial_state,obj.alternative_model.model); %+obj.ident_models(1).offset_value;
                                
                                obj.alternative_model.intervals(i).model_diff=sumsqr(obj.alternative_model.intervals(i).simulated_output-...
                                    obj.alternative_model.intervals(i).output_signal');
                                obj.alternative_model.intervals(i).model=obj.alternative_model.model;
                                %obj.alternative_model.intervals(i).model_params=obj.alternative_model.model_params;
                            end
                            
                            obj.alternative_model.intervals(op_interval_index)
                            
                            %obj.alternative_model.intervals=obj.alternative_model.intervals(op_interval_index:end);
                            obj.alternative_model.intervals(end+1).initial_state=obj.alternative_model.current_initial_state;
                            
                            % zmiana 12.09
                            obj.alternative_model.intervals_sim=[];
                            
                        end
                        
                    end
                    
                    
                end
                
            end
            
        end
        
        %%
        
        function select_best_model(obj)
            if  ~isempty(obj.current_model) &&  ~isempty(obj.alternative_model)
                
                intervals_nr=min(length(obj.alternative_model.intervals)-1,length(obj.ident_models(obj.current_model_nr).intervals)-1);
                interval_start=length(obj.ident_models(obj.current_model_nr).intervals)-intervals_nr;
                
                sum_original=0;
                sum_alternative=0;
                
                for i=interval_start:interval_start+intervals_nr-1;
                    sum_original=sum_original+obj.ident_models(obj.current_model_nr).intervals(i).model_diff;
                end
                
                for i=length(obj.alternative_model.intervals)-intervals_nr:length(obj.alternative_model.intervals)-1,
                    sum_alternative=sum_alternative+obj.alternative_model.intervals(i).model_diff;
                end
                
                if sum_alternative<sum_original
                    
                    % swap models
                    obj.current_model_nr=obj.current_model_nr+1;
                    
                    obj.current_model=obj.alternative_model.model;
                    obj.current_model_params=obj.alternative_model.model_params;
                    obj.ident_models(obj.current_model_nr).inputs_to_ident=obj.alternative_model.inputs_to_ident;
                    obj.ident_models(obj.current_model_nr).offset_value=obj.alternative_model.offset_value;
                    obj.ident_models(obj.current_model_nr).prev_section_del=obj.alternative_model.prev_section_del;
                    obj.current_delay=obj.alternative_model.prev_section_del;
                    
                    if MD_constant_values.alternative_model_method==0
                        obj.ident_models(obj.current_model_nr).intervals=obj.alternative_model.intervals;
                    else
                        % tylko interwa³y od zerowego sa przepisywane
                        obj.ident_models(obj.current_model_nr).intervals=obj.alternative_model.intervals(obj.alternative_model.op_interval_index:end);
                        obj.ident_models(obj.current_model_nr).intervals
                    end
                    
                    obj.current_initial_state=obj.ident_models(obj.current_model_nr).intervals(end).initial_state;
                    
                    obj.ident_models(obj.current_model_nr).model_params=obj.alternative_model.model_params;
                    obj.ident_models(obj.current_model_nr).intervals_sim=obj.alternative_model.intervals_sim;
                    
                    %obj.ident_models(1).intervals(i+1).initial_state=obj.current_initial_state;
                    disp('---------------------------------------------------');
                    disp('NEW MODEL WILL BE APPLIED');
                    disp('---------------------------------------------------');
                else
                    disp('---------------------------------------------------');
                    disp('NEW MODEL WILL NOT BE APPLIED');
                    disp('---------------------------------------------------');
                end
                
                obj.alternative_model=[];
                
            end
        end
        
        %%
        
        function simulate_model_output(obj,time_start,time_end)
            
            if ~isempty(obj.current_model)
                n=1;
                
                time_start_ob=time_end-MD_constant_values.T_ob+1;
                
                for j=1:obj.inputs_nr
                    if obj.ident_models(obj.current_model_nr).inputs_to_ident(j)
                        if j==1
                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,1,...
                                time_start-obj.ident_models(obj.current_model_nr).prev_section_del,...
                                time_end-obj.ident_models(obj.current_model_nr).prev_section_del,MD_constant_values.message_display);
                            
                            input_signals_ob(n,:)=obj.get_signal_from_file(obj.filename,1,...
                                time_start_ob-obj.ident_models(obj.current_model_nr).prev_section_del,...
                                time_end-obj.ident_models(obj.current_model_nr).prev_section_del,MD_constant_values.message_display);
                            
                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            input_signals_ob(n,:)=input_signals_ob(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                        else
                            input_signals(n,:)=obj.get_signal_from_file(obj.filename,j,...
                                time_start,time_end,MD_constant_values.message_display);
                            
                            input_signals_ob(n,:)=obj.get_signal_from_file(obj.filename,j,...
                                time_start_ob,time_end,MD_constant_values.message_display);
                            
                            input_signals(n,:)=input_signals(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            input_signals_ob(n,:)=input_signals_ob(n,:)-obj.ident_models(obj.current_model_nr).offset_value(n);
                            
                        end
                        n=n+1;
                    end
                end
                
                pos=length(obj.ident_models(obj.current_model_nr).intervals);
                
                obj.ident_models(obj.current_model_nr).intervals(pos).input_signals=input_signals;
                obj.ident_models(obj.current_model_nr).intervals(pos).time=...
                    obj.ident_models(obj.current_model_nr).intervals(end-1).time(end)+1:obj.ident_models(obj.current_model_nr).intervals(end-1).time(end)+time_end-time_start+1;
                
                output_signal=obj.get_signal_from_file(obj.filename,obj.inputs_nr+1,time_start,time_end,MD_constant_values.message_display);
                output_signal_ob=obj.get_signal_from_file(obj.filename,obj.inputs_nr+1,time_start_ob,time_end,MD_constant_values.message_display);
                output_signal=output_signal-obj.ident_models(obj.current_model_nr).offset_value(end);
                output_signal_ob=output_signal_ob-obj.ident_models(obj.current_model_nr).offset_value(end);
                
                obj.ident_models(obj.current_model_nr).intervals(pos).output_signal=output_signal;
                
                %obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output=output_signal;
                
                [simulated_output, obj.current_initial_state]=...
                    MD_simulate_MISO_system_output(input_signals,obj.current_initial_state,obj.current_model,0); %+obj.ident_intervals(1).offset_value;
                
                if MD_constant_values.initial_state_method
                    obj.current_initial_state=obj.obtain_system_state(input_signals_ob,output_signal_ob',MD_constant_values.T_ob);
                end
                
                obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output=simulated_output;
                obj.ident_models(obj.current_model_nr).intervals(pos).model_diff=sumsqr(obj.ident_models(obj.current_model_nr).intervals(pos).simulated_output-...
                    obj.ident_models(obj.current_model_nr).intervals(pos).output_signal');
                obj.ident_models(obj.current_model_nr).intervals(end+1).initial_state=obj.current_initial_state;
                
                
                %zmiana 12.09
                obj.ident_models(obj.current_model_nr).intervals_sim=[obj.ident_models(obj.current_model_nr).intervals_sim obj.current_interval-1];
                
            end
            
        end
        
        %%
        function system_state=obtain_system_state(obj,sys_inputs,sys_output,ident_horizon)
            
            current_inputs_nr=min(size(sys_inputs));
            
            switch MD_constant_values.ident_mode
                case 1
                    n=length(obj.current_model(1).A);
                    C_=[];
                    D_=[];
                    
                    for i=1:current_inputs_nr
                        g_=zeros(1,n);
                        g_(end)=1;
                        C_=[C_ g_];
                        D_=[D_ 0];
                    end
                    
                    A_=blkdiag(obj.current_model.A);
                    B_=blkdiag(obj.current_model.B);
                    
                    state_space.A=A_;
                    state_space.B=B_;
                    state_space.C=C_;
                    state_space.D=D_;
                    
                case 2
                    
                case 3
                    n=length(obj.current_model(1).A);
                    
                    C_=zeros(1,n);
                    C_(end)=1;
                    D_=zeros(1,current_inputs_nr);
                    
                    state_space.A=obj.current_model.A;
                    state_space.B=obj.current_model.B;
                    state_space.C=C_;
                    state_space.D=D_;
                case 4
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                case 5
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                case 6
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                case 7
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                    
                otherwise
                    
                    n=length(obj.current_model(1).A);
                    C_=[];
                    D_=[];
                    
                    for i=1:current_inputs_nr
                        g_=zeros(1,n);
                        g_(end)=1;
                        C_=[C_ g_];
                        D_=[D_ 0];
                    end
                    
                    A_=blkdiag(obj.current_model.A);
                    B_=blkdiag(obj.current_model.B);
                    
                    state_space.A=A_;
                    state_space.B=B_;
                    state_space.C=C_;
                    state_space.D=D_;
            end
            
            if length(sys_inputs)>ident_horizon
                u=sys_inputs(:,end-ident_horizon:end);
                y=sys_output(end-ident_horizon:end);
            else
                u=sys_inputs;
                y=sys_output;
            end
            
            t=0:length(y)-1;
            
            XT=MD_exact_state_observer(state_space,t,u,y');
            
            disp('Observed end state');
            XT
            
            if length(XT)>n
                
                for i=1:current_inputs_nr
                    system_state(i,:)=XT((i-1)*(length(XT)/current_inputs_nr)+1:(i)*(length(XT)/current_inputs_nr));
                end
                
            else
                system_state=XT;
            end
            
        end
        
        %%
        function system_state=obtain_system_initial_state(obj,sys_inputs,sys_output,ident_horizon)
            
            current_inputs_nr=min(size(sys_inputs));
            
            switch MD_constant_values.ident_mode
                case 1
                    n=length(obj.current_model(1).A);
                    C_=[];
                    D_=[];
                    
                    for i=1:current_inputs_nr
                        g_=zeros(1,n);
                        g_(end)=1;
                        C_=[C_ g_];
                        D_=[D_ 0];
                    end
                    
                    A_=blkdiag(obj.current_model.A);
                    B_=blkdiag(obj.current_model.B);
                    
                    state_space.A=A_;
                    state_space.B=B_;
                    state_space.C=C_;
                    state_space.D=D_;
                    
                case 2
                    
                case 3
                    n=length(obj.current_model(1).A);
                    
                    C_=zeros(1,n);
                    C_(end)=1;
                    D_=zeros(1,current_inputs_nr);
                    
                    state_space.A=obj.current_model.A;
                    state_space.B=obj.current_model.B;
                    state_space.C=C_;
                    state_space.D=D_;
                case 4
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                case 5
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                case 6
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                case 7
                    if length(obj.current_model)>1
                        n=length(obj.current_model(1).A);
                        C_=[];
                        D_=[];
                        
                        for i=1:current_inputs_nr
                            g_=zeros(1,n);
                            g_(end)=1;
                            C_=[C_ g_];
                            D_=[D_ 0];
                        end
                        
                        A_=blkdiag(obj.current_model.A);
                        B_=blkdiag(obj.current_model.B);
                        
                        state_space.A=A_;
                        state_space.B=B_;
                        state_space.C=C_;
                        state_space.D=D_;
                    else
                        n=length(obj.current_model.A);
                        
                        C_=zeros(1,n);
                        C_(end)=1;
                        D_=zeros(1,current_inputs_nr);
                        
                        state_space.A=obj.current_model.A;
                        state_space.B=obj.current_model.B;
                        state_space.C=C_;
                        state_space.D=D_;
                    end
                    
                    
                otherwise
                    
                    n=length(obj.current_model(1).A);
                    C_=[];
                    D_=[];
                    
                    for i=1:current_inputs_nr
                        g_=zeros(1,n);
                        g_(end)=1;
                        C_=[C_ g_];
                        D_=[D_ 0];
                    end
                    
                    A_=blkdiag(obj.current_model.A);
                    B_=blkdiag(obj.current_model.B);
                    
                    state_space.A=A_;
                    state_space.B=B_;
                    state_space.C=C_;
                    state_space.D=D_;
            end
            
            
            if length(sys_inputs)>ident_horizon
                u=sys_inputs(:,1:ident_horizon);
                y=sys_output(1:ident_horizon);
            else
                
                u=sys_inputs;
                y=sys_output;
            end
            
            
            t=0:length(y)-1;
            
            XT=MD_exact_state_observer_initial(state_space,t,u,y);
            
            disp('Observed initial state');
            XT
            
            if length(XT)>n
                
                for i=1:current_inputs_nr
                    system_state(i,:)=XT((i-1)*(length(XT)/current_inputs_nr)+1:(i)*(length(XT)/current_inputs_nr));
                end
                
            else
                system_state=XT;
            end
            
        end
        
        %%
        function plot_signals(obj,figure_nr,titles,y_labels,plot_intervals,plot_sim_intervals,plot_pull)
            
            plot_signals=[];
            f_size=25;
            
            if nargin > 1
                fig=figure(figure_nr);
            else
                fig=figure(100);
            end
            
            fig.Color=[1 1 1];
            
            
            for i=1:obj.inputs_nr+3
                
                plot_signal=[];
                
                for k=1:obj.current_interval-1
                    if isempty(obj.signals_intervals(k).original_signals)==0
                        plot_signal=[plot_signal obj.signals_intervals(k).original_signals(i,:)];
                    end
                end
                
                %size(plot_signal)
                plot_signals(i,:)=plot_signal;
                
            end
            
            for i=1:obj.inputs_nr
                if plot_pull
                    subplot(obj.inputs_nr+2,1,i);
                else
                    subplot(obj.inputs_nr+1,1,i);
                end
                
                plot_signal=[];
                
                for k=1:obj.current_interval-1
                    if isempty(obj.signals_intervals(k).original_signals)==0
                        hold on
                        
                        plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(i,:),'b');
                        if plot_intervals
                            plot([obj.signals_intervals(k).time(end) obj.signals_intervals(k).time(end)],...
                                [min(plot_signals(i,:)),max(plot_signals(i,:))],'g');
                        end
                    end
                end
                
                
                xlim([obj.signals_intervals(1).time(1) obj.signals_intervals(end).time(end)]);
                
                hold on;
                box on;
                grid on;
                title(titles(i), 'interpreter', 'latex');
                set(gca,'fontsize',f_size)
                set(gca, 'xticklabel', []);
                y=ylabel(y_labels{i}, 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
                set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
                
            end
            
            if plot_pull
                subplot(obj.inputs_nr+2,1,obj.inputs_nr+1);
            else
                subplot(obj.inputs_nr+1,1,obj.inputs_nr+1);
                
            end
            hold on;
            
            for k=1:obj.current_interval-1
                if isempty(obj.signals_intervals(k).original_signals)==0
                    hold on
                    plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:),'b');
                    plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+2,:),'r');
                    
                    if plot_intervals
                        plot([obj.signals_intervals(k).time(end) obj.signals_intervals(k).time(end)],...
                            [min(plot_signals(obj.inputs_nr+1,:)),max(plot_signals(obj.inputs_nr+1,:))],'g');
                        
                        if obj.signals_intervals(k).op_interval
                            plot([obj.signals_intervals(k).op_time obj.signals_intervals(k).op_time],...
                                [min(plot_signals(obj.inputs_nr+1,:)),max(plot_signals(obj.inputs_nr+1,:))],'k--');
                        end
                    end
                    
                end
            end
            
            if plot_sim_intervals
                for m=1:obj.current_model_nr
                    for i=1:length(obj.ident_models(m).intervals)-1
                        plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output+obj.ident_models(m).offset_value(end),'m');
                        
                        if ~isempty(obj.ident_models(m).intervals(i).interval_type)
                            text(0.5*(obj.ident_models(m).intervals(i).time(1)+obj.ident_models(m).intervals(i).time(end)),obj.ident_models(m).offset_value(end),...
                                obj.ident_models(m).intervals(i).interval_type,'FontSize',MD_constant_values.font_size, 'Interpreter', 'latex');
                        end
                    end
                end
            end
            %obj.ident_models(m).intervals(i).interval_type
            
            xlim([obj.signals_intervals(1).time(1) obj.signals_intervals(end).time(end)]);
            title('Output temperature and temperature set point', 'interpreter', 'latex');
            %xlabel('Time [s]', 'interpreter', 'latex');
            set(gca,'fontsize',f_size)
            if plot_pull
                set(gca, 'xticklabel', []);
            else
                xlabel('Time [s]', 'interpreter', 'latex');
            end
            y=ylabel(['Temp. [$^\circ$C]'], 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
            set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
            %lgd=legend('Output temperature','Temperature set point','Location','northeast');
            %lgd.FontSize=f_size;
            box on;
            grid on;
            
            if plot_pull
                
                subplot(obj.inputs_nr+2,1,obj.inputs_nr+2);
                hold on;
                for k=1:obj.current_interval-1
                    if length(obj.signals_intervals)>=i && isempty(obj.signals_intervals(i).original_signals)==0
                        hold on
                        plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+3,:),'b');
                        
                        if plot_intervals
                            plot([obj.signals_intervals(k).time(end) obj.signals_intervals(k).time(end)],...
                                [min(plot_signals(obj.inputs_nr+3,:))-1,max(plot_signals(obj.inputs_nr+3,:))+1],'g');
                        end
                    end
                end
                
                xlim([obj.signals_intervals(1).time(1) obj.signals_intervals(end).time(end)]);
                title('Forehearth pull', 'interpreter', 'latex');
                xlabel('Time [s]', 'interpreter', 'latex');
                set(gca,'fontsize',f_size)
                y=ylabel(['Pull [t/24h]'], 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
                set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
                box on;
                grid on;
                
            end
            
            fig=figure(521);
            fig.Color=[1 1 1];
            
            min_values=[];
            max_values=[];
            
            min_output_plot=min(plot_signals(obj.inputs_nr+1,:));
            max_output_plot=max(plot_signals(obj.inputs_nr+1,:));
            
            for k=1:obj.current_interval-1
                if isempty(obj.signals_intervals(k).original_signals)==0
                    hold on
                    p1=plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:),'b');
                    p2=plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+2,:),'r');
                    
                    if plot_intervals
                        plot([obj.signals_intervals(k).time(end) obj.signals_intervals(k).time(end)],...
                            [min_output_plot,max_output_plot],'g');
                        
                        if obj.signals_intervals(k).op_interval
                            plot([obj.signals_intervals(k).op_time obj.signals_intervals(k).op_time],...
                                [min_output_plot,max_output_plot],'k--');
                        end
                    end
                    
                    min_values=[min_values min(obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:))];
                    max_values=[max_values max(obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:))];
                    
                end
            end
            
            for m=1:obj.current_model_nr
                for i=1:length(obj.ident_models(m).intervals)-1
                    
                    if m>1 && ~isempty(obj.ident_models(m).intervals(i).interval_type) && obj.ident_models(m).intervals(i).interval_type=='I'
                        %plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output+obj.ident_models(m).offset_value(end),'c');
                    else
                        p3=plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output+obj.ident_models(m).offset_value(end),'m');
                    end
                    
                    if obj.ident_models(m).intervals(i).interval_type=='R' %~isempty(obj.ident_models(m).intervals(i).interval_type)
                        text(0.5*(obj.ident_models(m).intervals(i).time(1)+obj.ident_models(m).intervals(i).time(end)),obj.ident_models(m).offset_value(end),...
                            obj.ident_models(m).intervals(i).interval_type,'FontSize',MD_constant_values.font_size, 'Interpreter', 'latex');
                    end
                    
                end
                
                
            end
            
            ylim([min(min_values)*0.99 max(max_values)*1.01]);
            xlabel('Time [s]', 'interpreter', 'latex');
            set(gca,'fontsize',f_size)
            y=ylabel(['Temp. [$^\circ$C]'], 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
            set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
            box on;
            grid on;
            xlim([obj.signals_intervals(1).time(1) obj.signals_intervals(end).time(end)]);
            
            
            % plotting boxes
            if ~isempty(obj.ident_models)
                x_start=obj.ident_models(1).intervals(1).time(1);
                %x_end=obj.ident_models(1).intervals(obj.ident_models(1).intervals_sim(1)-1).time(end);
                x_end=obj.ident_models(1).intervals(length(obj.ident_models(1).intervals)-length(obj.ident_models(1).intervals_sim)-1).time(end);
                
                p4=patch([x_start x_end x_end x_start],...
                    [min_output_plot min_output_plot  max_output_plot max_output_plot],...
                    [0 1 1],'FaceAlpha',0.1,'LineStyle','none');
                %annotation('textarrow',[x_start x_end],[max(plot_signals(obj.inputs_nr+1,:)) max(plot_signals(obj.inputs_nr+1,:))],'FontSize',13,'Linewidth',2)
                
                text(x_start+MD_constant_values.T_sim*0,0.5*(min_output_plot+max_output_plot),'INITIAL MODEL','FontSize',MD_constant_values.font_size, 'Interpreter', 'latex');
                
                interval_offset=0;
                for i=1:length(obj.ident_models)
                    
                    %disp(['Model ' num2str(i) ' current interval ']);
                    %obj.ident_models(i).intervals_sim(1)-interval_prev_end
                    if length(obj.ident_models(i).intervals_sim)>0
                        x_start=obj.ident_models(i).intervals(length(obj.ident_models(i).intervals)-length(obj.ident_models(i).intervals_sim)).time(1);
                        x_end=obj.ident_models(i).intervals(end-1).time(end);
                        interval_prev_end=obj.ident_models(i).intervals_sim(end);
                        
                        if mod(i,2)==0
                            p5=patch([x_start x_end x_end x_start],...
                                [min_output_plot min_output_plot  max_output_plot max_output_plot],...
                                [1 1 0],'FaceAlpha',0.1,'LineStyle','none');
                        else
                            p6=patch([x_start x_end x_end x_start],...
                                [min_output_plot min_output_plot  max_output_plot max_output_plot],...
                                [1 0 1],'FaceAlpha',0.1,'LineStyle','none');
                        end
                    end
                    
                end
                
            end
            
            % legend
            legend([p1 p2 p3], 'Simulated temperature','Temperature set point','MFM model','Location','southeast');
            
        end
        
        %%
        % additional plot for the Strejc model
        function plot_signals_Strejc(obj,plot_intervals)
            
            plot_signals=[];
            f_size=25;
            
            
            
            fig.Color=[1 1 1];
            
            
            for i=1:obj.inputs_nr+3
                
                plot_signal=[];
                
                for k=1:obj.current_interval-1
                    if isempty(obj.signals_intervals(k).original_signals)==0
                        plot_signal=[plot_signal obj.signals_intervals(k).original_signals(i,:)];
                    end
                end
                
                %size(plot_signal)
                plot_signals(i,:)=plot_signal;
                
            end
            
            f_size=25;
            
            fig=figure(522);
            fig.Color=[1 1 1];
            
            min_values=[];
            max_values=[];
            
            for k=1:obj.current_interval-1
                if isempty(obj.signals_intervals(k).original_signals)==0
                    hold on
                    p1=plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:),'b');
                    p2=plot(obj.signals_intervals(k).time,obj.signals_intervals(k).original_signals(obj.inputs_nr+2,:),'r');
                    
                    if plot_intervals
                        plot([obj.signals_intervals(k).time(end) obj.signals_intervals(k).time(end)],...
                            [min(plot_signals(obj.inputs_nr+1,:)),max(plot_signals(obj.inputs_nr+1,:))],'g');
                        
                        if obj.signals_intervals(k).op_interval
                            plot([obj.signals_intervals(k).op_time obj.signals_intervals(k).op_time],...
                                [min(plot_signals(obj.inputs_nr+1,:)),max(plot_signals(obj.inputs_nr+1,:))],'k--');
                        end
                    end
                    
                    min_values=[min_values min(obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:))];
                    max_values=[max_values max(obj.signals_intervals(k).original_signals(obj.inputs_nr+1,:))];
                    
                end
            end
            
            
            for m=1:obj.current_model_nr
                for i=1:length(obj.ident_models(m).intervals)-1
                    
                    if ~isempty(obj.ident_models(m).intervals(i).simulated_output_Strejc)
                        if m>1 && ~isempty(obj.ident_models(m).intervals(i).interval_type) && obj.ident_models(m).intervals(i).interval_type=='I'
                            %plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output+obj.ident_models(m).offset_value(end),'c');
                        else
                            p3=plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output+obj.ident_models(m).offset_value(end),'m');
                            p4=plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output_Strejc+obj.ident_models(m).offset_value(end),'c');
                            %plot(obj.ident_models(m).intervals(i).time, obj.ident_models(m).intervals(i).simulated_output_Strejc,'m');
                        end
                    end
                    
                    if ~isempty(obj.ident_models(m).intervals(i).interval_type)
                        text(0.5*(obj.ident_models(m).intervals(i).time(1)+obj.ident_models(m).intervals(i).time(end)),obj.ident_models(m).offset_value(end),...
                            obj.ident_models(m).intervals(i).interval_type,'FontSize',MD_constant_values.font_size, 'Interpreter', 'latex');
                    end
                    
                end
            end
            
            
            %ylim([min(min_values)*0.99 max(max_values)*1.01]);
            xlabel('Time [s]', 'interpreter', 'latex');
            set(gca,'fontsize',f_size)
            y=ylabel(['Temp. [$^\circ$C]'], 'rot', 90, 'interpreter', 'latex');  % do not rotate the y label
            set(y, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
            box on;
            grid on;
            xlim([obj.signals_intervals(1).time(1) obj.signals_intervals(end).time(end)]);
            
            legend([p1 p2 p3 p4], 'Simulated temperature','Temperature set point','MFM model','Strejc model','Location','southeast');
            
        end
        
        
    end
end
