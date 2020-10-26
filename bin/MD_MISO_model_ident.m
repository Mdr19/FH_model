function [ current_model ] = MD_MISO_model_ident(sys_input,sys_output,eta,plot_nr)
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

ni_min=MD_MFM_MISO_ident(ident_inputs_nr,sys_ident_input,sys_output,method,eta);

ni_min

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
        B(j,i)=ni_min(m+k)/ni_min(m);
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
D=zeros(m-1,1);

input_model=[];


for i=1:ident_inputs_nr
        input_model(i).A=A;
        input_model(i).B=B(:,i);
        input_model(i).C=C;
        input_model(i).D=D;
        input_model(i).vector=[ni_min(1:m); ni_min(m+i)];
end

input_model

t=0:length(sys_ident_input)-1;

for i=1:ident_inputs_nr
    state_space=ss(A,B(:,i),C,D);
    pv_temp_u(i,:,:)=lsim(state_space,sys_ident_input(i,:),t);
end

pv_=sum(pv_temp_u);

if MD_constant_values.sum_sqr_difference
    disp(['Results 1 identification ' num2str(sumsqr(sys_output'-pv_(:,:,end)))]);
else
    disp(['Results 1 identification ' num2str(sum(abs(sys_output'-pv_(:,:,end))))]);
end

initial_state=zeros(ident_inputs_nr,rank(A));

models_temp=[];

for initial_nr=1:ident_inputs_nr
    
    %disp('------------------------------------');
    
    model_temp=input_model;
    
    disp('----------------------');
    for i=1:ident_inputs_nr-1
        
        current_nr=initial_nr+(i-1);
        
        if current_nr>ident_inputs_nr
            current_nr=mod((initial_nr+(i-1)),ident_inputs_nr);
        end
        
        disp(['Nr modelu ' num2str(current_nr)]);
        
        output_sim_temp=MD_simulate_MISO_without_selected(model_temp,initial_state,...
            sys_ident_input,current_nr);
        
        [A,B,C,D,vector]=MD_MFM_SISO_ident(sys_ident_input(current_nr,:),...
            sys_output-output_sim_temp',method,MD_constant_values.SISO_eta);
        
        %model_temp(current_nr)=ss(A,B,C,D);
        
        model_temp(current_nr).A=A;
        model_temp(current_nr).B=B;
        model_temp(current_nr).C=C;
        model_temp(current_nr).D=D;
        
        model_temp(current_nr).vector=vector;
    end
    
    models_temp=[models_temp; model_temp];
    
end

sim_results=[];

for i=1:length(models_temp)
    
    %sim_result=[];
    sim_result=[];
    
    for j=1:ident_inputs_nr
        
        A=models_temp(i,j).A;
        B=models_temp(i,j).B;
        C=models_temp(i,j).C;
        D=models_temp(i,j).D;
        
        state_space=ss(A,B,C,D);
        sim_res=lsim(state_space,sys_ident_input(j,:),t);
        sim_result(j,:)=sim_res(:,end);
        %{
        if j==1
           sim_results=sim_result(:,end)';
        else
           sim_results(i,:)=sim_results(i,:)+sim_result(:,end)';
        end
        %}
        
    end
    
    sim_results=[sim_results; sum(sim_result)];
    
end

for i=1:length(models_temp)
    if MD_constant_values.sum_sqr_difference
        sim_diff(i)=sumsqr(sim_results(i,:)'-sys_output);
    else
        sim_diff(i)=sum(abs(sim_results(i,:)'-sys_output));
    end
end



if MD_constant_values.GaussSeidel_method==0 || ident_inputs_nr==1
    [val pos]=min(sim_diff);
    disp(['Results ident final ' num2str(val)]);
    current_model=models_temp(pos,:);
    
    results_plot=sim_results(pos,:);
else
    
    sim_results2=[];
    models_temp2=[];
    sim_diff2=[];
    
    for initial_nr=1:ident_inputs_nr
        
        disp('------------------------------------');
        disp(['Initial model ' num2str(initial_nr) ' result ' num2str(sim_diff(initial_nr))]);
        
        model_current=models_temp(initial_nr,:);
        sim_res_curr=sim_results(initial_nr,:);
        res_curr=sim_diff(initial_nr);
        
        res_prev=inf;
        i=0;
        
        sim_res=res_curr;
        
        while res_curr<res_prev
            
            res_prev=res_curr;
            
            model_temp=model_current;
            
            current_nr=initial_nr+(ident_inputs_nr-1)+i;
            current_nr=current_nr-floor(current_nr/ident_inputs_nr)*ident_inputs_nr;
            
            if current_nr==0
                current_nr=ident_inputs_nr;
            end
            
            disp(['Nr modelu ' num2str(current_nr)]);
            
            output_sim_MISO_temp=MD_simulate_MISO_without_selected(model_temp,initial_state,...
                sys_ident_input,current_nr);
            
            [A,B,C,D,vector]=MD_MFM_SISO_ident(sys_ident_input(current_nr,:),...
                sys_output-output_sim_MISO_temp',method,MD_constant_values.SISO_eta);
            
            model_temp(current_nr).A=A;
            model_temp(current_nr).B=B;
            model_temp(current_nr).C=C;
            model_temp(current_nr).D=D;
            model_temp(current_nr).vector=vector;
            
            output_sim_SISO_temp=MD_simulate_SISO_selected(model_temp(current_nr),...
                initial_state(current_nr,:),sys_ident_input(current_nr,:));
            
            sim_temp=output_sim_MISO_temp+output_sim_SISO_temp(:,end)';
            if MD_constant_values.sum_sqr_difference
                diff_temp=sumsqr(sys_output'-(output_sim_MISO_temp+output_sim_SISO_temp(:,end)'));
            else
                diff_temp=sum(abs(sys_output'-(output_sim_MISO_temp+output_sim_SISO_temp(:,end)')));
            end
                
            if diff_temp<res_prev
                disp(['System updating - result: ' num2str(diff_temp)]);
                model_current=model_temp;
                sim_res_curr=sim_temp;
                res_curr=diff_temp;
                %model_temp.A
                
                %figure(initial_nr*10+current_nr);
                %plot(sys_output);
                %hold on
                %plot(model_temp_res);
                %plot(output_sim_MISO_temp+output_sim_SISO_temp(:,end)');
                
            else
                disp(['Not updating - result: ' num2str(diff_temp)]);
                break;
            end
            
            i=i+1;
        end
        
        sim_results2=[sim_results2; sim_res_curr];
        models_temp2=[models_temp2; model_current];
        sim_diff2=[sim_diff2; res_curr];
        
    end
    
    [val pos]=min(sim_diff2);
    disp(['Results ident final ' num2str(val)]);
    current_model=models_temp2(pos,:);
    
    results_plot=sim_results2(pos,:);
    
end

%-------------------------------------------------------------------------------




figure(plot_nr); %(floor(second(now)));
hold on
plot(pv_(:,:,end));
plot(results_plot);
plot(sys_output)
legend('Model initial', 'Model final', 'System output');

%{
  figure(plot_nr+1); %(floor(second(now)+1));
  hold on;
  for i=1:sys_inputs_nr
    plot(sys_ident_input(i,:));
  end
%}

end

