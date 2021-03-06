function [ u, X_hat] = MD_calculate_MPC_control_signal( A,B,C,K_ob,Omega,Psi,Lzerot,M,h,u_initial,u_max,u_min,d_max,d_min,X0,u_offset,y,sp)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%global X_hat;
%global X_hat_;

X_hat=X0;

%global u_mpc;

N_sim=length(y);
%t=0:h:(N_sim-1)*h;

n=size(A,1);
n_in=size(B,2);
%X_hat=X_hat+K_ob*(y0-C*X_hat);

%u=0;

%X_hat=zeros(n,1);
%X_hat

u=u_initial;

%disp(['!!!!!!!!!!!!!!!!!!!!!!!11   INITIAL ERROR ' num2str(y(1)-sp(1))]);

%M=[Mu;-Mu;Lzerot;-Lzerot];
%u_max=[0;3];
%u_min=[-1;-3];
%Deltau_max=[0.4;0.4];
%Deltau_min=[-0.4;-0.4];

%max_press=MD_constant_values.mix_press_max;
%min_press=MD_constant_values.mix_press_min;

%max_cln_vlv=MD_constant_values.cln_vlv_max;
%min_cln_vlv=MD_constant_values.cln_vlv_min;

%max_press_d=MD_constant_values.mix_press_d;
%min_press_d=-MD_constant_values.mix_press_d;

%max_cln_vlv_d=MD_constant_values.cln_vlv_d;
%min_cln_vlv_d=-MD_constant_values.cln_vlv_d;

%M=[Lzerot;-Lzerot];
Deltau_max(1)=d_max(1);          %0.02  0.05
Deltau_min(1)=d_min(1);
u_max(1)=u_max(1)-u_offset(1);
u_min(1)=u_min(1)-u_offset(1);

if n_in==2
    u_max(2)=u_max(2)-u_offset(2);
    u_min(2)=u_min(2)-u_offset(2);
    Deltau_max(2)=d_max(2);
    Deltau_min(2)=d_min(2);
end

%[Mu,Mu1]=Mucon(p,N,n_in,h,0.1);
gamma=[u_max'-u;-u_min'+u;Deltau_max';-Deltau_min'];
%gamma=[u_max-u;-u_min+u];


for kk=1:N_sim;
    Xsp=[zeros(n-1,1);sp(:,kk)];
    %Xsp_=[zeros(3,1);sp1(:,kk)];
    Xf=X_hat-Xsp;
    
    %eta=QPhild(Omega,Psi*Xf,M,gamma);      % z ograniczeniami
    eta=-Omega\(Psi*Xf);
    udot=Lzerot*eta;
    
    % zmiana 24.10
    
    active_constraints=zeros(1,size(M,1));
    
    if n_in==1
        
        if u(1)>u_max(1)
            active_constraints(1)=1;
        elseif u(1)<u_min(1)
            active_constraints(2)=1;
        end
        
        if udot(1)>Deltau_max(1)
            active_constraints(3)=1;
            %h=0.0001;
        elseif udot(1)<Deltau_min(1)
            active_constraints(4)=1;
            %h=0.0001;
        end
        
    elseif n_in==2
        
        if u(1)>u_max(1)
            active_constraints(1)=1;
        elseif u(1)<u_min(1)
            active_constraints(3)=1;
        end
        
        if u(2)>u_max(2)
            active_constraints(2)=1;
        elseif u(2)<u_min(2)
            active_constraints(4)=1;
        end
        
        if udot(1)>Deltau_max(1)
            active_constraints(5)=1;
        elseif udot(1)<Deltau_min(1)
            active_constraints(7)=1;
        end
        
        if udot(2)>Deltau_max(2)
            active_constraints(6)=1;
        elseif udot(2)<Deltau_min(2)
            active_constraints(8)=1;
        end
        
    end
    
    
    M_act=[];
    gamma_act=[];
    
    for i=1:size(gamma,1)
        
        %active_constraints
        %i
        %M
        %active_constraints
        
        if active_constraints(i)==1
            M_act=[M_act; M(i,:)];
            gamma_act=[gamma_act; gamma(i,:)];
        end
    end
    
    udot_prev=udot;
    
    if sum(active_constraints)>0
        %h=0.00001;
        
        l_act=-inv((M_act*inv(Omega)*M_act'))*(gamma_act+M_act*inv(Omega)*(Psi*Xf));
        eta=-Omega\(Psi*Xf)-Omega\(M_act'*l_act);
        udot=Lzerot*eta;
        
        %udot_prev
        
    end
    
    
    if n_in==1
        
        if isnan(udot)
            %udot=udot_prev;
            if udot_prev>Deltau_max(1)
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot_prev<Deltau_min(1)
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
        else
            
            if udot(1)>Deltau_max(1)
                %udot(1)=Deltau_max(1);
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot(1)<Deltau_min(1)
                %udot(1)=Deltau_min(1);
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
        end
        
    elseif n_in==2
        
        if isnan(udot)
            %udot=udot_prev;
            %udot=zeros(n_in,1);
            
            if udot_prev(1)>Deltau_max(1)
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot_prev(1)<Deltau_min(1)
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
            if udot_prev(2)>Deltau_max(2)
                udot(2)=min(Deltau_max(2),(u_max(2)-u(2))/h);
            elseif udot_prev(2)<Deltau_min(2)
                udot(2)=max(Deltau_min(2),(u_min(2)-u(2))/h);
            end
            
            %{
    elseif sum(udot>Deltau_max)>0
        for i=1:length(udot)
            if udot(i)>Deltau_max(i)
                udot(i)=Deltau_max(i);
            end
        end
    elseif sum(udot<Deltau_min)>0
        for i=1:length(udot)
            if udot(i)>Deltau_min(i)
                udot(i)=Deltau_min(i);
            end
        end
            %}
        else
            if udot(1)>Deltau_max(1)
                %udot(1)=Deltau_max(1);
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot(1)<Deltau_min(1)
                %udot(1)=Deltau_min(1);
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
            if udot(2)>Deltau_max(2)
                %udot(2)=Deltau_max(2);
                udot(2)=min(Deltau_max(2),(u_max(2)-u(2))/h);
            elseif udot(2)<Deltau_min(2)
                %udot(2)=Deltau_min(2);
                udot(2)=max(Deltau_min(2),(u_min(2)-u(2))/h);
            end
            
        end
        
    end
    
    
    %{
    if udot>Deltau_max
        gamma_act=gamma(1,:);
        M_act=M(1,:);
        l_act=-inv((M_act*inv(Omega)*M_act'))*(gamma_act+M_act*inv(Omega)*(Psi*Xf));
        eta=-Omega\(Psi*Xf)-Omega\(M_act*l_act)';
        udot=Lzerot*eta;
    elseif udot<Deltau_min
        gamma_act=gamma(2,:);
        M_act=M(2,:);
        l_act=-inv((M_act*inv(Omega)*M_act'))*(gamma_act+M_act*inv(Omega)*(Psi*Xf));
        eta=-Omega\(Psi*Xf)-Omega\(M_act*l_act)';
        udot=Lzerot*eta;
    end
    %}
    
    %eta=-Omega\(Psi*Xf);
    %udot=Lzerot*eta;
    
    %X_hat_=X_hat_+(A*X_hat_+K_ob*(y(kk)-C*X_hat_))*h+B*udot*h
    
    
    h2 = h/2; h3 = h/3; h6 = h3/2;
    
    dx1=(A*X_hat+K_ob*(y(kk)-C*X_hat))+B*udot;
    dx2=(A*(X_hat+h2*dx1)+K_ob*(y(kk)-C*(X_hat+h2*dx1)))+B*udot;
    dx3=(A*(X_hat+h2*dx2)+K_ob*(y(kk)-C*(X_hat+h2*dx2)))+B*udot;
    dx4=(A*(X_hat+h*dx3)+K_ob*(y(kk)-C*(X_hat+h*dx3)))+B*udot;
    
    X_hat=X_hat+h3*(dx2+dx3)+h6*(dx1+dx4);
    
    
    %X_hat=X_hat+(A*X_hat+K_ob*(y(kk)-C*X_hat))*h+B*udot*h;
    %udot
    
    u=u+udot*h;
    gamma=[u_max'-u;-u_min'+u;Deltau_max';-Deltau_min'];
    %gamma=[u_max-u;-u_min+u];
end

%disp(['Single iter, init. error: '  num2str(num2str(y(1)-sp(1))) ', X_hat: ' num2str(X_hat')  ', Xsp: ' num2str(Xsp')]);
disp(['Single iter, init. error: '  num2str(num2str(sp(1)-y(1))) ', X_hat: ' num2str(X_hat')  ', Xsp: ' num2str(Xsp') ', ctrl. ' num2str(u'+u_offset) ' u dot ' num2str(udot')]);

end

