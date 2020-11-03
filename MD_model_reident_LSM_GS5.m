function [ interval_type, best_model ] = MD_model_reident_LSM_GS5(start_model,model_params,inputs_to_ident,sys_input,sys_output,initial_state,method_params,plot_nr)

disp('---------------------------------');
disp('MODEL REIDENTIFICATION PROCEDURE');
disp('---------------------------------');

%sys_inputs_nr=size(inputs_to_ident,1);
ident_inputs_nr=size(sys_input,1);
method=method_params.ident_method;

sys_ident_input=[];
k=1;

for i=1:ident_inputs_nr
    sys_ident_input(k,:)=sys_input(i,:);
    k=k+1;
end

%time for simulation
t=0:length(sys_ident_input)-1;

model_len=length(start_model);
zero_initial_state=sum(initial_state(1,:));

if model_len>1 %&& method_params.model_reident
    disp('Set of SISO models');
    state=1;
elseif ((model_len==1) && (zero_initial_state==0)) && method_params.model_reident
    disp('Model single. Zero initial state');
    state=2;
else
    disp('Model single. Non-zero initial state or wihout GS method');
    state=3;
end

interval_type='N';
best_model=start_model;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
current_sys_signals=[];

%{
for i=1:model_len
    current_input_len=size(start_model(i).B,2);
    current_sys_signals(i).inputs_nr=current_input_len;
    current_sys_signals(i).input=sys_input(i:i+current_input_len-1,:);
    
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:model_len
    current_input_len=size(start_model(i).B,2);
    current_sys_signals(i).inputs_nr=current_input_len;
    current_sys_signals(i).input=sys_input(i:i+current_input_len-1,:);
    
end

if length(sys_output)>model_params.h
    
    % simulation for the current model
    
    switch(state)
        case 1
            
            
            
            for i=1:length(start_model)
                C=zeros(1,model_params.m-1);
                C(end)=1;
                D=[0];
                state_space=ss(start_model(i).A,start_model(i).B,C,D);
                initial_model_out(:,i)=lsim(state_space,current_sys_signals(i).input,t,initial_state(i,:));
                current_input_len=size(start_model(i).B,2);
                current_sys_signals(i).inputs_nr=current_input_len;
                current_sys_signals(i).input=sys_input(i:i+current_input_len-1,:);
            end
            
        otherwise
            
            C=zeros(1,model_params.m-1);
            C(end)=1;
            D=[0];
            state_space=ss(start_model.A,start_model.B,C,D);
            initial_model_out=lsim(state_space,current_sys_signals.input,t,initial_state(1,:));
            
            
            
    end
    
    if method_params.sum_sqr_difference
        model_diff(1)=sumsqr(sys_output-sum(initial_model_out,2));                  % dla pojedynczego moelu tez dziala
        disp(['Results model original identification ' num2str(model_diff(1))]);
    else
        model_diff(1)=sum(abs(sys_output-sum(initial_model_out,2)));
        disp(['Results model original identification ' num2str(model_diff(1))]);
    end
    
    
    % obtain the initial re-ident systems
    
    switch(state)
        case 1
            
            % nothing to do
            
            
        otherwise
            
            % first step of re-identification - obtaining the MFM vector
            
            switch method_params.initial_model_method
                case 1
                    eta=model_params.eta;
                    ni_min=MD_MFM_MISO_ident(ident_inputs_nr,sys_ident_input,sys_output,method,eta',model_params);
                    
                    for k=1:model_params.m
                        ni_min(k)=-ni_min(k);
                    end
                    %params(i).
                    vector=ni_min;
                case 2
                    [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output,method_params,model_params);
                    %params(i).
                    vector=[ni_min(1:model_params.m-1);-1; ni_min(model_params.m:end)];
                case 3
                    [ni_min, ~]=MD_MFM_model_ident_out_LSM(ident_inputs_nr,sys_ident_input,sys_output,method_params,model_params);
                    %params(i).
                    vector=[-1; ni_min(1:model_params.m-1); ni_min(model_params.m:end)];
                    
                otherwise
                    [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output,method_params,model_params);
                    %params(i).
                    vector=[ni_min(1:model_params.m-1);-1; ni_min(model_params.m:end)];
            end
            
    end
    
    
    
    % method initialization and initial simulation - first
    % re-identification
    
    switch (state)
        
        case 1
            %tylko przepisanie ze starego modelu do nowego
            
            for i=1:model_len
                
                
                %disp(['Model ' num2str(i)]);
                models(i).A=start_model(i).A;
                models(i).B=start_model(i).B;
                models(i).C=zeros(1,model_params.m-1);
                models(i).C(end)=1;
                models(i).D=zeros(1,size(models(i).B,2));
                models(i).vector=start_model(i).vector;
                models(i).p=-models(i).vector(2:end)/models(i).vector(1);
                %disp(models(i).p');
                
                state_space=ss(models(i).A,models(i).B,C,D);
                current_sys_signals(i).output=lsim(state_space,current_sys_signals(i).input,t,initial_state(i,:));
            end
            
            start_models=models;
            
        case 2
            % inicjalizacja na podstawie otrzymanego poprzednio wektora
            % zmiana struktury current_sys_inputs
            
            sys_out_sim=0;
            model_len=max(length(start_model),method_params.min_inputs_ident);      % uwzglednic sytuacje gdy dlugosc moelu mniejsza niz min liczba wejsc

            
            if method_params.alternative_model_method && model_len>=3
                model_len=2;
            end 
                
            
            model_len
                
            for i=1:model_len
                
                if i==1
                    
                    %vector=best_model.vector;
                    
                    models(i).vector=[vector(1:model_params.m); vector(model_params.m+model_params.n*(i-1)+1:model_params.m+model_params.n*i)];
                    %current_sys_signals_in(i,:)=sys_input(i,:);
                    %inputs_nr=1;
                    current_sys_signals(i).inputs_nr=1;
                    current_sys_signals(i).input=sys_input(i,:);
                    
                else
                    models(i).vector=[vector(1:model_params.m); vector(model_params.m+model_params.n*(i-1)+1:end)];
                    %inputs_nr=ident_inputs_nr-1;
                    current_sys_signals(i).inputs_nr=ident_inputs_nr-1;
                    %if ident_inputs_nr>2
                    current_sys_signals(i).input=sys_input(i:end,:);
                    %else
                    %current_sys_signals(i).input=sys_input(i,:);
                    %end
                    
                end
                
                [models(i).A, models(i).B]=obtain_SS_MISO_model(models(i).vector,current_sys_signals(i).inputs_nr,model_params);
                
                models(i).C=zeros(1,model_params.m-1);
                models(i).C(end)=1;
                models(i).D=zeros(1,size(models(i).B,2));
                models(i).p=-models(i).vector(2:end)/models(i).vector(1);
                
                state_space=ss(models(i).A,models(i).B,C,D);
                current_sys_signals(i).output=lsim(state_space,current_sys_signals(i).input,t);
                sys_out_sim=sys_out_sim+current_sys_signals(i).output;
            end
            
            if method_params.sum_sqr_difference
                model_diff(2)=sumsqr(sys_output-sys_out_sim);
                disp(['Results 1 re-identification ' num2str(model_diff(2))]);
            else
                model_diff(2)=sum(abs(sys_output-sys_out_sim));
                disp(['Results 1 re-identification ' num2str(model_diff(2))]);
            end
            
            start_models=models;
            initial_state=zeros(ident_inputs_nr,model_params.m-1);
            
            
            if model_diff(2)<model_diff(1)
                
                disp('CASE 2 obtained model better than current');
                [best_model.A, best_model.B, best_model.C, best_model.D]=obtain_SS_MISO_model(vector,ident_inputs_nr,model_params);
                best_model.vector=vector;
                interval_type='R';
                
            end
            
            
        case 3
            
            % MFM re-identification only
            
            [test_model.A, test_model.B, test_model.C, test_model.D]=obtain_SS_MISO_model(vector,ident_inputs_nr,model_params);
            test_model.vector=vector;
            C=zeros(1,model_params.m-1);
            C(end)=1;
            D=zeros(1,ident_inputs_nr);
            state_space=ss(test_model.A,test_model.B,C,D);
            %eig(test_model.A)
            start_model_out=lsim(state_space,sys_input,t,initial_state(end,:));
            
            if method_params.sum_sqr_difference
                model_diff(2)=sumsqr(sys_output-sum(start_model_out,2));
                disp(['Results 1 identification ' num2str(model_diff(2))]);
            else
                model_diff(2)=sum(abs(sys_output-sum(start_model_out,2)));
                disp(['Results 1 identification ' num2str(model_diff(2))]);
            end
            
            if model_diff(2)<model_diff(1)
                
                disp('CASE 3 obtained model better than current');
                best_model=test_model;
                interval_type='R';
                
            else
                disp('CASE 3 obtained model nod updated');
            end
            
        otherwise
            
            interval_type='N';
            best_model=start_model;
            
    end
    
    % w³asciwa identyfikacja modeli - jak poprzednio iteracyjnie
    
    if state==1 || state==2
        
        sim_max_iters=method_params.sim_max_iters;
        GS_max_iters=method_params.GS_max_iters;
        pos_next=0;
        
        if state==1
            sim_models(1,:)=models;
        else
            sim_models(2,:)=models;
        end
        
        %%
        % Gauss-Seidel procedure start
        %current_SISO_out=start_model_out;
        
        % sim_models - otrzymane modele na koncu kazdej iteracji
        % models - modele podczas iteracji (zmieniane)
        % current_models - do spr w symulacji - obecny model najlepszy
        % best_model - selected best model
        % current_sys_signals - actual input and outputs
        
        
        for nr=1:sim_max_iters
            %disp('---------------------------------------------------');
            %disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters)]);
            
            for i=1:length(models)
                
                sys_out_sim=0;
                models(i).X=[];
                models(i).Y=[];
                
                for j=1:length(models)
                    if i~=j
                        %sys_out_sim=sys_out_sim+start_model_out(:,j);
                        sys_out_sim=sys_out_sim+current_sys_signals(j).output;
                    end
                end
                [models(i).u_d, models(i).y_d]=obtain_modulated_signals(current_sys_signals(i).input,sys_output-sys_out_sim,method_params,model_params);
                
                for j=2:model_params.m
                    models(i).X(j-1,:)=models(i).y_d(j,:);
                end
                
                for j=1:size(models(i).u_d,1)
                    models(i).X(j+model_params.m-1,:)=models(i).u_d(j,:);
                end
                
                models(i).X=models(i).X';
                models(i).Y=models(i).y_d(1,:)';
                
                %p(i,1)=-ni_min(1);
                models(i).p=-models(i).vector(2:end)/models(i).vector(1);
                
                models(i).phi=models(i).X'*models(i).X;
                models(i).L=tril(models(i).phi);
                models(i).U=models(i).phi-models(i).L;
                
                models(i).Y_=models(i).X'*models(i).Y;
                disp('---------------------------------------------------');
                disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters)]);
                isPositiveDefinite(models(i).phi);
                
            end
            
            if method_params.method_exact_mode
                
                disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' EXACT MODE ']);
                
                for i=1:model_len
                    if (nr==1) || (i==pos_next)
                        models(i).p=inv(models(i).X'*models(i).X)*models(i).X'*models(i).Y;
                        disp(models(i).p')
                        disp(['Wynik ' num2str(sum(models(i).X*models(i).p-models(i).Y))]);
                        models(i).vector=[-1; models(i).p];
                    end
                end
                
            else
                for iter=1:GS_max_iters
                    if method_params.disp_message
                        disp('---------------------------------------------------');
                        disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' iter ' num2str(iter) ' of ' num2str(GS_max_iters)]);
                    end
                    
                    for i=1:model_len
                        if (nr==1) || (i==pos_next)
                            models(i).p=inv(models(i).L)*(models(i).Y_-models(i).U*models(i).p);
                            models(i).vector=[-1; models(i).p];
                            if method_params.disp_message
                                disp(models(i).p')
                                disp(['Wynik ' num2str(sum(models(i).X*models(i).p-models(i).Y))]);
                            end
                        end
                    end
                    
                end
            end
            
            model_diff_temp=[];
            
            for i=1:model_len
                [models(i).A, models(i).B]=obtain_SS_MISO_model(models(i).vector,current_sys_signals(i).inputs_nr,model_params);
                models(i).C=zeros(1,model_params.m-1);
                models(i).C(end)=1;
                models(i).D=zeros(1,size(models(i).B,2));
                %models(i).A
                %models(i).B
                %models(i).vector
                %models(i).A
                
                state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
                y_sim(:,i)=lsim(state_space,current_sys_signals(i).input,t,initial_state(i,:));
                %[models(i).u_d models(i).y_d]=obtain_modulated_signals_SISO(sys_input(i,:),y_sim(i,:));
                
                sys_out_sim=0;
                for j=1:length(models)
                    if i~=j
                        %sys_out_sim=sys_out_sim+start_model_out(:,j);
                        sys_out_sim=sys_out_sim+current_sys_signals(j).output;
                    end
                end
                
                sys_out_sim=sys_out_sim+y_sim(:,i);
                
                if method_params.sum_sqr_difference
                    model_diff_temp(i)=sumsqr(sys_output-sys_out_sim);
                    if method_params.disp_message
                        disp(['Model ' num2str(i) ' Results  re-identification ' num2str(model_diff_temp(i))]);
                    end
                else
                    model_diff_temp(i)=sum(abs(sys_output-sys_out_sim));
                    if method_params.disp_message
                        disp(['Model ' num2str(i) ' Results re-identification ' num2str(model_diff_temp(i))]);
                    end
                end
                
            end
            
            %check if the obtained model is better
            
            if nr==1
                [val_min, pos]=min(model_diff_temp);
                pos_next=pos+1;
                
                if pos_next>model_len
                    pos_next=1; %ident_inputs_nr;
                end
                
                disp(['Iter ' num2str(nr) ' current pos ' num2str(pos) ' next pos ' num2str(pos_next)]);
                disp(['Model ' num2str(pos) ' will be updated']);
                start_models(pos).A=models(pos).A;
                start_models(pos).B=models(pos).B;
                start_models(pos).C=models(pos).C;
                start_models(pos).D=models(pos).D;
                start_models(pos).vector=models(pos).vector;
                
                for i=1:model_len
                    if i~=pos
                        models(i).A=start_models(i).A;
                        models(i).B=start_models(i).B;
                        models(i).C=start_models(i).C;
                        models(i).D=start_models(i).D;
                        models(i).vector=start_models(i).vector;
                    end
                end
            else
                pos=pos_next;
                %pos_next=mod(pos+(nr),ident_inputs_nr);
                
                pos_next=pos+1;
                
                if pos_next>model_len
                    pos_next=1; %ident_inputs_nr;
                end
                
                disp(['Iter ' num2str(nr) ' current pos ' num2str(pos) ' next pos ' num2str(pos_next)]);
                disp(['Model ' num2str(pos) ' will be updated']);
                start_models(pos).A=models(pos).A;
                start_models(pos).B=models(pos).B;
                start_models(pos).C=models(pos).C;
                start_models(pos).D=models(pos).D;
                start_models(pos).vector=models(pos).vector;
                
            end
            
            %simulation for the obtained models
            
            for i=1:model_len
                state_space=ss(start_models(i).A,start_models(i).B,start_models(i).C,start_models(i).D);
                % zmiana 15.09
                current_sys_signals(i).output=lsim(state_space,current_sys_signals(i).input,t);
                %start_model_out(i,:)=lsim(state_space,sys_input(i,:),t);
            end
            
            
            model_diff=[model_diff model_diff_temp(pos)];
            sim_models=[sim_models; start_models];
            
            if (state==1 && model_diff(nr+1)>=model_diff(nr)*method_params.model_diff_par) ||...
                    (state==2 && model_diff(nr+2)>=model_diff(nr+1)*method_params.model_diff_par)
                disp('Next model worse than previous BREAK');
                break
            end
            
            
            
        end
        
        [best_model_result, best_model_nr]=min(model_diff);
        
        % Gauss-Seidel procedure end
        %%
        
        y_sim=[];
        
        switch state
            case 1
                if best_model_nr>1
                    
                    best_model=(sim_models(best_model_nr,:));
                    
                    for i=1:length(best_model)
                        best_model(i).C=diag(ones(model_params.m-1,1));
                        best_model(i).D=zeros(model_params.m-1,size(best_model(i).B,2));
                    end
                    
                    interval_type='R';
                    disp(['Model reident. Best model nr ' num2str(best_model_nr) ' results ' num2str(best_model_result)]);
                else
                    disp('Model NOT reident');
                end
                
                
            case 2
                if best_model_nr>2
                    
                    best_model=(sim_models(best_model_nr,:));
                    
                    for i=1:length(best_model)
                        best_model(i).C=diag(ones(model_params.m-1,1));
                        best_model(i).D=zeros(model_params.m-1,size(best_model(i).B,2));
                    end
                    
                    interval_type='R';
                    disp(['Model reident. Best model nr ' num2str(best_model_nr) ' results ' num2str(best_model_result)]);
                else
                    disp('Model NOT reident');
                end
        end
    end
    
    for i=1:length(best_model)
        if length(best_model)==1
            C=zeros(1,model_params.m-1);
            C(end)=1;
            D=[0];
            state_space=ss(best_model.A,best_model.B,C,D);
            y_sim=lsim(state_space,sys_input,t,initial_state(1,:));        % POPRAWIC !!!!!!!!!!!!!!!!!
        else
            C=zeros(1,model_params.m-1);
            C(end)=1;
            D=[0];
            state_space=ss(best_model(i).A,best_model(i).B,C,D);
            y_sim(:,i)=lsim(state_space,current_sys_signals(i).input,t,initial_state(i,:));
        end
    end
    
    if method_params.plot_reident
        
        figure(plot_nr);
        hold on;
        grid on;
        if length(best_model)>1
            plot(y_sim(:,1));
            plot(y_sim(:,2));
            plot(sys_output);
            plot(sum(y_sim,2));
            plot(sum(initial_model_out,2));
            legend('y1','y2','original','sum','initial');
        else
            plot(y_sim(:,end));
            plot(sys_output);
            plot(sum(initial_model_out,2));
            legend('sum','original','initial');
        end
        %}
    end
end
end