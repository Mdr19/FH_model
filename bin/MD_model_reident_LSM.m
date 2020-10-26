function [interval_type, best_model] = MD_model_reident_LSM(current_model,inputs_to_ident,sys_input,sys_output,initial_state,plot_nr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%eta_MIMO=MISO_eta

sys_inputs_nr=length(inputs_to_ident);
ident_inputs_nr=sum(inputs_to_ident);

n=MD_constant_values.n;
m=MD_constant_values.m;

%method=MD_constant_values.ident_method;

sys_ident_input=[];
k=1;

for i=1:sys_inputs_nr
    if inputs_to_ident(i)==1
        sys_ident_input(k,:)=sys_input(i,:);
        k=k+1;
    end
end

%--------------------------------------------------------------------------------

%current_model

t=0:length(sys_ident_input)-1;

%for i=1:ident_inputs_nr
    state_space=ss(current_model.A,current_model.B,current_model.C,current_model.D);   
    pv_temp_u=lsim(state_space,sys_ident_input,t,initial_state);
%end

pv_curr=sum(pv_temp_u');


if MD_constant_values.sum_sqr_difference
    initial_error=sumsqr(sys_output'-pv_curr(:,:,end));
else
    initial_error=sum(abs(sys_output'-pv_curr(:,:,end)));
end




best_model=current_model;
interval_type='N';

disp(['Results for the current model ' num2str(initial_error)]);

%-------------------------------------------------------------------------------

if initial_error>MD_constant_values.model_change_threshold
    
    disp('New model identification');
    
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
    
    input_model=[];
    
    k=1;
    
 %   for i=1:sys_inputs_nr
 %       if inputs_to_ident(i)~=0
            reident_model.A=A;
            reident_model.B=B;
            reident_model.C=C;
            reident_model.D=D;
            reident_model.vector=ni_min;
  %          k=k+1;
  %      end
  %  end
    
    %input_model
    
    t=0:length(sys_ident_input)-1;
    
    %for i=1:ident_inputs_nr
        state_space=ss(A,B,C,D);
        pv_temp_u=lsim(state_space,sys_ident_input,t,initial_state);
    %end
    
    pv_=sum(pv_temp_u');
    
    if MD_constant_values.sum_sqr_difference
        reident_error=num2str(sumsqr(sys_output'-pv_));
    else
        reident_error=sum(abs(sys_output'-pv_));
    end
    
    disp(['Results re-identification ' num2str(reident_error)]);
    
    if reident_error<initial_error
        best_model=reident_model;
        interval_type='I';
    end
    
    figure(plot_nr); %(floor(second(now)));
    hold on
    plot(pv_curr(:,:,end));
    plot(pv_(:,:,end));
    %plot(sim_results(pos,:));
    %plot(results_plot);
    plot(sys_output)
    legend('Model original','Model reident', 'System output');
end

end

