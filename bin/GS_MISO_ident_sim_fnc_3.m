function [ params_opt ] = GS_MISO_ident_sim_fnc_3( ni_min_,inputs_nr, input_signals, output_signal, T_end)
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
%ni_min_=params_vector;

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
%ni_min_=[-1; ni_min_];

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
    %input_model(i).vector=[ni_min(2:m); ni_min(m+n*(i-1)+1:m+n*i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(models)
    state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
    y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
    [models(i).u_d, models(i).y_d]=obtain_modulated_signals_SISO(input_signals(i,:),y_sim(i,:));
    %models(i).vector=[ni_min_(1:m); ni_min_(m+n*(i-1)+1:m+n*i)];
    %model(i).vector=[params_vector(1:m-1);params_vector(m-1+n*(i-1)+1:m-1+n*i)];
end

model_diff(1)=sumsqr(sum(y_sim)-output_signal);

figure(123);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(output_signal);
plot(sum(y_sim));
legend('y1','y2','original','sum');

disp(['Roznica model initial ' num2str(sumsqr(sum(y_sim)-output_signal))]);


X=[];
p=[];
Y=[];
k=1;

for i=1:inputs_nr
    
    X(i,:)=models(i).y_d(1,:);
    
    for j=2:m
        models(i).X(j-1,:)=models(i).y_d(j,:);
    end
    
    for j=1:n
        models(i).X(j+m-1,:)=models(i).u_d(j,:);
    end
    
    p(i,1)=-ni_min_(1);
    models(i).p=models(i).vector(2:end);
    
end

sim_max_iters=MD_constant_values.sim_max_iters;
GS_max_iters=MD_constant_values.GS_max_iters;

% method initialization

X=X';
phi=X'*X;
Y_=X'*modulated_out(1,:)';

isPositiveDefinite(phi)
L=tril(phi);
U=phi-L;

for i=1:inputs_nr
    models(i).phi=models(i).X*models(i).X';
    %coef=p(i)/sum(p);
    models(i).Y_=[];
    models(i).L=tril(models(i).phi);
    models(i).U=models(i).phi-models(i).L;
    models(i).p=models(i).vector(2:end);
    isPositiveDefinite(models(i).phi);
end

disp('INITIAL');
models.p
sim_models(1,:)=models;

disp(['Wynik ' num2str(sum(models(2).p'*models(2).X+models(1).p'*models(1).X-modulated_out(1,:)))]);


for nr=1:sim_max_iters
    disp('-------------------------------------------------------------');
    
    if MD_constant_values.method_exact_mode
        
        disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' exact mode ']);
        disp(['Wynik ' num2str(sum(models(2).p'*models(2).X+models(1).p'*models(1).X-modulated_out(1,:)))]);
        
        p=inv(X'*X)*X'*modulated_out(1,:)'
        
        for i=1:inputs_nr
            
            sum_=0;
            
            for k=1:inputs_nr
                if i~=k
                    sum_=sum_+models(k).y_d(1,:)'*p(k);
                end
            end
            
            out=modulated_out(1,:)'-sum_;
            
            %models(i).Y_=models(i).X*modulated_out(1,:)'*coef;
            models(i).Y_=models(i).X*out;               %modulated_out(1,:)'*coef;
            %models(i).p=inv(models(i).L)*(models(i).Y_-models(i).U*models(i).p);
            models(i).p=inv(models(i).X*models(i).X')*models(i).X*out;
            models(i).p
            models(i).vector=[-1; models(i).p];
        end
        
        
    else
        for iter=1:GS_max_iters
            
            disp(['Model ' num2str(nr) ' of ' num2str(sim_max_iters) ' iter ' num2str(iter) ' of ' num2str(GS_max_iters)]);
            disp(['Wynik ' num2str(sum(models(2).p'*models(2).X+models(1).p'*models(1).X-modulated_out(1,:)))]);
            
            p=inv(L)*(Y_-U*p);
            p
            for i=1:inputs_nr
                
                
                if MD_constant_values.diff_mode
                    sum_=0;
                    
                    for k=1:inputs_nr
                        if i~=k
                            sum_=sum_+models(k).y_d(1,:)'*p(k);
                        end
                    end
                    
                    out=modulated_out(1,:)'-sum_;
                    
                    %models(i).Y_=models(i).X*modulated_out(1,:)'*coef;
                    models(i).Y_=models(i).X*out;               %modulated_out(1,:)'*coef;
                    models(i).p=inv(models(i).L)*(models(i).Y_-models(i).U*models(i).p);
                    models(i).p
                    models(i).vector=[-1; models(i).p];
                    
                else
                    models(i).Y_=models(i).X*models(i).y_d(1,:)';
                    models(i).p=inv(models(i).L)*(models(i).Y_-models(i).U*models(i).p);
                    models(i).p
                    models(i).vector=[-1; models(i).p]*p(i);
                end
                
            end
            
        end
    end
    for i=1:inputs_nr
        [models(i).A, models(i).B]=obtain_SS_SISO_model(models(i).vector);
        models(i).C=zeros(1,m-1);
        models(i).C(end)=1;
        models(i).D=[0];
        state_space=ss(models(i).A,models(i).B,models(i).C,models(i).D);
        y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
        [model(i).u_d model(i).y_d]=obtain_modulated_signals_SISO(input_signals(i,:),y_sim(i,:));
    end
    
    model_diff=[model_diff; sumsqr(sum(y_sim)-output_signal)];
    sim_models=[sim_models; models];
    
    if model_diff(nr+1)>model_diff(nr)
        disp('Next model worse than previous BREAK');
        break
    else
        
        X=[];
        
        for i=1:inputs_nr
            
            X(i,:)=models(i).y_d(1,:);
            
            for j=2:m
                models(i).X(j-1,:)=models(i).y_d(j,:);
            end
            
            for j=1:n
                models(i).X(j+m-1,:)=models(i).u_d(j,:);
            end
            
            p(i,1)=-models(i).vector(1);
            %models(i).p=models(i).vector(2:end);
            
        end
        
        X=X';
        phi=X'*X;
        Y_=X'*modulated_out(1,:)';
        
        isPositiveDefinite(phi)
        L=tril(phi);
        U=phi-L;
        
        for i=1:inputs_nr
            models(i).phi=models(i).X*models(i).X';
            %coef=p(i)/sum(p);
            %models(i).Y_=models(i).X*modulated_out(1,:)'*coef;
            models(i).L=tril(models(i).phi);
            models(i).U=models(i).phi-models(i).L;
            models(i).p=models(i).vector(2:end);
            isPositiveDefinite(models(i).phi);
        end
        
    end
    
    
end

[~, best_model_nr]=min(model_diff);
best_model=sim_models(best_model_nr,:);
%vectors_p(:,best_model_nr)

for i=1:length(best_model)
    state_space=ss(best_model(i).A,best_model(i).B,best_model(i).C,best_model(i).D);
    y_sim(i,:)=lsim(state_space,input_signals(i,:),t);
end


figure(124);
hold on;
grid on;
plot(y_sim(1,:));
plot(y_sim(2,:));
plot(output_signal);
plot(sum(y_sim));
legend('y1','y2','original','sum');

end

