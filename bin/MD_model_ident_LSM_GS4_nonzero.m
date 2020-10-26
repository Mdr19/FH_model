function [ best_model, model_params, model_initial_state] = MD_model_ident_LSM_GS4_nonzero(sys_input,sys_output,plot_nr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%eta_MIMO=MISO_eta
disp('---------------------------------------');
disp('MODEL IDENTIFICATION PROCEDURE NON-ZERO');
disp('---------------------------------------');

method=MD_constant_values.ident_method;

%sys_inputs_nr=size(inputs_to_ident,1);
ident_inputs_nr=size(sys_input,1);

%n=MD_constant_values.n;
%m=MD_constant_values.m;

method=MD_constant_values.ident_method;

sys_ident_input=[];
k=1;

for i=1:ident_inputs_nr
    sys_ident_input(k,:)=sys_input(i,:);
    k=k+1;
end

%time for simulation
t=0:length(sys_ident_input)-1;
%t2=zero_time:length(sys_ident_input);

%Select the best initial model rank
for i=1:MD_constant_values.ident_models_nr
    params(i).N=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_N'));
    params(i).M=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_M'));
    params(i).h=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_h'));
    params(i).n=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_n'));
    params(i).m=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_m'));
    params(i).eta=getfield(MD_constant_values,strcat('ident_models',num2str(i),'_eta'));
    
    switch MD_constant_values.initial_model_method
        case 1
            ni_min=MD_MFM_MISO_ident(ident_inputs_nr,sys_ident_input,sys_output,method,params(i).eta',params(i));
            for k=1:params(i).m
                ni_min(k)=-ni_min(k);
            end
            params(i).vector=ni_min
        case 2
            [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output,params(i));
            params(i).vector=[ni_min(1:params(i).m-1);-1; ni_min(params(i).m:end)];
        case 3
            [ni_min, ~]=MD_MFM_model_ident_out_LSM(ident_inputs_nr,sys_ident_input,sys_output,params(i));
            params(i).vector=[-1; ni_min(1:params(i).m-1); ni_min(params(i).m:end)];
            
        otherwise
            [ni_min, ~]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output,params(i));
            params(i).vector=[ni_min(1:params(i).m-1);-1; ni_min(params(i).m:end)];
    end
        
    [test_model(i).A, test_model(i).B]=obtain_SS_MISO_model(params(i).vector,ident_inputs_nr,params(i));
    test_model(i).C=zeros(1,params(i).m-1);
    test_model(i).C(end)=1;
    test_model(i).D=zeros(1,ident_inputs_nr);
    state_space=ss(test_model(i).A,test_model(i).B,test_model(i).C,test_model(i).D);
    %eig(test_model(i).A)
    test_model(i).initial_state=MD_exact_state_observer_initial(state_space,t,sys_input,sys_output);
    %sim_out_test(i,:)=lsim(state_space,sys_input(:,zero_time:end),t2);
    if sum(isnan(test_model(i).initial_state))==0
    sim_out_test(i,:)=lsim(state_space,sys_input,t,test_model(i).initial_state);
    
    if MD_constant_values.sum_sqr_difference
        sim_out_test_diff(i)=sumsqr(sys_output-sim_out_test(i,:)');
    else
        sim_out_test_diff(i)=sum(abs(sys_output-sim_out_test(i,:)'));
    end
    disp(['Results model select identification ' num2str(sim_out_test_diff(i))]);
    
    %{
    figure(i);
    hold on;
    plot(t,sim_out_test(i,:));
    plot(sys_output);
    %}
    else
        disp('INITIAL STATE NAN');
        sim_out_test_diff(i)=inf;
    end
end

[~,best_model_initial]=min(sim_out_test_diff);

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
model_initial_state=test_model(best_model_initial).initial_state;

figure(plot_nr); %(floor(second(now)));
hold on;
grid on;
plot(sys_output);
plot(sim_out_test(best_model_initial,:));
legend('original','model');
%}
end