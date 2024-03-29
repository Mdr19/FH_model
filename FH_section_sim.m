classdef FH_section_sim < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        sim_mode;
        
        file_path;
        signals_names;
        inputs_nr;
        
        pull_file;
        pull_saved_file;
        temp_SP_file;
        input_signal_file;
        temp_prev_file;
        temp_measured_file;
        
        section_name;
        sim_date;
        
        current_interval;
        intervals;
        
        applied_controller;
        
        k_1;
        k_2;
        k_3;
        k_4;
        
        elements_nr;
        section_len;
        t_step;
        
        start_index;
        current_index;
        
        fea;
        init_temp_function;
        init_temp_function_par;
        
        simulated_temperature;
        
        % Z4 functions
        Z4_input_signal_function;
        
        % Z3 functions
        Z3_input_signal_function_1;
        Z3_input_signal_function_2;
        
        % uncertain pull
        pull_uncertain;
        
        %noises
        add_noise;
        snr;
        seed;
        
    end
    
    methods
        
        % class constructor
        
        function obj = FH_section_sim(FH_section_data)
            if nargin > 0
                obj.section_name=FH_section_data.section_name;
                obj.sim_date=FH_section_data.sim_date;
                obj.signals_names=FH_section_data.signals_names;
                obj.inputs_nr=FH_section_data.inputs_nr;
                
                obj.k_1 = FH_section_data.k_1;
                obj.k_2 = FH_section_data.k_2;
                
                if obj.inputs_nr>2
                    obj.k_3 = FH_section_data.k_3;
                    obj.k_4 = FH_section_data.k_4;
                end
                
                obj.elements_nr=FH_section_data.elements_nr;
                %obj.glass_vel=FH_section_data.glass_vel;
                obj.section_len=FH_section_data.section_len;
                obj.t_step=FH_section_data.t_step;
                
                
                obj.file_path=FH_section_data.file_path;
                
                
                obj.start_index=FH_section_data.start_index;
                obj.current_index=obj.start_index;
                obj.current_interval=0;
                obj.intervals=[];
                
                if obj.inputs_nr==2
                    obj.Z4_input_signal_function=FH_section_data.Z4_input_signal_function;
                elseif obj.inputs_nr==3
                    obj.Z3_input_signal_function_1=FH_section_data.Z3_input_signal_function_1;
                    obj.Z3_input_signal_function_2=FH_section_data.Z3_input_signal_function_2;
                end
                
                obj.pull_file=FH_section_data.pull_file;
                obj.pull_saved_file=FH_section_data.pull_saved_file;
                obj.temp_SP_file=FH_section_data.temp_SP_file;
                obj.input_signal_file=FH_section_data.input_signal_file;
                obj.temp_prev_file=FH_section_data.temp_prev_file;
                obj.temp_measured_file=FH_section_data.temp_measured_file;
                
                obj.sim_mode=FH_section_data.sim_mode;
                obj.pull_uncertain=FH_section_data.pull_uncertain;
                
                obj.add_noise=FH_section_data.add_noise;
                obj.snr=FH_section_data.snr;
                obj.seed=FH_section_data.seed;
            end
        end
        
        function init(obj)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % initial state function
            
            str='';
            for i=1:length(obj.init_temp_function_par)
                if obj.init_temp_function_par(i)<0
                    str=strcat(str,num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                else
                    str=strcat(str,'+',num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                end
            end
            
            obj.init_temp_function = str;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            cOptDef = { ...
                'icase',    1; ...
                'len',      obj.section_len; ...
                'hmax',     obj.section_len/obj.elements_nr; ...
                'ischeme'   3; ...
                'sfun',     'sflag1'; ...
                'iplot',    1; ...
                'dvname',   'u'; ...
                'tol',      1.1e-1; ...
                'fid',      1 };
            
            varargin={};
            [got,opt] = parseopt( cOptDef, varargin{:} );
            fid = opt.fid;
            
            % Grid generation.
            nx = round( opt.len/opt.hmax );
            obj.fea.grid = linegrid( nx, 0, opt.len );
            
            
            % Problem definition.
            u = opt.dvname;
            
            if obj.inputs_nr==3
                seqn = [u,''' + ',u,'x*pull = k2*ctrl_1 - k1*(1+k3*ctrl_2^2+k4*ctrl_2)*', u];
            else
                seqn = [u,''' + ',u,'x*pull + k1*',u ' = k2*ctrl'];
            end
            %seqn = [u,''' + ',u,'x*pull = k2*ctrl'];
            %seqn = [u,''' + ',u,'x + ',u '_t = alpha'];
            
            
            
            %refsol = '-9.5490*x+1210.5';
            
            if obj.inputs_nr==2
                
                obj.fea.sdim  = { 'x' };
                obj.fea = addphys( obj.fea, @customeqn );
                obj.fea.phys.ce.dvar = { u };
                obj.fea.phys.ce.eqn.seqn = seqn;
                obj.fea.phys.ce.sfun = { opt.sfun };
                
                obj.fea.phys.ce.eqn.coef{2,1}='ctrl';
                obj.fea.phys.ce.eqn.coef{2,4}=obj.Z4_input_signal_function;
                
                obj.fea.phys.ce.eqn.coef{3,1}='pull';
                obj.fea.phys.ce.eqn.coef{3,4}={'FH_glass_vel_function(t)'};
                
                
                obj.fea.phys.ce.eqn.coef{4,1}='k1';
                obj.fea.phys.ce.eqn.coef{4,4}=obj.k_1;
                
                obj.fea.phys.ce.eqn.coef{5,1}='k2';
                obj.fea.phys.ce.eqn.coef{5,4}=obj.k_2;
                
            elseif obj.inputs_nr==3
                
                obj.fea.sdim  = { 'x' };
                obj.fea = addphys( obj.fea, @customeqn );
                obj.fea.phys.ce.dvar = { u };
                obj.fea.phys.ce.eqn.seqn = seqn;
                obj.fea.phys.ce.sfun = { opt.sfun };
                
                obj.fea.phys.ce.eqn.coef{2,1}='ctrl_1';
                obj.fea.phys.ce.eqn.coef{2,4}=obj.Z3_input_signal_function_1;
                %{'PNV_ctrl_function_Z3_mix_press(u,t)'};
                
                obj.fea.phys.ce.eqn.coef{3,1}='ctrl_2';
                obj.fea.phys.ce.eqn.coef{3,4}=obj.Z3_input_signal_function_2;
                
                obj.fea.phys.ce.eqn.coef{4,1}='pull';
                obj.fea.phys.ce.eqn.coef{4,4}={'FH_glass_vel_function(t)'};
                
                obj.fea.phys.ce.eqn.coef{5,1}='k1';
                obj.fea.phys.ce.eqn.coef{5,4}=obj.k_1;
                
                obj.fea.phys.ce.eqn.coef{6,1}='k2';
                obj.fea.phys.ce.eqn.coef{6,4}=obj.k_2;
                
                obj.fea.phys.ce.eqn.coef{7,1}='k3';
                obj.fea.phys.ce.eqn.coef{7,4}=obj.k_3;
                
                obj.fea.phys.ce.eqn.coef{8,1}='k4';
                obj.fea.phys.ce.eqn.coef{8,4}=obj.k_4;
                
            end
            
            obj.fea = parsephys( obj.fea );
            obj.fea = parseprob( obj.fea );
            
            obj.fea.bdr.d = {'FH_boundary_function(t)' []};
            
        end
        
        function define_init_temp_function_file(obj,temp_files_names,variables_names,sections_len,start_time)
            
            for i=1:length(temp_files_names)
                temp(i)=MD_get_from_file(char(strcat(obj.file_path,'\',obj.sim_date,'\',temp_files_names(i),'.csv')) ,...
                    variables_names(i),start_time,start_time,0,MD_constant_values.FH_message_display);
            end
            
            obj.init_temp_function_par = polyfit(sections_len,temp, 4);
            x_=sections_len(1):0.01:sections_len(end);
            val_p=polyval(obj.init_temp_function_par,x_);
            
            figure(10);
            plot(sections_len,temp,'o');
            hold on
            grid on;
            plot(x_,val_p);
            
        end
        
        function define_init_temp_function(obj,init_temperatures,sections_len)
            
            obj.init_temp_function_par = polyfit(sections_len,init_temperatures, 2);
            x_=sections_len(1):0.01:sections_len(end);
            val_p=polyval(obj.init_temp_function_par,x_);
            
            figure(10);
            plot(sections_len,init_temperatures,'o');
            hold on
            grid on;
            plot(x_,val_p);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function perform_simulation(obj,end_time)
            
            global temp_zone_prev;
            global glass_pull;
            global temp_SP;
            
            global E_int;
            global E_int_cln;
            
            global E_temp;
            global time_temp;
            
            global Kp;
            global Ki;
            
            global Kp_cln;
            global Ki_cln;
            
            global input_signal_applied;
            
            % common
            global input_signals;
            global output_signal;
            %global error_hist;
            global MPC_model;
            
            obj.current_interval=obj.current_interval+1;
            
            disp('--------------------------------------------------------------------------');
            disp(['Performing simulation ' obj.section_name ': ' num2str(obj.current_index) ' ' num2str(end_time)]);
            
            signal_len=end_time-obj.current_index-1;
            
            % temp prev
            obj.intervals(obj.current_interval).signals(1,:)=MD_get_from_file(char(obj.temp_prev_file),...
                obj.signals_names(1),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            
            % input signals and measured temp
            if obj.sim_mode==0
                if obj.inputs_nr==2
                    obj.intervals(obj.current_interval).signals(2,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(2),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(3,:)=MD_get_from_file(char(obj.temp_measured_file),...
                        obj.signals_names(3),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                elseif obj.inputs_nr==3
                    obj.intervals(obj.current_interval).signals(2,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(2),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(3,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(3),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(4,:)=MD_get_from_file(char(obj.temp_measured_file),...
                        obj.signals_names(4),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
            end
            
            % temp SP
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).signals(4,:)=MD_get_from_file(char(obj.temp_SP_file),...
                    obj.signals_names(4),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).signals(5,:)=MD_get_from_file(char(obj.temp_SP_file),...
                    obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            end
            
            % pull-up
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).signals(5,:)=MD_get_from_file(char(obj.pull_file),...
                    obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                
                if obj.pull_uncertain
                    obj.intervals(obj.current_interval).signals(6,:)=MD_get_from_file(char(obj.pull_saved_file),...
                        obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
                
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).signals(6,:)=MD_get_from_file(char(obj.pull_file),...
                    obj.signals_names(6),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                
                if obj.pull_uncertain
                    obj.intervals(obj.current_interval).signals(7,:)=MD_get_from_file(char(obj.pull_saved_file),...
                        obj.signals_names(6),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
                
            end
            
            % time vector
            obj.intervals(obj.current_interval).time=obj.current_index-obj.start_index:obj.current_index-obj.start_index+signal_len;
            
            % model with mix. press. only
            
            if obj.inputs_nr==2
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                input_signals.(strcat(obj.section_name,'_input'))=obj.intervals(obj.current_interval).signals(2,:);
                glass_pull=obj.intervals(obj.current_interval).signals(5,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(4,:);
                %error_hist=[];
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    %sim_mode_append=1;
                else
                    time_temp=0;
                end
                
                
                if (obj.sim_mode==2 || obj.sim_mode==3 || obj.sim_mode==4 || obj.sim_mode==5) && ~isempty(MPC_model.(strcat(obj.section_name,'_new')))
                    obj.applied_controller(obj.current_interval).input_1='MPC';
                else
                    obj.applied_controller(obj.current_interval).input_1='PID';
                end
                
                
                % model with mix. press. and cln. vlv.
                
            elseif obj.inputs_nr==3
                
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                input_signals.(strcat(obj.section_name,'_input_1'))=obj.intervals(obj.current_interval).signals(2,:);
                input_signals.(strcat(obj.section_name,'_input_2'))=obj.intervals(obj.current_interval).signals(3,:);
                glass_pull=obj.intervals(obj.current_interval).signals(6,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(5,:);
                %error_hist=[];
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_int_cln.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    
                    Kp_cln=MD_constant_values.Kp_cln;
                    Ki_cln=MD_constant_values.Ki_cln;
                    
                else
                    time_temp=0;
                end
                
                % current controller
                obj.applied_controller(obj.current_interval).input_1='PID';
                obj.applied_controller(obj.current_interval).input_2='PID';
                
                % MPC model modification for zone 3
                
                if obj.sim_mode==2 || obj.sim_mode==3
                    
                    if ~isempty(MPC_model.(obj.section_name)) || ~isempty(MPC_model.(strcat(obj.section_name,'_new')))
                        
                        without_mix_press=false;
                        without_cln_vlv=false;
                        
                        if (abs(input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)-MD_constant_values.cln_vlv_min)<1 && temp_SP(end,2)>output_signal.(obj.section_name)(end,2)) ||...
                                (abs(input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)-MD_constant_values.cln_vlv_max)<1 && temp_SP(end,2)<output_signal.(obj.section_name)(end,2))
                            %disp('Mix press omitted');
                            disp('Cln vlv omitted');
                            without_cln_vlv=true;
                        elseif (abs(input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)-MD_constant_values.mix_press_min)<0.25 && temp_SP(end,2)<output_signal.(obj.section_name)(end,2)) ||...
                                (abs(input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)-MD_constant_values.mix_press_max)<0.25 && temp_SP(end,2)>output_signal.(obj.section_name)(end,2))
                            %disp('Cln vlv omitted');
                            disp('Mix press omitted');
                            without_mix_press=true;
                        end
                        
                    end
                    
                    % for current models
                    
                    if ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==2
                        
                        MPC_model.(obj.section_name).control_signals(1)=1;
                        MPC_model.(obj.section_name).control_signals(2)=1;
                        
                        if without_mix_press
                            
                            disp('MPC cln vlv ONLY');
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                            
                            MPC_model.(obj.section_name).control_signals(1)=0;
                            MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B(:,2);
                            
                            n=size(MPC_model.(strcat(obj.section_name,'_saved')).Omega,1)/2;
                            MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega(n+1:end,n+1:end);
                            
                            m=size(MPC_model.(strcat(obj.section_name,'_saved')).Psi,1)/2;
                            MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi(m+1:end,:);
                            
                            MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot(2,n+1:end);
                            
                            M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                            MPC_model.(obj.section_name).M=[];
                            
                            %M
                            
                            for i=1:size(M,1)
                                if mod(i,2)==0
                                    MPC_model.(obj.section_name).M(ceil(i/2),:)=M(i,n+1:end);
                                end
                            end
                            
                            if obj.sim_mode==3
                                MPC_model.Z3.Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma(1:m,:);
                            end
                            
                        elseif without_cln_vlv
                            
                            disp('MPC mix press ONLY');
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            
                            MPC_model.(obj.section_name).control_signals(2)=0;
                            MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B(:,1);
                            
                            n=size(MPC_model.(strcat(obj.section_name,'_saved')).Omega,1)/2;
                            MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega(1:n,1:n);
                            
                            m=size(MPC_model.(strcat(obj.section_name,'_saved')).Psi,1)/2;
                            MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi(1:m,:);
                            
                            MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot(1,1:n);
                            
                            M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                            MPC_model.(obj.section_name).M=[];
                            
                            %M
                            
                            for i=1:size(M,1)
                                if mod(i,2)==1
                                    MPC_model.(obj.section_name).M(ceil(i/2),:)=M(i,1:n);
                                end
                            end
                            
                            if obj.sim_mode==3
                                MPC_model.Z3.Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma(1:m,:);
                            end
                            
                        else
                            
                            disp('Both models');
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                            
                            MPC_model.(obj.section_name).control_signals=MPC_model.(strcat(obj.section_name,'_saved')).control_signals;
                            MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B;
                            
                            MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega;
                            
                            MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi;
                            
                            MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot;
                            
                            MPC_model.(obj.section_name).M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                            
                            if obj.sim_mode==3
                                MPC_model.(obj.section_name).Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma;
                            end
                            
                        end
                        
                    elseif ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==1
                        
                        % 1 controlled signal in model only - mix. press. or
                        % cln. vlv.
                        
                        if MPC_model.(strcat(obj.section_name,'_saved')).control_signals(1)
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                        elseif MPC_model.(strcat(obj.section_name,'_saved')).control_signals(2)
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        end
                        
                        % correction if the controller updated
                        
                        if without_mix_press && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set')) && ...
                                sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        elseif without_cln_vlv && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set')) && ...
                                sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                        elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && ...
                                MPC_model.(strcat(obj.section_name,'_new_model_set')) && sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        end
                       
                    end
                    %{
                    elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new')))
                        
                        % PID and new model not applied yet
                        
                        if without_mix_press && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        elseif without_cln_vlv && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                        elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && ...
                                MPC_model.(strcat(obj.section_name,'_new_model_set')) && sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        end
                        
                    end
                    %}
                    
                     if ~isempty(MPC_model.(strcat(obj.section_name,'_new'))) && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                        
                        % PID and new model not applied yet
                        
                        if (sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2 && without_mix_press) ||...
                                (sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==1 && MPC_model.(strcat(obj.section_name,'_new')).control_signals(2))
                            obj.applied_controller(obj.current_interval).input_1='PID';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        elseif (sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2 && without_cln_vlv) ||...
                                (sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==1 && MPC_model.(strcat(obj.section_name,'_new')).control_signals(1))
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='PID';
                        elseif sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        end
                        
                    end
                    
                    
                    
                    
                elseif obj.sim_mode==4
                    disp('Discrete MPC');
                    
                elseif obj.sim_mode==5
                    disp('Discrete MPC FF');
                    
                    obj.applied_controller(obj.current_interval).input_1='PID';
                    obj.applied_controller(obj.current_interval).input_2='PID';
                    
                    if ~isempty(MPC_model.(strcat(obj.section_name,'_new'))) && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                        
                        if sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                            
                        elseif MPC_model.(strcat(obj.section_name,'_new')).control_signals(1)
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                            
                        elseif MPC_model.(strcat(obj.section_name,'_new')).control_signals(2)
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                            
                        end
                        
                    elseif ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==2
                        
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                        
                    elseif ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==1
                        
                        if MPC_model.(strcat(obj.section_name,'_saved')).control_signals(1)
                            obj.applied_controller(obj.current_interval).input_1='MPC';
                        elseif MPC_model.(strcat(obj.section_name,'_saved')).control_signals(2)
                            obj.applied_controller(obj.current_interval).input_2='MPC';
                        end
                        
                    end
                    
                end
                
            end
            
            input_signal_applied.(strcat(obj.section_name,'_input_1'))=[];
            output_signal.(obj.section_name)=[];
            
            if obj.inputs_nr==3
                input_signal_applied.(strcat(obj.section_name,'_input_2'))=[];
            end
            
            [obj.fea.sol.u,tlist] = solvetime( obj.fea, 'fid',     MD_constant_values.FH_PDE_display, ...
                'tmax',    signal_len, ...
                'icub',    6, ...
                'ischeme', 3, ...
                'tstep',   obj.t_step, ...
                'init',    obj.init_temp_function, ...
                'tolchg',  1e-6, ...
                'tstop',   1e-6);
            
            if tlist(end)<signal_len
                tlist=[tlist signal_len];
                obj.fea.sol.u=[obj.fea.sol.u obj.fea.sol.u(:,end)];
                input_signal_applied.(strcat(obj.section_name,'_input_1'))(end+1,1)=signal_len;
                input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)=input_signal_applied.(strcat(obj.section_name,'_input_1'))(end-1,2);
                
                if obj.inputs_nr==3
                    input_signal_applied.(strcat(obj.section_name,'_input_2'))(end+1,1)=signal_len;
                    input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)=input_signal_applied.(strcat(obj.section_name,'_input_2'))(end-1,2);
                end
            end
            
            obj.intervals(obj.current_interval).simulated_temp.time=tlist+obj.current_index-obj.start_index;
            
            if obj.add_noise
                obj.intervals(obj.current_interval).simulated_temp.values=awgn(obj.fea.sol.u(end,:),obj.snr,0,obj.seed);
            else
                obj.intervals(obj.current_interval).simulated_temp.values=obj.fea.sol.u(end,:);
            end
            
            obj.intervals(obj.current_interval).simulated_temp_resampled=...
                interp1(obj.intervals(obj.current_interval).simulated_temp.time,obj.intervals(obj.current_interval).simulated_temp.values,obj.intervals(obj.current_interval).time);
            
            if obj.sim_mode==1 || obj.sim_mode==2  || obj.sim_mode==3 || obj.sim_mode==4 || obj.sim_mode==5
                
                input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,input_signal_applied.(strcat(obj.section_name,'_input_1')),obj.intervals(obj.current_interval).time,'nearest');
                
                input_signal_resampled=input_signal_resampled(:,2);
                
                
                for i=1:length(input_signal_resampled)
                    if input_signal_resampled(i)>6
                        input_signal_resampled(i)=6;
                    elseif input_signal_resampled(i)<0.6;
                        input_signal_resampled(i)=0.6;
                    end
                end
                
                
                obj.intervals(obj.current_interval).signals(2,:)=input_signal_resampled;
                
                if obj.inputs_nr==3
                    
                    
                    input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,input_signal_applied.(strcat(obj.section_name,'_input_2')),obj.intervals(obj.current_interval).time,'nearest');
                    input_signal_resampled=input_signal_resampled(:,2);
                    
                    
                    for i=1:length(input_signal_resampled)
                        if input_signal_resampled(i)>75
                            input_signal_resampled(i)=75;
                        elseif input_signal_resampled(i)<5;
                            input_signal_resampled(i)=5;
                        end
                    end
                    
                    obj.intervals(obj.current_interval).signals(3,:)=input_signal_resampled;
                    
                end
            end
            
            % SP difference
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).SP_diff=sumsqr(obj.intervals(obj.current_interval).simulated_temp_resampled-obj.intervals(obj.current_interval).signals(4,:));
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).SP_diff=sumsqr(obj.intervals(obj.current_interval).simulated_temp_resampled-obj.intervals(obj.current_interval).signals(5,:));
            end
            
            % init. temp. function for next intervals
            
            last_temp_dist=obj.fea.sol.u(:,end);
            obj.init_temp_function_par = polyfit(0:(obj.section_len/(length(last_temp_dist)-1)):obj.section_len, last_temp_dist', MD_constant_values.temp_poly_rank);
            
            str='';
            for i=1:length(obj.init_temp_function_par)
                if obj.init_temp_function_par(i)<0
                    str=strcat(str,num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                else
                    str=strcat(str,'+',num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                end
            end
            
            obj.init_temp_function = str;
            obj.current_index=end_time;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function perform_simulation_multizone(obj,end_time,prev_section)
            
            %global mix_press;
            global temp_zone_prev;
            %global temp_zone_prev_del;
            global glass_pull;
            global temp_SP;
            
            global E_int;
            global E_int_cln;
            
            global E_temp;
            global time_temp;
            
            global Kp;
            global Ki;
            
            global Kp_cln;
            global Ki_cln;
            
            global input_signal_applied;
            %global sim_mode_append;         % 0 - do��czanie starych pomiar�w, 1 - brak do��czania
            
            % common
            global input_signals
            global output_signal;
            global MPC_model;
            
            obj.current_interval=obj.current_interval+1;
            
            disp('--------------------------------------------------------------------------');
            disp(['Performing simulation ' obj.section_name ': ' num2str(obj.current_index) ' ' num2str(end_time)]);
            
            signal_len=end_time-obj.current_index-1;
            
            obj.intervals(obj.current_interval).signals(1,:)=prev_section.intervals(end).simulated_temp_resampled;
            
            % input signals and measured temp
            if obj.sim_mode==0
                if obj.inputs_nr==2
                    obj.intervals(obj.current_interval).signals(2,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(2),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(3,:)=MD_get_from_file(char(obj.temp_measured_file),...
                        obj.signals_names(3),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                elseif obj.inputs_nr==3
                    obj.intervals(obj.current_interval).signals(2,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(2),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(3,:)=MD_get_from_file(char(obj.input_signal_file),...
                        obj.signals_names(3),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                    
                    obj.intervals(obj.current_interval).signals(4,:)=MD_get_from_file(char(obj.temp_measured_file),...
                        obj.signals_names(4),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
            end
            
            % temp SP
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).signals(4,:)=MD_get_from_file(char(obj.temp_SP_file),...
                    obj.signals_names(4),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).signals(5,:)=MD_get_from_file(char(obj.temp_SP_file),...
                    obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            end
            
            % pull-up
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).signals(5,:)=MD_get_from_file(char(obj.pull_file),...
                    obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                
                if obj.pull_uncertain
                    obj.intervals(obj.current_interval).signals(6,:)=MD_get_from_file(char(obj.pull_saved_file),...
                        obj.signals_names(5),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
                
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).signals(6,:)=MD_get_from_file(char(obj.pull_file),...
                    obj.signals_names(6),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                
                if obj.pull_uncertain
                    obj.intervals(obj.current_interval).signals(7,:)=MD_get_from_file(char(obj.pull_saved_file),...
                        obj.signals_names(6),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
                end
                
            end
            
            % time vector
            obj.intervals(obj.current_interval).time=obj.current_index-obj.start_index:obj.current_index-obj.start_index+signal_len;
            
            if obj.inputs_nr==2
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                
                input_signals.(strcat(obj.section_name,'_input'))=obj.intervals(obj.current_interval).signals(2,:);
                glass_pull=obj.intervals(obj.current_interval).signals(5,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(4,:);
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    %sim_mode_append=1;
                else
                    time_temp=0;
                end
                
                if isempty(MPC_model.(strcat(obj.section_name,'_new')))
                    obj.applied_controller(obj.current_interval).input_1='PID';
                else
                    obj.applied_controller(obj.current_interval).input_1='MPC';
                end
                
                
            elseif obj.inputs_nr==3
                
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                
                input_signals.(strcat(obj.section_name,'_input_1'))=obj.intervals(obj.current_interval).signals(2,:);
                input_signals.(strcat(obj.section_name,'_input_2'))=obj.intervals(obj.current_interval).signals(3,:);
                glass_pull=obj.intervals(obj.current_interval).signals(5,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(5,:);
                %error_hist=[];
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_int_cln.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    
                    Kp_cln=MD_constant_values.Kp_cln;
                    Ki_cln=MD_constant_values.Ki_cln;
                    
                    %sim_mode_append=1;
                else
                    time_temp=0;
                end
                
                
                % current controller
                obj.applied_controller(obj.current_interval).input_1='PID';
                obj.applied_controller(obj.current_interval).input_2='PID';
                
                % MPC model modification for zone 3
                
                if ~isempty(MPC_model.(obj.section_name)) || ~isempty(MPC_model.(strcat(obj.section_name,'_new')))
                    
                    without_mix_press=false;
                    without_cln_vlv=false;
                    
                    if (abs(input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)-MD_constant_values.cln_vlv_min)<1 &&...
                            temp_SP(end,2)>output_signal.(obj.section_name)(end,2)) ||...
                            (abs(input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)-MD_constant_values.cln_vlv_max)<1 &&...
                            temp_SP(end,2)<output_signal.(obj.section_name)(end,2))
                        %disp('Mix press omitted');
                        disp('Cln vlv omitted');
                        without_cln_vlv=true;
                    elseif (abs(input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)-MD_constant_values.mix_press_min)<0.25 &&...
                            temp_SP(end,2)<output_signal.(obj.section_name)(end,2)) ||...
                            (abs(input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)-MD_constant_values.mix_press_max)<0.25 &&...
                            temp_SP(end,2)>output_signal.(obj.section_name)(end,2))
                        %disp('Cln vlv omitted');
                        disp('Mix press omitted');
                        without_mix_press=true;
                    end
                    
                    
                    
                end
                
                % for current models
                
                if ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==2
                    
                    MPC_model.(obj.section_name).control_signals(1)=1;
                    MPC_model.(obj.section_name).control_signals(2)=1;
                    
                    if without_mix_press
                        
                        disp('MPC cln vlv ONLY');
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                        
                        MPC_model.(obj.section_name).control_signals(1)=0;
                        MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B(:,2);
                        
                        n=size(MPC_model.(strcat(obj.section_name,'_saved')).Omega,1)/2;
                        MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega(n+1:end,n+1:end);
                        
                        m=size(MPC_model.(strcat(obj.section_name,'_saved')).Psi,1)/2;
                        MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi(m+1:end,:);
                        
                        MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot(2,n+1:end);
                        
                        M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                        MPC_model.(obj.section_name).M=[];
                        
                        %M
                        
                        for i=1:size(M,1)
                            if mod(i,2)==0
                                MPC_model.(obj.section_name).M(ceil(i/2),:)=M(i,n+1:end);
                            end
                        end
                        
                        MPC_model.Z3.Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma(m+1:end,:);
                        
                    elseif without_cln_vlv
                        
                        disp('MPC mix press ONLY');
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                        
                        MPC_model.(obj.section_name).control_signals(2)=0;
                        MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B(:,1);
                        
                        n=size(MPC_model.(strcat(obj.section_name,'_saved')).Omega,1)/2;
                        MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega(1:n,1:n);
                        
                        m=size(MPC_model.(strcat(obj.section_name,'_saved')).Psi,1)/2;
                        MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi(1:m,:);
                        
                        MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot(1,1:n);
                        
                        M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                        MPC_model.(obj.section_name).M=[];
                        
                        %M
                        
                        for i=1:size(M,1)
                            if mod(i,2)==1
                                MPC_model.(obj.section_name).M(ceil(i/2),:)=M(i,1:n);
                            end
                        end
                        
                        MPC_model.Z3.Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma(1:m,:);
                        
                        
                    else
                        
                        disp('Both models');
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                        
                        MPC_model.(obj.section_name).control_signals=MPC_model.(strcat(obj.section_name,'_saved')).control_signals;
                        MPC_model.(obj.section_name).B=MPC_model.(strcat(obj.section_name,'_saved')).B;
                        
                        MPC_model.(obj.section_name).Omega=MPC_model.(strcat(obj.section_name,'_saved')).Omega;
                        
                        MPC_model.(obj.section_name).Psi=MPC_model.(strcat(obj.section_name,'_saved')).Psi;
                        
                        MPC_model.(obj.section_name).Lzerot=MPC_model.(strcat(obj.section_name,'_saved')).Lzerot;
                        
                        MPC_model.(obj.section_name).M=MPC_model.(strcat(obj.section_name,'_saved')).M;
                        
                        % zmiana 25.02.2021
                        MPC_model.(obj.section_name).Gamma=MPC_model.(strcat(obj.section_name,'_saved')).Gamma;
                        
                    end
                    
                elseif ~isempty(MPC_model.(obj.section_name)) && sum(MPC_model.(strcat(obj.section_name,'_saved')).control_signals)==1
                    
                    % 1 controlled signal in model only - mix. press. or
                    % cln. vlv.
                    
                    if MPC_model.(strcat(obj.section_name,'_saved')).control_signals(1)
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                    elseif MPC_model.(strcat(obj.section_name,'_saved')).control_signals(2)
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                    end
                    
                    if without_mix_press && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set')) && ...
                            sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                    elseif without_cln_vlv && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set')) && ...
                            sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                    elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && ...
                            MPC_model.(strcat(obj.section_name,'_new_model_set')) && sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                    end
                    
                elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new')))
                    
                    % PID and new model not applied yet
                    
                    if without_mix_press && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                    elseif without_cln_vlv && ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && MPC_model.(strcat(obj.section_name,'_new_model_set'))
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                    elseif ~isempty(MPC_model.(strcat(obj.section_name,'_new_model_set'))) && ...
                            MPC_model.(strcat(obj.section_name,'_new_model_set')) && sum(MPC_model.(strcat(obj.section_name,'_new')).control_signals)==2
                        obj.applied_controller(obj.current_interval).input_1='MPC';
                        obj.applied_controller(obj.current_interval).input_2='MPC';
                    end
                    
                end
            end
            
            input_signal_applied.(strcat(obj.section_name,'_input_1'))=[];
            output_signal.(strcat(obj.section_name))=[];
            
            if obj.inputs_nr==3
                input_signal_applied.(strcat(obj.section_name,'_input_2'))=[];
            end
            
            [obj.fea.sol.u,tlist] = solvetime( obj.fea, 'fid',     MD_constant_values.FH_PDE_display, ...
                'tmax',    signal_len, ...
                'icub',    6, ...
                'ischeme', 3, ...
                'tstep',   obj.t_step, ...
                'init',    obj.init_temp_function, ...
                'tolchg',  1e-6, ...
                'tstop',   1e-6);
            
            
            if tlist(end)<signal_len
                tlist=[tlist signal_len];
                obj.fea.sol.u=[obj.fea.sol.u obj.fea.sol.u(:,end)];
                input_signal_applied.(strcat(obj.section_name,'_input_1'))(end+1,1)=signal_len;
                input_signal_applied.(strcat(obj.section_name,'_input_1'))(end,2)=input_signal_applied.(strcat(obj.section_name,'_input_1'))(end-1,2);
                
                if obj.inputs_nr==3
                    input_signal_applied.(strcat(obj.section_name,'_input_2'))(end+1,1)=signal_len;
                    input_signal_applied.(strcat(obj.section_name,'_input_2'))(end,2)=input_signal_applied.(strcat(obj.section_name,'_input_2'))(end-1,2);
                end
            end
            
            obj.intervals(obj.current_interval).simulated_temp.time=tlist+obj.current_index-obj.start_index;
            %obj.intervals(obj.current_interval).simulated_temp.values=obj.fea.sol.u(end,:);
            
            if obj.add_noise
                obj.intervals(obj.current_interval).simulated_temp.values=awgn(obj.fea.sol.u(end,:),obj.snr,0,obj.seed);
            else
                obj.intervals(obj.current_interval).simulated_temp.values=obj.fea.sol.u(end,:);
            end
            
            obj.intervals(obj.current_interval).simulated_temp_resampled=...
                interp1(obj.intervals(obj.current_interval).simulated_temp.time,...
                obj.intervals(obj.current_interval).simulated_temp.values,obj.intervals(obj.current_interval).time);
            
            if obj.sim_mode==1 || obj.sim_mode==2  || obj.sim_mode==3 || obj.sim_mode==4 || obj.sim_mode==5
                
                input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,...
                    input_signal_applied.(strcat(obj.section_name,'_input_1')),obj.intervals(obj.current_interval).time,'nearest');
                input_signal_resampled=input_signal_resampled(:,2);
                
                for i=1:length(input_signal_resampled)
                    if input_signal_resampled(i)>6
                        input_signal_resampled(i)=6;
                    elseif input_signal_resampled(i)<0.6;
                        input_signal_resampled(i)=0.6;
                    end
                end
                
                obj.intervals(obj.current_interval).signals(2,:)=input_signal_resampled;
                
                if obj.inputs_nr==3
                    
                    input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,...
                        input_signal_applied.(strcat(obj.section_name,'_input_2')),obj.intervals(obj.current_interval).time,'nearest');
                    input_signal_resampled=input_signal_resampled(:,2);
                    
                    for i=1:length(input_signal_resampled)
                        if input_signal_resampled(i)>75
                            input_signal_resampled(i)=75;
                        elseif input_signal_resampled(i)<5;
                            input_signal_resampled(i)=5;
                        end
                    end
                    
                    obj.intervals(obj.current_interval).signals(3,:)=input_signal_resampled;
                    
                end
                
            end
            
            % SP difference
            if obj.inputs_nr==2
                obj.intervals(obj.current_interval).SP_diff=sumsqr(obj.intervals(obj.current_interval).simulated_temp_resampled-obj.intervals(obj.current_interval).signals(4,:));
            elseif obj.inputs_nr==3
                obj.intervals(obj.current_interval).SP_diff=sumsqr(obj.intervals(obj.current_interval).simulated_temp_resampled-obj.intervals(obj.current_interval).signals(5,:));
            end
            
            
            
            %figure(300+obj.current_interval)
            %plot(obj.intervals(obj.current_interval).simulated_temp.time,obj.intervals(obj.current_interval).simulated_temp.values);
            %hold on;
            %grid on;
            %plot(obj.intervals(obj.current_interval).signals(3,:)');
            
            %figure(400+obj.current_interval)
            last_temp_dist=obj.fea.sol.u(:,end);
            obj.init_temp_function_par = polyfit(0:(obj.section_len/(length(last_temp_dist)-1)):obj.section_len, last_temp_dist', MD_constant_values.temp_poly_rank);
            
            str='';
            for i=1:length(obj.init_temp_function_par)
                if obj.init_temp_function_par(i)<0
                    str=strcat(str,num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                else
                    str=strcat(str,'+',num2str(obj.init_temp_function_par(i)),'*x^',num2str(length(obj.init_temp_function_par)-i));
                end
            end
            
            
            obj.init_temp_function = str;
            
            obj.current_index=end_time;
            
            %{
            figure(501);
            hold on;
            plot(obj.fea.sol.u(1:end,end));
            text(1,obj.fea.sol.u(1,end),num2str(obj.current_interval));
            %}
        end
        
        
        function sum_diff= get_last_SP_diff(obj,n)
            
            sum_diff=0;
            
            if obj.current_interval>n
                
                for i=1:n
                    sum_diff=sum_diff+obj.intervals(end-n+i).SP_diff;
                end
                
            else
                
                for i=1:obj.current_interval
                    sum_diff=sum_diff+obj.intervals(i).SP_diff;
                end
                
            end
            
        end
        
        function sum_diff= get_SP_diff(obj)
            
            sum_diff=0;
            
            
            for i=1:obj.current_interval
                sum_diff=sum_diff+obj.intervals(i).SP_diff;
            end
            
            disp(['SP diff: ' num2str(sum_diff) ' mean SP diff ' num2str(sum_diff/obj.intervals(end).time(end))]);
            
        end
        
        
        
        function signal_long=get_signal(obj,signal_nr,start_index,end_index)
            
            %disp('-------------------- FUNCTION GET SIGNALS START --------------------');
            %disp(['Start index ' num2str(start_index) ' end index ' num2str(end_index)]);
            signal_long=[];
            
            if start_index<0
                if end_index<0
                    signal_long=obj.intervals(1).signals(signal_nr,1)*ones(1,abs(end_index-start_index+1));
                else
                    signal_long=obj.intervals(1).signals(signal_nr,1)*ones(1,abs(start_index));
                    start_index=0;
                end
            end
            
            for i=1:obj.current_interval
                if start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end) && ...
                        end_index>=obj.intervals(i).time(1) && end_index<=obj.intervals(i).time(end)
                    
                    % kawa�ek interwa�u pierwszy
                    %disp('--- INT START SHORT ---');
                    signal_interval=obj.intervals(i).signals(signal_nr,start_index-obj.intervals(i).time(1)+1:end_index-obj.intervals(i).time(1)+1);
                    signal_long=[signal_long signal_interval];
                    
                    break;
                    
                elseif start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end) && end_index>=obj.intervals(i).time(end)
                    
                    %disp(['obecny int ' num2str(i) ' pocz interwalu: ' num2str(obj.intervals(i).time(1)) ' start index: ' num2str(start_index)]);
                    % ca�y przedzia�
                    %disp('--- INT MIDDLE WHOLE ---');
                    signal_interval=obj.intervals(i).signals(signal_nr,start_index-obj.intervals(i).time(1)+1:end);
                    signal_long=[signal_long signal_interval];
                    
                    start_index=obj.intervals(i).time(end)+1;
                    
                end
            end
            
        end
        
        
        function signal_long=get_output_signal(obj,start_index,end_index)
            
            signal_long=[];
            
            if start_index<0
                signal_long=obj.intervals(1).simulated_temp_resampled(1)*ones(1,abs(start_index));
                start_index=0;
            end
            
            for i=1:obj.current_interval
                if start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end) && ...
                        end_index>=obj.intervals(i).time(1) && end_index<=obj.intervals(i).time(end)
                    signal_interval=obj.intervals(i).simulated_temp_resampled(start_index-obj.intervals(i).time(1)+1:end_index-obj.intervals(i).time(1)+1);
                    signal_long=[signal_long signal_interval];
                    
                    break;
                elseif start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end)
                    signal_interval=obj.intervals(i).simulated_temp_resampled(start_index-obj.intervals(i).time(1)+1:end);
                    signal_long=[signal_long signal_interval];
                    
                elseif end_index>=obj.intervals(i).time(1) && end_index<=obj.intervals(i).time(end)
                    signal_interval=obj.intervals(i).simulated_temp_resampled(1:end_index-obj.intervals(i).time(1)+1);
                    signal_long=[signal_long signal_interval];
                    
                end
            end
            
        end
        
        
        function plot_results(obj,figure_nr)
            
            if nargin > 1
                fig=figure(figure_nr);
            else
                fig=figure(200);
            end
            
            fig.Color=[1 1 1];
            f_size=25;
            
            for i=1:obj.current_interval
                hold on;
                plot(obj.intervals(i).simulated_temp.time,obj.intervals(i).simulated_temp.values,'k');
                p1=plot(obj.intervals(i).time,obj.intervals(i).simulated_temp_resampled,'m');
                if obj.inputs_nr==2
                    p2=plot(obj.intervals(i).time,obj.intervals(i).signals(3,:),'b');
                    p3=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'r');
                elseif obj.inputs_nr==3
                    p2=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'b');
                    p3=plot(obj.intervals(i).time,obj.intervals(i).signals(5,:),'r');
                end
            end
            xlim([0 obj.intervals(i).time(end)+1]);
            grid on;
            set(gca,'fontsize',f_size)
            legend([p1 p2 p3],{'Simulated temp.','Real temp.','Temp. SP'},'Location','southeast');
        end
        
        function plot_results_multiplot(obj)
            
            %{
            if nargin > 1
                fig=figure(figure_nr);
            else
                fig=figure(200);
            end
            
            fig.Color=[1 1 1];
            %}
            f_size=10;
            
            for i=1:obj.current_interval
                hold on;
                plot(obj.intervals(i).simulated_temp.time,obj.intervals(i).simulated_temp.values,'k');
                p1=plot(obj.intervals(i).time,obj.intervals(i).simulated_temp_resampled,'m');
                if obj.inputs_nr==2
                    if obj.sim_mode==0
                        p2=plot(obj.intervals(i).time,obj.intervals(i).signals(3,:),'b');
                    end
                    p3=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'r');
                elseif obj.inputs_nr==3
                    if obj.sim_mode==0
                        p2=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'b');
                    end
                    p3=plot(obj.intervals(i).time,obj.intervals(i).signals(5,:),'r');
                end
            end
            xlim([0 obj.intervals(i).time(end)+1]);
            grid on;
            set(gca,'fontsize',f_size)
            if obj.sim_mode==0
                legend([p1 p2 p3],{'Simulated temp.','Real temp.','Temp. SP'},'Location','southeast');
            else
                legend([p1 p3],{'Simulated temp.','Temp. SP'},'Location','southeast');
            end
        end
        
        function plot_inputs_multiplot(obj,input_nr,plot_ctrl_intervals,inerval_width)
            
            if nargin <=1
                input_nr=1;
                plot_ctrl_intervals=0;
                inerval_width=0;
            end
            
            f_size=10;
            
            max_press=MD_constant_values.mix_press_max;
            min_press=MD_constant_values.mix_press_min;
            max_cln_vlv=MD_constant_values.cln_vlv_max;
            min_cln_vlv=MD_constant_values.cln_vlv_min;
            
            
            for i=1:obj.current_interval
                hold on;
                
                if input_nr==1
                    plot(obj.intervals(i).time,obj.intervals(i).signals(2,:),'b');
                    %p3=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'r');
                    legend('Mix. press.','Location','northeast');
                    
                    if plot_ctrl_intervals
                        if strcmp(obj.applied_controller(i).input_1,'PID')
                            patch([inerval_width*(i-1) inerval_width*i inerval_width*i inerval_width*(i-1)],...
                                [min_press min_press  max_press max_press],[0 1 1],'FaceAlpha',0.1,'LineStyle','none');
                        else
                            patch([inerval_width*(i-1) inerval_width*i inerval_width*i inerval_width*(i-1)],...
                                [min_press min_press  max_press max_press],[1 1 0],'FaceAlpha',0.1,'LineStyle','none');
                        end
                    end
                    
                else
                    plot(obj.intervals(i).time,obj.intervals(i).signals(3,:),'r');
                    legend('Cln. vlv. pos.','Location','northeast');
                    
                    if plot_ctrl_intervals
                        if strcmp(obj.applied_controller(i).input_2,'PID')
                            patch([inerval_width*(i-1) inerval_width*i inerval_width*i inerval_width*(i-1)],...
                                [min_cln_vlv min_cln_vlv  max_cln_vlv max_cln_vlv],[0 1 1],'FaceAlpha',0.1,'LineStyle','none');
                        else
                            patch([inerval_width*(i-1) inerval_width*i inerval_width*i inerval_width*(i-1)],...
                                [min_cln_vlv min_cln_vlv  max_cln_vlv max_cln_vlv],[1 1 0],'FaceAlpha',0.1,'LineStyle','none');
                        end
                    end
                    
                    
                end
            end
            
            xlim([0 obj.intervals(i).time(end)+1]);
            grid on;
            set(gca,'fontsize',f_size)
            %legend([p1 p2 p3],{'Simulated temp.','Real temp.','Temp. SP'},'Location','southeast');
        end
        
    end
end