function [ current_model ] = MD_model_ident_LSM_GS(sys_input,sys_output,plot_nr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%eta_MIMO=MISO_eta

%sys_inputs_nr=size(inputs_to_ident,1);
ident_inputs_nr=size(sys_input,1);

n=MD_constant_values.n;
m=MD_constant_values.m;

method=MD_constant_values.ident_method;

sys_ident_input=[];
k=1;

for i=1:ident_inputs_nr
    sys_ident_input(k,:)=sys_input(i,:);
    k=k+1;
end

[ni_min, modulated_out]=MD_MFM_model_ident_out_LSM(ident_inputs_nr,sys_ident_input,sys_output);

ni_min=[-1; ni_min];


disp('Budowa A');
for i=1:m-1
    for j=1:m-1
        if i==m-1
            A(j,i)=-ni_min(j)/ni_min(m);
        elseif j==i+1
            A(j,i)=1;
        else
            A(j,i)=0;
        end
    end
end

disp('Budowa B');
B=zeros(m-1,ident_inputs_nr);
%{
for i=1:ident_inputs_nr
    B(:,i)=zeros(m-1,1);
    B(1,i)=ni_min(m+i)/ni_min(m);
end
%}
k=1;
for i=1:ident_inputs_nr
    for j=1:n
        B(j,i)=-ni_min(m+k)/ni_min(m);
        k=k+1;
    end
end

disp('Budowa C');
for i=1:m-1
    for j=1:m-1
        if i==j
            C(i,j)=1;
        else
            C(i,j)=0;
        end
    end
end

disp('Budowa D');
D=zeros(m-1,ident_inputs_nr);
%{
for i=1:ident_inputs_nr
    input_model(i).A=A;
    input_model(i).B=B(:,i);
    input_model(i).C=C;
    input_model(i).D=D;
    input_model(i).vector=ni_min;
end

current_model=input_model;
%}


for i=1:ident_inputs_nr
    input_model(i).A=A;
    input_model(i).B=B(:,i);
    input_model(i).C=zeros(1,m-1);
    input_model(i).C(end)=1;
    input_model(i).D=[0];
    input_model(i).vector=[ni_min(2:m); ni_min(m+n*(i-1)+1:m+n*i)];
end

current_model.A=A;
current_model.B=B;
current_model.C=diag(ones(m-1,1));
current_model.D=zeros(m-1,ident_inputs_nr);

%current_model=input_model;


t=0:length(sys_ident_input)-1;

for i=1:ident_inputs_nr
    %C=zeros(1,m-1);
    %C(end)=1;
    state_space=ss(input_model(i).A,input_model(i).B,input_model(i).C,input_model(i).D);
    pv_temp_u(i,:)=lsim(state_space,sys_ident_input(i,:),t);
    [input_model(i).u_d, input_model(i).y_d]=obtain_modulated_signals_SISO(sys_ident_input(i,:),pv_temp_u(i,:));
end

pv_=sum(pv_temp_u);


if MD_constant_values.sum_sqr_difference
    model_diff(1)=sumsqr(sys_output-pv_');
    disp(['Results 1 identification ' num2str(model_diff(1))]);
else
    model_diff(1)=sum(abs(sys_output-pv_'));
    disp(['Results 1 identification ' num2str(model_diff(1))]);
end

figure(plot_nr); %(floor(second(now)));
hold on
plot(pv_);
%plot(results_plot);
plot(sys_output);
grid on;
legend('Model ident', 'System output');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%model_diff(1)=sumsqr(sum(y_sim)-sys_output);
sim_models(1,:)=input_model;

%{
X=[];
p=[];


X=[];
Y=[];
k=1;


for i=1:length(input_model)
    for j=2:m
        X_(j-1,:)=input_model(i).y_d(j,:);
    end
    
    %X_(m,:)=model(i).u_d;
    
    for j=1:n
        X_(m+j-1,:)=input_model(i).u_d(j,:);
    end
    
    X=[X; X_];
    
    p_=input_model(i).vector;
    p=[p; p_];
    %k=k+1;
end

X=X';

phi=X'*X;
Y_=X'*modulated_out(1,:)';

isPositiveDefinite(phi)

L=tril(phi);
U=phi-L;

%quality_factor=[];
quality_factor=[sum(Y_-phi*p) sum(modulated_out(1,:)-p'*X')];
disp(['Vector initial quality factor ' num2str(quality_factor(end,1)) ' ' num2str(quality_factor(end,2))]);
disp(num2str(p));
for k=1:length(input_model)
    vector=p((k-1)*m+1:(k-1)*m+m);
    %test_model(k).vector=[-1; test_model(k).vector];
    A=obtain_SS_SISO_model([-1; vector]);
    %test_model(k).A
    eig(A)
end

sim_max_iters=MD_constant_values.sim_max_iters;
GS_max_iters=MD_constant_values.GS_max_iters;


%disp(['Roznica model initial ' num2str(sumsqr(sum(y_sim)-sys_output))]);

if sum(isnan(p)==0)
    vectors_p=p;
    %{
    for i=1:length(models)
        models(1).vector=p((i-1)*m+1:(i-1)*m+m);
        models(1).vector=[-1; models(i).vector];
        %models(1).C=[0 1];
        %models(1).D=[0];
        models(1).C=zeros(1,m-1);
        models(1).C(end)=1;
        models(1).D=[0];
        
        [models(1).A,models(1).B]=obtain_SS_SISO_model([-1; models(1).vector],m);
    end
    %}
else
    disp('Params vector initial nan BREAK');
end


for nr=1:sim_max_iters
    
    disp('-------------------------------------------------------------');
    
    X=[];
    
    for i=1:length(input_model)
        for j=2:m
            X_(j-1,:)=input_model(i).y_d(j,:);
        end
        
        %X_(m,:)=model(i).u_d;
        
        for j=1:n
            X_(m+j-1,:)=input_model(i).u_d(j,:);
        end
        
        X=[X; X_];
        
    end
    
    X=X';
    
    phi=X'*X;
    Y_=X'*modulated_out(1,:)';
    
    if ~isPositiveDefinite(phi)
        break;
    end
    
    L=tril(phi);
    U=phi-L;
    
    %quality_factor=[];
    quality_factor=[sum(Y_-phi*p) sum(modulated_out(1,:)-p'*X')];
    disp(['Model ' num2str(nr) ' initial quality factor ' num2str(quality_factor(1,1)) ' ' num2str(quality_factor(1,2))]);
    disp(num2str(p));
    
    if MD_constant_values.method_exact_mode==1
        p=inv(X'*X)*X'*modulated_out(1,:)'
        
        for k=1:length(input_model)
            vector=p((k-1)*m+1:(k-1)*m+m);
            %test_model(k).vector=[-1; test_model(k).vector];
            A=obtain_SS_SISO_model([-1; vector]);
            %test_model(k).A
            eig(A)
        end
        
    else
        for i=1:GS_max_iters
            p=inv(L)*(Y_-U*p);
            
            if MD_constant_values.constraints
                p=solution_constraint(p);
            end
            
            %if disp_
            quality_factor=[quality_factor; [sum(Y_-phi*p) sum(modulated_out(1,:)-p'*X')]];
            
            if MD_constant_values.disp_GS
                disp('-----------------------------------------------------');
                disp(['Model ' num2str(nr) ' Iteration ' num2str(i)]);
                disp(['Vector quality factor ' num2str(quality_factor(i+1,1)) ' ' num2str(quality_factor(i+1,2))]);
                disp(num2str(p));
                
                for k=1:length(input_model)
                    vector=p((k-1)*m+1:(k-1)*m+m);
                    %test_model(k).vector=[-1; test_model(k).vector];
                    A=obtain_SS_SISO_model([-1; vector]);
                    %test_model(k).A
                    eig(A)
                end
            end
            
            if abs(sum(modulated_out(1,:)-p'*X'))<MD_constant_values.GS_threshold;
                disp(['Iteracja ' num2str(i) ' BREAK Dokladnosc osiagnieta ' num2str(abs(sum(modulated_out(1,:)-p'*X')))]);
                break;
            elseif i==GS_max_iters
                disp(['Iteracja ' num2str(i) ' Osiagnieto MAX ITER']);
            end
            
        end
    end
    %end
    if sum(isnan(p)==0)
        vectors_p=[vectors_p p];
        for i=1:length(input_model)
            input_model(i).vector=p((i-1)*m+1:(i-1)*m+m);
            %input_model(i).vector=[-1; models(i).vector];
            %models(i).C=[0 1];
            %models(i).D=[0];
            input_model(i).C=zeros(1,m-1);
            input_model(i).C(end)=1;
            input_model(i).D=[0];
            [input_model(i).A,input_model(i).B]=obtain_SS_SISO_model([-1; input_model(i).vector]);
        end
    else
        disp('Params vector nan BREAK');
    end
    
    for i=1:length(input_model)
        state_space=ss(input_model(i).A,input_model(i).B,input_model(i).C,input_model(i).D);
        y_sim(i,:)=lsim(state_space,sys_input(i,:),t);
        [input_model(i).u_d, input_model(i).y_d]=obtain_modulated_signals_SISO(sys_input(i,:),y_sim(i,:));
        %input_model(i).vector=[params_vector(1:m-1);params_vector(m-1+i)];
    end
    
    model_diff(nr+1)=sumsqr(sum(y_sim)-sys_output');
    sim_models(nr+1,:)=input_model;
    
    disp(['Roznica model ' num2str(nr+1) ' ' num2str(model_diff(nr+1))]);
    
    if model_diff(nr+1)>model_diff(nr)*MD_constant_values.model_diff_par
        disp('Next model worse than previous BREAK');
        break
    end
    
end
%}
[~, best_model_nr]=min(model_diff);
best_model=sim_models(best_model_nr,:);
%vectors_p(:,best_model_nr)

for i=1:length(best_model)
    state_space=ss(best_model(i).A,best_model(i).B,best_model(i).C,best_model(i).D);
    y_sim(i,:)=lsim(state_space,sys_input(i,:),t);
end

disp('-----------------------------------------------------');
figure(124);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(sys_output);
plot(sum(y_sim));
legend('y1','y2','original','sum');
disp(['Roznica model final ' num2str(sumsqr(sum(y_sim)-sys_output'))]);

figure(12);
hold on;
grid on;
%{
plot(quality_factor(:,1));
plot(quality_factor(:,2));

inv(X'*X)*X'*modulated_out(1,:)';

for i=1:length(best_model)
    current_model(i).A=best_model(i).A;
    current_model(i).B=best_model(i).B;
    current_model(i).C=diag(ones(m-1,1));
    current_model(i).D=zeros(m-1,1);
end
%}

end
