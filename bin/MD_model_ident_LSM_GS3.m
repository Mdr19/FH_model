function [ current_model ] = MD_model_ident_LSM_GS3(sys_input,sys_output,plot_nr)
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

%[ni_min, modulated_out]=MD_MFM_model_ident_out_LSM(ident_inputs_nr,sys_ident_input,sys_output);
[ni_min, modulated_out]=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output);


ni_min=[ni_min(1:m-1);-1; ni_min(m:end)];
%ni_min=[-1 -1 -1 -1 1 1]';

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
    models(i).A=A;
    models(i).B=B(:,i);
    models(i).C=zeros(1,m-1);
    models(i).C(end)=1;
    models(i).D=[0];
    models(i).vector=[ni_min(1:m); ni_min(m+n*(i-1)+1:m+n*i)];
end

current_model.A=A;
current_model.B=B;
current_model.C=diag(ones(m-1,1));
current_model.D=zeros(m-1,ident_inputs_nr);

%current_model=input_model;


t=0:length(sys_ident_input)-1;

for i=1:length(models)
    state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
    y_sim(i,:)=lsim(state_space,sys_input(i,:),t);
    [models(i).u_d, models(i).y_d]=obtain_modulated_signals_SISO(sys_input(i,:),y_sim(i,:));
    %models(i).vector=[ni_min_(1:m); ni_min_(m+n*(i-1)+1:m+n*i)];
    %model(i).vector=[params_vector(1:m-1);params_vector(m-1+n*(i-1)+1:m-1+n*i)];
end

%pv_=sum(pv_temp_u);
%model_diff(1)=sumsqr(pv_-sys_output);


if MD_constant_values.sum_sqr_difference
    model_diff(1)=sumsqr(sys_output-sum(y_sim)');
    disp(['Results 1 identification ' num2str(model_diff(1))]);
else
    model_diff(1)=sum(abs(sys_output-sum(y_sim)'));
    disp(['Results 1 identification ' num2str(model_diff(1))]);
end

figure(plot_nr); %(floor(second(now)));
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(sys_output);
plot(sum(y_sim));
legend('y1','y2','original','sum');


X=[];
p=[];
Y=[];
k=1;



for i=1:ident_inputs_nr
    
    %X(i,:)=models(i).y_d(1,:);
    
    X_=[];
    p_=[];
    
    for j=2:m
        X_(j-1,:)=models(i).y_d(j,:);
    end
    
    for j=1:n
        X_(j+m-1,:)=models(i).u_d(j,:);
    end
    
    p_=models(i).vector(2:end);
    %p(i,1)=-ni_min(1);
    %models(i).p=models(i).vector(2:end);
    
    X=[X; X_];
    p=[p; p_];
end

%p=p';
Y=modulated_out(1,:);

sim_max_iters=MD_constant_values.sim_max_iters;
GS_max_iters=MD_constant_values.GS_max_iters;

% method initialization

X=X';
phi=X'*X;
Y_=X'*modulated_out(1,:)';

isPositiveDefinite(phi)
L=tril(phi);
U=phi-L;

disp('INITIAL');
p
sim_models(1,:)=models;

disp(['Wynik ' num2str(sum(p'*X'-Y))]);


for nr=1:sim_max_iters
    disp('-------------------------------------------------------------');
    
    if MD_constant_values.method_exact_mode
        
        disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' exact mode ']);
        disp(['Wynik ' num2str(sum(p'*X'-Y))]);
        
        p=inv(X'*X)*X'*modulated_out(1,:)'
        
    else
        for iter=1:GS_max_iters
            
            disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' iter ' num2str(iter) ' of ' num2str(GS_max_iters)]);
            p
            disp(['Wynik ' num2str(sum(p'*X'-Y)) ' wynik w³. ' num2str(sum(p'*phi-Y_'))]);
            
            p=inv(L)*(Y_-U*p);
            %p
            
            if sum(isnan(p))>0
                break;
            end
            
            if MD_constant_values.constraints
                p=solution_constraint(p);
            end
            p
            
            for i=1:ident_inputs_nr
                models(i).vector=[-1; p((i-1)*(m-1+n)+1:(i-1)*(m-1+n)+m-1+n)];
            end
            
        end
    end
    
    for i=1:ident_inputs_nr
        [models(i).A, models(i).B]=obtain_SS_SISO_model(models(i).vector);
        models(i).C=zeros(1,m-1);
        models(i).C(end)=1;
        models(i).D=[0];
        state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
        y_sim(i,:)=lsim(state_space,sys_input(i,:),t);
        [models(i).u_d, models(i).y_d]=obtain_modulated_signals_SISO(sys_input(i,:),y_sim(i,:));
    end
    
    model_diff=[model_diff; sumsqr(sum(y_sim)'-sys_output)];
    sim_models=[sim_models; models];
    
    model_diff
    
    if model_diff(nr+1)>model_diff(nr)*MD_constant_values.model_diff_par
        disp('Next model worse than previous BREAK');
        break
    else
        
        X=[];
        p=[];
        
        for i=1:ident_inputs_nr
            
            X_=[];
            p_=[];
            
            for j=2:m
                X_(j-1,:)=models(i).y_d(j,:);
            end
            
            for j=1:n
                X_(j+m-1,:)=models(i).u_d(j,:);
            end
            
            p_=models(i).vector(2:end);
            %p(i,1)=-ni_min(1);
            %models(i).p=models(i).vector(2:end);
            
            X=[X; X_];
            p=[p; p_];
            
        end
        
        X=X';
        phi=X'*X;
        Y_=X'*modulated_out(1,:)';
        
        isPositiveDefinite(phi)
        L=tril(phi);
        U=phi-L;
        
        
    end
    
    
end

[~, best_model_nr]=min(model_diff);

model_diff_org=model_diff;
%sim_models=sim_models(2:end,:);
%model_diff=model_diff(2:end);

best_model=sim_models(best_model_nr,:);
%vectors_p(:,best_model_nr)

for i=1:length(best_model)
    state_space=ss(best_model(i).A,best_model(i).B,best_model(i).C,best_model(i).D);
    y_sim(i,:)=lsim(state_space,sys_input(i,:),t);
end

%if best_model_nr>1
for i=1:length(best_model)
    current_model(i).A=best_model(i).A;
    current_model(i).B=best_model(i).B;
    current_model(i).C=diag(ones(m-1,1));
    current_model(i).D=zeros(m-1,1);
end
%end

figure(124);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(sys_output);
plot(sum(y_sim));
legend('y1','y2','original','sum');
%}
end
