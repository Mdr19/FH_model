function [ current_model ] = MD_model_ident_LSM(sys_input,sys_output,plot_nr)
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

ni_min=MD_MFM_model_ident_LSM(ident_inputs_nr,sys_ident_input,sys_output);

ni_min


disp('Budowa A');
for i=1:m-1
    for j=1:m-1
        if i==m-1
            A(j,i)=ni_min(j);
        elseif j==i+1
            A(j,i)=1;
        else
            A(j,i)=0;
        end
    end
end

B=zeros(m-1,ident_inputs_nr);

k=1;
disp('Budowa B');
for i=1:ident_inputs_nr
    for j=1:n
        B(j,i)=ni_min(m-1+k);
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

current_model.A=A;
current_model.B=B;
current_model.C=C;
current_model.D=D;
current_model.vector=ni_min;


t=0:length(sys_ident_input)-1;

%for i=1:ident_inputs_nr
    state_space=ss(A,B,C,D);
    pv_temp_u=lsim(state_space,sys_ident_input,t);
%end

pv_=sum(pv_temp_u');

if MD_constant_values.sum_sqr_difference
    disp(['Results 1 identification ' num2str(sumsqr(sys_output'-pv_))]);
else
    disp(['Results 1 identification ' num2str(sum(abs(sys_output'-pv_)))]);
end

figure(plot_nr); %(floor(second(now)));
hold on
plot(pv_(:,:,end));
%plot(results_plot);
plot(sys_output);
grid on;
legend('Model ident', 'System output');

end

