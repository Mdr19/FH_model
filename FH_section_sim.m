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
                %{'PNV_ctrl_function_Z3_cln_vlv(u,t)'};
                
                %fea.phys.ce.eqn.coef{2,4}={[num2str(pu(1)),'*t^5+',num2str(pu(2)),'*t^4+',num2str(pu(3)),'*t^3+',num2str(pu(4)),'*t^2+',num2str(pu(5)),'*t+',num2str(pu(6))]};
                
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
            
            %global mix_press;
            global temp_zone_prev;
            %global temp_zone_prev_del;
            global glass_pull;
            global temp_SP;
            
            global E_int;
            global E_temp;
            global time_temp;
            
            global Kp;
            global Ki;
            
            global Kp_cln;
            global Ki_cln;
            
            global input_signal_applied;
            
            global sim_mode_append;         % 0 - do³¹czanie starych pomiarów, 1 - brak do³¹czania
            
            % common
            global input_signals;
            global output_signal;
            %global error_hist;
            
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
                    sim_mode_append=1;
                else
                    time_temp=0;
                end
            elseif obj.inputs_nr==3
                
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                input_signals.(strcat(obj.section_name,'_input_1'))=obj.intervals(obj.current_interval).signals(2,:);
                input_signals.(strcat(obj.section_name,'_input_2'))=obj.intervals(obj.current_interval).signals(3,:);
                glass_pull=obj.intervals(obj.current_interval).signals(6,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(5,:);
                %error_hist=[];
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    
                    Kp_cln=MD_constant_values.Kp_cln;
                    Ki_cln=MD_constant_values.Ki_cln;

                    
                    sim_mode_append=1;
                else
                    time_temp=0;
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
            obj.intervals(obj.current_interval).simulated_temp.values=obj.fea.sol.u(end,:);
            
            obj.intervals(obj.current_interval).simulated_temp_resampled=...
                interp1(obj.intervals(obj.current_interval).simulated_temp.time,obj.intervals(obj.current_interval).simulated_temp.values,obj.intervals(obj.current_interval).time);
            
            if (obj.sim_mode==1) || (obj.sim_mode==2 && sim_mode_append==1)
                                
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
                    
                    
                    input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,input_signal_applied.(strcat(obj.section_name,'_input_2')),obj.intervals(obj.current_interval).time);
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function perform_simulation_multizone(obj,end_time,prev_section)
            
            %global mix_press;
            global temp_zone_prev;
            %global temp_zone_prev_del;
            global glass_pull;
            global temp_SP;
            
            global E_int;
            global E_temp;
            global time_temp;
            
            global Kp;
            global Ki;
            
            global Kp_cln;
            global Ki_cln;

            
            global input_signal_applied;
            
            global sim_mode_append;         % 0 - do³¹czanie starych pomiarów, 1 - brak do³¹czania
            
            %global DC_model                 % zidentyfikowany model temp
            %global DC_delay                 % obecne opóŸnienie
            %global DC_initial_state
            %global DC_offset
            %global DC_signal
            
            
            % common
            global input_signals
            global output_signal;
            
            %global error_hist;
            
            obj.current_interval=obj.current_interval+1;
            
            disp('--------------------------------------------------------------------------');
            disp(['Performing simulation ' obj.section_name ': ' num2str(obj.current_index) ' ' num2str(end_time)]);
            
            signal_len=end_time-obj.current_index-1;
            
            %{
            for i=1:length(obj.signals_names)
                obj.intervals(obj.current_interval).signals(i,:)=MD_get_from_file(char(strcat(obj.file_path,'\',obj.sim_date,'\',obj.section_name,'.csv')),...
                    obj.signals_names(i),obj.current_index,end_time-1,0,MD_constant_values.FH_message_display);
            end
            %}
            
            
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
                %temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                %mix_press=obj.intervals(obj.current_interval).signals(2,:);
                
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
            elseif obj.inputs_nr==3
                
                temp_zone_prev=obj.intervals(obj.current_interval).signals(1,:);
                
                input_signals.(strcat(obj.section_name,'_input_1'))=obj.intervals(obj.current_interval).signals(2,:);
                input_signals.(strcat(obj.section_name,'_input_2'))=obj.intervals(obj.current_interval).signals(3,:);
                glass_pull=obj.intervals(obj.current_interval).signals(5,:);
                
                temp_SP=obj.intervals(obj.current_interval).signals(5,:);
                %error_hist=[];
                
                if obj.current_interval==1
                    E_int.(obj.section_name)=0;
                    E_temp=0;
                    time_temp=0;
                    
                    Kp=MD_constant_values.Kp;
                    Ki=MD_constant_values.Ki;
                    
                    Kp_cln=MD_constant_values.Kp_cln;
                    Ki_cln=MD_constant_values.Ki_cln;

                    sim_mode_append=1;
                else
                    time_temp=0;
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
            
            obj.intervals(obj.current_interval).simulated_temp.time=tlist+obj.current_index-obj.start_index;
            obj.intervals(obj.current_interval).simulated_temp.values=obj.fea.sol.u(end,:);
            
            obj.intervals(obj.current_interval).simulated_temp_resampled=...
                interp1(obj.intervals(obj.current_interval).simulated_temp.time,obj.intervals(obj.current_interval).simulated_temp.values,obj.intervals(obj.current_interval).time);
            
            if (obj.sim_mode==1) || (obj.sim_mode==2 && sim_mode_append==1)
                
                input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,input_signal_applied.(strcat(obj.section_name,'_input_1')),obj.intervals(obj.current_interval).time);
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
                    
                    input_signal_resampled=interp1(obj.intervals(obj.current_interval).simulated_temp.time,input_signal_applied.(strcat(obj.section_name,'_input_2')),obj.intervals(obj.current_interval).time);
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
        
        
        function signal_long=get_signal(obj,signal_nr,start_index,end_index)
            
            %disp('-------------------- FUNCTION GET SIGNALS START --------------------');
            %disp(['Start index ' num2str(start_index) ' end index ' num2str(end_index)]);
            signal_long=[];
            
            if start_index<0
                signal_long=obj.intervals(1).signals(signal_nr,1)*ones(1,abs(start_index));
                start_index=0;
            end
            
            for i=1:obj.current_interval
                if start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end) && ...
                        end_index>=obj.intervals(i).time(1) && end_index<=obj.intervals(i).time(end)
                    
                    % kawa³ek interwa³u pierwszy
                    %disp('--- INT START SHORT ---');
                    signal_interval=obj.intervals(i).signals(signal_nr,start_index-obj.intervals(i).time(1)+1:end_index-obj.intervals(i).time(1)+1);
                    signal_long=[signal_long signal_interval];
                    
                    break;
                    
                elseif start_index>=obj.intervals(i).time(1) && start_index<=obj.intervals(i).time(end) && end_index>=obj.intervals(i).time(end)
                    
                    %disp(['obecny int ' num2str(i) ' pocz interwalu: ' num2str(obj.intervals(i).time(1)) ' start index: ' num2str(start_index)]);
                    % ca³y przedzia³
                    %disp('--- INT MIDDLE WHOLE ---');
                    signal_interval=obj.intervals(i).signals(signal_nr,start_index-obj.intervals(i).time(1)+1:end);
                    signal_long=[signal_long signal_interval];
                    
                    start_index=obj.intervals(i).time(end)+1;
                    
                    %{
                elseif end_index>=obj.intervals(i).time(1) && end_index<=obj.intervals(i).time(end)
                    
                    % kawa³ek interwa³u ostatni
                    disp(['obecny int ' num2str(i) ' pocz interwalu: ' num2str(obj.intervals(i).time(1)) ' end index: ' num2str(end_index)]);
                    disp('--- INT END SHORT ---');
                    signal_interval=obj.intervals(i).signals(signal_nr,1:end_index-obj.intervals(i).time(1)+1);
                    signal_long=[signal_long signal_interval];
                    %}
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
        
        function plot_inputs_multiplot(obj,input_nr)
            
            if nargin <=1
                input_nr=1;
            end
            
            f_size=10;
            
            for i=1:obj.current_interval
                hold on;
                
                if input_nr==1
                    plot(obj.intervals(i).time,obj.intervals(i).signals(2,:),'b');
                    %p3=plot(obj.intervals(i).time,obj.intervals(i).signals(4,:),'r');
                    legend('Mix. press.','Location','northeast');
                    
                else
                    plot(obj.intervals(i).time,obj.intervals(i).signals(3,:),'r');
                    legend('Cln. vlv. pos.','Location','northeast');
                end
            end
            
            xlim([0 obj.intervals(i).time(end)+1]);
            grid on;
            set(gca,'fontsize',f_size)
            %legend([p1 p2 p3],{'Simulated temp.','Real temp.','Temp. SP'},'Location','southeast');
        end
        
    end
end