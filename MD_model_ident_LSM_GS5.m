function [ best_model, model_params ] = MD_model_ident_LSM_GS5(sys_input,real_sys_output,inputs_to_ident,method_params,plot_nr)

disp('---------------------------------');
disp('MODEL IDENTIFICATION PROCEDURE');
disp('---------------------------------');

%sys_inputs_nr=size(inputs_to_ident,1);
% model divided into 2 parts
% - prev section temp
% - mixture press. and cln valve

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

%Select the best initial model rank
for i=1:method_params.ident_models_nr
    params(i).N=getfield(method_params,strcat('ident_models',num2str(i),'_N'));
    params(i).M=getfield(method_params,strcat('ident_models',num2str(i),'_M'));
    params(i).h=getfield(method_params,strcat('ident_models',num2str(i),'_h'));
    params(i).n=getfield(method_params,strcat('ident_models',num2str(i),'_n'));
    params(i).m=getfield(method_params,strcat('ident_models',num2str(i),'_m'));
    params(i).eta=getfield(method_params,strcat('ident_models',num2str(i),'_eta'));
    
    switch method_params.initial_model_method
        case 1
            ni_min=MD_MFM_MISO_ident(ident_inputs_nr,sys_ident_input,real_sys_output,method,params(i).eta',params(i));
            
            for k=1:params(i).m
                ni_min(k)=-ni_min(k);
            end
            params(i).vector=ni_min;
        case 2
            [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,real_sys_output,method_params,params(i));
            params(i).vector=[ni_min(1:params(i).m-1);-1; ni_min(params(i).m:end)];
        case 3
            [ni_min, ~]=MD_MFM_model_ident_out_LSM(ident_inputs_nr,sys_ident_input,real_sys_output,params(i));
            params(i).vector=[-1; ni_min(1:params(i).m-1); ni_min(params(i).m:end)];
            
        otherwise
            [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,real_sys_output,method_params,params(i));
            params(i).vector=[ni_min(1:params(i).m-1);-1; ni_min(params(i).m:end)];
    end
    
    %ni_min
    params(i).vector
    [test_model(i).A, test_model(i).B]=obtain_SS_MISO_model(params(i).vector,ident_inputs_nr,params(i));
    test_model(i).C=zeros(1,params(i).m-1);
    test_model(i).C(end)=1;
    test_model(i).D=zeros(1,ident_inputs_nr);
    state_space=ss(test_model(i).A,test_model(i).B,test_model(i).C,test_model(i).D);
    %eig(test_model(i).A)
    sim_out_test(i,:)=lsim(state_space,sys_input,t);
    
    if method_params.sum_sqr_difference
        sim_out_test_diff(i)=sumsqr(real_sys_output-sim_out_test(i,:)');
    else
        sim_out_test_diff(i)=sum(abs(real_sys_output-sim_out_test(i,:)'));
    end
    disp(['Results model ' num2str(i) ' select identification ' num2str(sim_out_test_diff(i))]);
    
    if method_params.ident_message_display
        figure(plot_nr+50+i);
        hold on;
        plot(sim_out_test(i,:));
        plot(real_sys_output);
    end
end

[~,best_model_initial]=min(sim_out_test_diff);

ni_min=params(best_model_initial).vector;


% sim_models - otrzymane modele na koncu kazdej iteracji
% models - modele podczas iteracji (zmieniane)
% current_models - do spr w symulacji - obecny model najlepszy
% best_model - selected best model
% current_sys_signals - actual input and outputs

model_params.N=params(best_model_initial).N;
model_params.M=params(best_model_initial).M;
model_params.h=params(best_model_initial).h;
model_params.n=params(best_model_initial).n;
model_params.m=params(best_model_initial).m;
model_params.eta=params(best_model_initial).eta;

% initial model-common denominator
best_model.A=test_model(best_model_initial).A;
best_model.B=test_model(best_model_initial).B;
best_model.C=diag(ones(model_params.m-1,1));
best_model.D=zeros(model_params.m-1,ident_inputs_nr);
best_model.vector=params(best_model_initial).vector;


if ident_inputs_nr>=3
    number_of_separate_models=2;
else
    number_of_separate_models=ident_inputs_nr;
end

% without prev zone
if inputs_to_ident(1)==0
    number_of_separate_models=number_of_separate_models-1;
end


current_sys_signals=[];

for i=1:number_of_separate_models
    models(i).A=best_model.A;
    
    if i==1
        models(i).B=best_model.B(:,i);
        models(i).vector=[best_model.vector(1:model_params.m); best_model.vector(model_params.m+model_params.n*(i-1)+1:model_params.m+model_params.n*i)];
        %current_sys_signals_in(i,:)=sys_input(i,:);
        current_sys_signals(i).input=sys_input(i,:);
        current_sys_signals(i).inputs_nr=1;
    else
        models(i).B=zeros(model_params.m-1,ident_inputs_nr-1);
        
        for j=1:ident_inputs_nr-1
            models(i).B(:,j)=best_model.B(:,j+1);
        end
        
        models(i).vector=[best_model.vector(1:model_params.m); best_model.vector(model_params.m+model_params.n*(i-1)+1:end)];
        current_sys_signals(i).input=sys_input(i:end,:);
        current_sys_signals(i).inputs_nr=ident_inputs_nr-1;
    end
    
    models(i).C=zeros(1,model_params.m-1);
    models(i).C(end)=1;
    models(i).D=zeros(1,size(models(i).B,2));
end

current_models=models;
current_sys_out_sum=zeros(length(t),1);
% split model output simulation
for i=1:length(models)
    state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
    if i==1
        current_sys_signals(i).output=lsim(state_space,sys_input(i,:),t);
    else
        current_sys_signals(i).output=lsim(state_space,sys_input(i:end,:),t);
    end
    
    current_sys_out_sum=current_sys_out_sum+current_sys_signals(i).output;
end

if method_params.sum_sqr_difference
    model_diff(1)=sumsqr(real_sys_output-current_sys_out_sum);
    disp(['Results initial model identification ' num2str(model_diff(1))]);
else
    model_diff(1)=sum(abs(real_sys_output-current_sys_out_sum));
    disp(['Results initial model identification ' num2str(model_diff(1))]);
end

initial_model_result=current_sys_out_sum;

%%
% Gauss-Seidel procedure start

if method_params.model_reident
    
    % Define new output signals for SISO models
    for i=1:length(models)
        sys_out_sim=0;
        for j=1:length(models)
            if i~=j
                sys_out_sim=sys_out_sim+current_sys_signals(j).output;
            end
        end
    end
    
    sim_max_iters=method_params.sim_max_iters;
    GS_max_iters=method_params.GS_max_iters;
    pos_next=0;
    
    % method initialization
    %disp('---------------------------------------------------');
    %disp('INITIAL');
    sim_models(1,:)=models;
    
    for i=1:number_of_separate_models
        disp(['Model ' num2str(i)]);
        models(i).p=-models(i).vector(2:end)/models(i).vector(1);
        %isPositiveDefinite(models(i).phi);
        disp(models(i).p');
        %disp(['Wynik ' num2str(sum(models(i).X*models(i).p-models(i).Y))]);
    end
    
    for nr=1:sim_max_iters
        for i=1:length(models)
            
            sys_out_sim=0;
            models(i).X=[];
            models(i).Y=[];
            
            for j=1:length(models)
                if i~=j
                    sys_out_sim=sys_out_sim+current_sys_signals(j).output;
                end
            end
            [models(i).u_d, models(i).y_d]=obtain_modulated_signals(current_sys_signals(i).input,real_sys_output-sys_out_sim,method_params,model_params);
            
            for j=2:model_params.m
                models(i).X(j-1,:)=models(i).y_d(j,:);
            end
            
            for j=1:size(models(i).u_d,1) %model_params.n
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
            
            disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' EXACT MODE']);
            
            for i=1:length(models)
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
                
                for i=1:length(models)
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
        
        for i=1:number_of_separate_models
            [models(i).A, models(i).B]=obtain_SS_MISO_model(models(i).vector,current_sys_signals(i).inputs_nr,model_params);
            models(i).C=zeros(1,model_params.m-1);
            models(i).C(end)=1;
            models(i).D=zeros(1,size(models(i).B,2));
            state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
            y_sim(i,:)=lsim(state_space,current_sys_signals(i).input,t);
            %[models(i).u_d models(i).y_d]=obtain_modulated_signals_SISO(sys_input(i,:),y_sim(i,:));
            
            sys_out_sim=0;
            for j=1:length(models)
                if i~=j
                    sys_out_sim=sys_out_sim+current_sys_signals(j).output;
                end
            end
            
            sys_out_sim=sys_out_sim+y_sim(i,:)';
            
            if method_params.sum_sqr_difference
                model_diff_temp(i)=sumsqr(real_sys_output-sys_out_sim);
                if method_params.disp_message
                    disp(['Model ' num2str(i) ' Results  re-identification ' num2str(model_diff_temp(i))]);
                end
            else
                model_diff_temp(i)=sum(abs(real_sys_output-sys_out_sim));
                if method_params.disp_message
                    disp(['Model ' num2str(i) ' Results re-identification ' num2str(model_diff_temp(i))]);
                end
            end
            
        end
        
        %check if the obtained model is better
        if nr==1
            [val_min, pos]=min(model_diff_temp);
            pos_next=pos+1;
            
            if pos_next>number_of_separate_models
                pos_next=1; %ident_inputs_nr;
            end
            
            disp(['Iter ' num2str(nr) ' current pos ' num2str(pos) ' next pos ' num2str(pos_next)]);
            disp(['Model ' num2str(pos) ' will be updated']);
            current_models(pos).A=models(pos).A;
            current_models(pos).B=models(pos).B;
            current_models(pos).C=models(pos).C;
            current_models(pos).D=models(pos).D;
            current_models(pos).vector=models(pos).vector;
            
            for i=1:number_of_separate_models
                if i~=pos
                    models(i).A=current_models(i).A;
                    models(i).B=current_models(i).B;
                    models(i).C=current_models(i).C;
                    models(i).D=current_models(i).D;
                    models(i).vector=current_models(i).vector;
                end
            end
        else
            pos=pos_next;
            %pos_next=mod(pos+(nr),ident_inputs_nr);
            
            pos_next=pos+1;
            
            if pos_next>number_of_separate_models
                pos_next=1; %ident_inputs_nr;
            end
            
            disp(['Iter ' num2str(nr) ' current pos ' num2str(pos) ' next pos ' num2str(pos_next)]);
            disp(['Model ' num2str(pos) ' will be updated']);
            current_models(pos).A=models(pos).A;
            current_models(pos).B=models(pos).B;
            current_models(pos).C=models(pos).C;
            current_models(pos).D=models(pos).D;
            current_models(pos).vector=models(pos).vector;
        end
        
        %simulation for the obtained models - zmiana 15.09
        
        for i=1:number_of_separate_models
            state_space=ss(current_models(i).A,current_models(i).B,current_models(i).C,current_models(i).D);
            %current_sys_out(i,:)=lsim(state_space,sys_input(i,:),t);
            current_sys_signals(i).output=lsim(state_space,current_sys_signals(i).input,t);
        end
        
        
        model_diff=[model_diff model_diff_temp(pos)];
        sim_models=[sim_models; current_models];
        
        if model_diff(nr+1)>=model_diff(nr)*method_params.model_diff_par
            disp('Next model worse than previous BREAK');
            break
        end
        
    end
    
    [best_model_result, best_model_nr]=min(model_diff);
    
else
    
    best_model_nr=1;
    
end

% Gauss-Seidel procedure end

%%

if best_model_nr>1
    best_model=(sim_models(best_model_nr,:));
    for i=1:length(best_model)
        best_model(i).C=diag(ones(model_params.m-1,1));
        best_model(i).D=zeros(model_params.m-1,size(best_model(i).B,2));
        
        C=zeros(1,model_params.m-1);
        C(end)=1;
        D=zeros(1,size(best_model(i).B,2));
        
        state_space=ss(best_model(i).A,best_model(i).B,C,D);
        y_sim(i,:)=lsim(state_space,current_sys_signals(i).input,t);
    end
    disp(['Model reident. Best model nr ' num2str(best_model_nr) ' results ' num2str(best_model_result)]);
else
    disp('Model NOT reident');
    state_space=ss(best_model.A,best_model.B,best_model.C,best_model.D);
    y_sim=lsim(state_space,sys_input,t);
end

if method_params.plot_new_model
    
    figure(plot_nr);
    hold on;
    grid on;
    if best_model_nr>1
        plot(y_sim(1,:));
        plot(y_sim(2,:));
        plot(real_sys_output);
        plot(initial_model_result);
        plot(sum(y_sim));
        legend('y1','y2','original','initial model','reidentified model');
    else
        plot(initial_model_result);
        plot(y_sim(:,end));
        plot(real_sys_output);
        legend('initial model','reidentified model','original');
    end
    
end

end