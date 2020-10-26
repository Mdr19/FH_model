function [ params_opt ] = GS_MISO_ident_sim_fnc( params_vector,inputs_nr, input_signals, output_signal, T_end)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%y_sim=[];
%t=0:length(input_signals)-1;
step_=0.01;
t=0:step_:T_end;
h=MD_constant_values.h;
n=MD_constant_values.n;
m=MD_constant_values.m;

disp_GS=MD_constant_values.disp_GS;

%ni_min_=[-1; params_vector];
ni_min_=params_vector;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%funkcja modulujaca identyfikacja
mod_func=modulating_func(0:step_:h,h);
mod_func=mod_func(2:end);
max_mod=max(mod_func);
mod_func=mod_func/max_mod;


k=max(n,m);

u_dot=[];
y_dot=[];

for i=1:k-1
    mod_func_d(i,:)=(1/max_mod)*modulating_func_d(i,0:step_:h,h);
end

mod_func_d=mod_func_d(:,2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cnt=1:length(output_signal)
    
    if (cnt>h/step_)
        %(cnt1<=change_end(current_interval))  (cnt1<zero_lin(current_interval+2)
        
        %disp('Ident');
        
        current_out=output_signal(cnt-h/step_:cnt);
        
        %IDENTYFIKACJA DLA DLUGIEGO OKNA
        %Wyjscie i jego pochodne
        for i=1:m
            if i==1
                con=conv(current_out,mod_func);
                con=con(1:floor(length(con)/2));
                s(i)=con(end);
            else
                con=conv(current_out,mod_func_d(i-1,:));
                con=con(1:floor(length(con)/2));
                s(i)=con(end);
            end
        end
        
        y_dot=[y_dot s'];
    end
end

modulated_out=y_dot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ni_min_=[-1; ni_min_];

disp('Budowa A');
for i=1:m-1
    for j=1:m-1
        if i==m-1
            A(j,i)=-ni_min_(j)/ni_min_(m);
        elseif j==i+1
            A(j,i)=1;
        else
            A(j,i)=0;
        end
    end
end

disp('Budowa B');
B=zeros(m-1,inputs_nr);
%{
for i=1:ident_inputs_nr
    B(:,i)=zeros(m-1,1);
    B(1,i)=ni_min(m+i)/ni_min(m);
end
%}
k=1;
for i=1:inputs_nr
    for j=1:n
        B(j,i)=-ni_min_(m+k)/ni_min_(m);
        k=k+1;
    end
end
%{
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
D=zeros(m-1,1);
%}

for i=1:inputs_nr
    models(i).A=A;
    models(i).B=B(:,i);
    models(i).C=zeros(1,m-1);
    models(i).C(end)=1;
    models(i).D=[0];
    models(i).vector=[ni_min_(1:m); ni_min_(m+n*(i-1)+1:m+n*i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(models)
    state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
    y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
    [model(i).u_d, model(i).y_d]=obtain_modulated_signals_SISO(input_signals(i,:),y_sim(i,:));
    model(i).vector=[ni_min_(1:m); ni_min_(m+n*(i-1)+1:m+n*i)];
end



figure(123);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(output_signal);
plot(sum(y_sim));
legend('y1','y2','original','sum');

disp(['Roznica model initial ' num2str(sumsqr(sum(y_sim)-output_signal))]);

%{
for i=1:length(models)
    disp(['Ident SISO model nr ' num2str(i)]);
    [model(i).params model(i).u_dot model(i).y_dot]=ident_SISO_model_LSM(input_signals(i,:),output_signal-y_sim(i,:),m,i*10);
end
%}
%{
X=[];

for i=1:m-1
    X(i,:)=y_dot(i,:);
end

for i=1:inputs_nr
    X(i+m-1,:)=u_dot(i,:);
end
%}

X=[];
p=[];

%{
for i=1:length(models)
    for j=2:m
        X_(j-1,:)=model(i).y_d(j,:);
    end
    
    X_(m,:)=model(i).u_d;
    X=[X; X_];
    
    p_=model(i).vector;
    p=[p; p_];
    %k=k+1;
end
%}

X=[];
Y=[];
k=1;


for i=1:length(models)
    for j=2:m
        X_(j-1,:)=model(i).y_d(j,:);
    end
    
    %X_(m,:)=model(i).u_d;
    
    for j=1:n
        X_(m+j-1,:)=model(i).u_d(j,:);
    end
    
    X=[X; X_];
    
    p_=model(i).vector(2:end);
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
for k=1:length(models)
    test_model(k).vector=p((k-1)*m+1:(k-1)*m+m);
    test_model(k).vector=[-1; test_model(k).vector];
    [test_model(k).A]=obtain_SS_SISO_model(test_model(k).vector);
    %test_model(k).A
    eig(test_model(k).A)
end

sim_max_iters=MD_constant_values.sim_max_iters;
GS_max_iters=MD_constant_values.GS_max_iters;


for i=1:length(models)
    state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
    y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
    [model(i).u_d model(i).y_d]=obtain_modulated_signals_SISO(input_signals(i,:),y_sim(i,:));
    %model(i).vector=[params_vector(1:m-1);params_vector(m-1+i)];
end

model_diff(1)=sumsqr(sum(y_sim)-output_signal);
sim_models(1,:)=models;

disp(['Roznica model initial ' num2str(sumsqr(sum(y_sim)-output_signal))]);

if sum(isnan(p)==0)
    vectors_p=p;
    for i=1:length(models)
        models(1).vector=p((i-1)*m+1:(i-1)*m+m);
        models(1).vector=[-1; models(i).vector];
        %models(1).C=[0 1];
        %models(1).D=[0];
        models(1).C=zeros(1,m-1);
        models(1).C(end)=1;
        models(1).D=[0];
        
        [models(1).A,models(1).B]=obtain_SS_SISO_model(models(1).vector);
    end
else
    disp('Params vector initial nan BREAK');
end

%best_p=p;

for nr=1:sim_max_iters
    
    disp('-------------------------------------------------------------');
    
    X=[];
    
    for i=1:length(models)
        for j=2:m
            X_(j-1,:)=model(i).y_d(j,:);
        end
        
        %X_(m,:)=model(i).u_d;
        
        for j=1:n
            X_(m+j-1,:)=model(i).u_d(j,:);
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
        
        for k=1:length(models)
            test_model(k).vector=p((k-1)*m+1:(k-1)*m+m);
            test_model(k).vector=[-1; test_model(k).vector];
            [test_model(k).A]=obtain_SS_SISO_model(test_model(k).vector);
            %test_model(k).A
            eig(test_model(k).A)
        end
        
    else
        for i=1:GS_max_iters
            p=inv(L)*(Y_-U*p);
            
            if MD_constant_values.constraints
                p=solution_constraint(p);
            end
            %if disp_
            quality_factor=[quality_factor; [sum(Y_-phi*p) sum(modulated_out(1,:)-p'*X')]];
            
            if disp_GS
                disp('-----------------------------------------------------');
                disp(['Model ' num2str(nr) ' Iteration ' num2str(i)]);
                disp(['Vector quality factor ' num2str(quality_factor(i+1,1)) ' ' num2str(quality_factor(i+1,2))]);
                disp(num2str(p));
                
                for k=1:length(models)
                    test_model(k).vector=p((k-1)*m+1:(k-1)*m+m);
                    test_model(k).vector=[-1; test_model(k).vector];
                    [test_model(k).A]=obtain_SS_SISO_model(test_model(k).vector);
                    %test_model(k).A
                    eig(test_model(k).A)
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
        for i=1:length(models)
            models(i).vector=p((i-1)*m+1:(i-1)*m+m);
            models(i).vector=[-1; models(i).vector];
            %models(i).C=[0 1];
            %models(i).D=[0];
            models(i).C=zeros(1,m-1);
            models(i).C(end)=1;
            models(i).D=[0];
            [models(i).A,models(i).B]=obtain_SS_SISO_model(models(i).vector);
        end
    else
        disp('Params vector nan BREAK');
    end
    
    for i=1:length(models)
        state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
        y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
        [model(i).u_d model(i).y_d]=obtain_modulated_signals_SISO(input_signals(i,:),y_sim(i,:));
        %model(i).vector=[params_vector(1:m-1);params_vector(m-1+i)];
    end
    
    model_diff(nr+1)=sumsqr(sum(y_sim)-output_signal);
    sim_models(nr+1,:)=models;
    
    disp(['Roznica model ' num2str(nr+1) ' ' num2str(model_diff(nr+1))]);
    
    if model_diff(nr+1)>model_diff(nr)*MD_constant_values.model_diff_par
        disp('Next model worse than previous BREAK');
        break
    end
    
end

[~, best_model_nr]=min(model_diff);
best_model=sim_models(best_model_nr,:);
vectors_p(:,best_model_nr)

for i=1:length(best_model)
    state_space=ss(best_model(i).A,best_model(i).B,best_model(i).C,best_model(i).D);
    y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
end

disp('-----------------------------------------------------');
figure(124);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(output_signal);
plot(sum(y_sim));
legend('y1','y2','original','sum');
disp(['Roznica model final ' num2str(sumsqr(sum(y_sim)-output_signal))]);

figure(12);
hold on;
grid on;
plot(quality_factor(:,1));
plot(quality_factor(:,2));

inv(X'*X)*X'*modulated_out(1,:)';

end

