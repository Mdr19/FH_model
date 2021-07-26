function [ u, X_hat] = MD_calculate_MPC_control_signal(A,B,Bd,C,K_ob,Omega,Psi,Gamma,eta_d,Lzerot,M,h,u_initial,u_max,u_min,d_max,d_min,X0,u_offset,y,sp,prev_sec_corr)

X_hat=X0;
N_sim=length(y);
n=size(A,1);
n_in=size(B,2);
u=u_initial;
Deltau_max(1)=d_max(1);       
Deltau_min(1)=d_min(1);
u_max(1)=u_max(1)-u_offset(1);
u_min(1)=u_min(1)-u_offset(1);

if n_in==2
    u_max(2)=u_max(2)-u_offset(2);
    u_min(2)=u_min(2)-u_offset(2);
    Deltau_max(2)=d_max(2);
    Deltau_min(2)=d_min(2);
end

gamma=[u_max'-u;-u_min'+u;Deltau_max';-Deltau_min'];

for kk=1:N_sim;
    Xsp=[zeros(n-1,1);sp(:,kk)];
    Xf=X_hat-Xsp;
    
    if prev_sec_corr
        eta=-Omega\(Psi*Xf)-Omega\(Gamma*eta_d);
        
        if size(Lzerot,2)>1
            d_dot=(nonzeros(Lzerot(1,:)))'*eta_d;
        else
            d_dot=Lzerot*eta_d;
        end
        
        
    else
         eta=-Omega\(Psi*Xf);
    end

    udot=Lzerot*eta;
    active_constraints=zeros(1,size(M,1));
    
    if n_in==1
        
        if u(1)>u_max(1)
            active_constraints(1)=1;
        elseif u(1)<u_min(1)
            active_constraints(2)=1;
        end
        
        if udot(1)>Deltau_max(1)
            active_constraints(3)=1;
        elseif udot(1)<Deltau_min(1)
            active_constraints(4)=1;
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
        if active_constraints(i)==1
            M_act=[M_act; M(i,:)];
            gamma_act=[gamma_act; gamma(i,:)];
        end
    end
    
    udot_prev=udot;
    
    if sum(active_constraints)>0
        if prev_sec_corr
            l_act=-inv((M_act*inv(Omega)*M_act'))*(gamma_act+M_act*inv(Omega)*(Psi*Xf+Gamma*eta_d));
            eta=-Omega\(Psi*Xf)-Omega\(Gamma*eta_d)-Omega\(M_act'*l_act);
        else
            l_act=-inv((M_act*inv(Omega)*M_act'))*(gamma_act+M_act*inv(Omega)*(Psi*Xf));
            eta=-Omega\(Psi*Xf)-Omega\(M_act'*l_act);
        end
        udot=Lzerot*eta;
    end
    
    
    if n_in==1
        
        if isnan(udot)
            
            if udot_prev>Deltau_max(1)
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot_prev<Deltau_min(1)
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
        else
            
            if udot(1)>Deltau_max(1)
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot(1)<Deltau_min(1)
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
        end
        
    elseif n_in==2
        
        if isnan(udot)
            
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
            
        else
            
            if udot(1)>Deltau_max(1)
                udot(1)=min(Deltau_max(1),(u_max(1)-u(1))/h);
            elseif udot(1)<Deltau_min(1)
                udot(1)=max(Deltau_min(1),(u_min(1)-u(1))/h);
            end
            
            if udot(2)>Deltau_max(2)
                udot(2)=min(Deltau_max(2),(u_max(2)-u(2))/h);
            elseif udot(2)<Deltau_min(2)
                udot(2)=max(Deltau_min(2),(u_min(2)-u(2))/h);
            end
            
        end
        
    end
    
    h2 = h/2; h3 = h/3; h6 = h3/2;
    
    if prev_sec_corr %&& 0==1
        dx1=(A*X_hat+K_ob*(y(kk)-C*X_hat))+B*udot+Bd*d_dot;
        dx2=(A*(X_hat+h2*dx1)+K_ob*(y(kk)-C*(X_hat+h2*dx1)))+B*udot+Bd*d_dot;
        dx3=(A*(X_hat+h2*dx2)+K_ob*(y(kk)-C*(X_hat+h2*dx2)))+B*udot+Bd*d_dot;
        dx4=(A*(X_hat+h*dx3)+K_ob*(y(kk)-C*(X_hat+h*dx3)))+B*udot+Bd*d_dot;
    else
        dx1=(A*X_hat+K_ob*(y(kk)-C*X_hat))+B*udot;
        dx2=(A*(X_hat+h2*dx1)+K_ob*(y(kk)-C*(X_hat+h2*dx1)))+B*udot;
        dx3=(A*(X_hat+h2*dx2)+K_ob*(y(kk)-C*(X_hat+h2*dx2)))+B*udot;
        dx4=(A*(X_hat+h*dx3)+K_ob*(y(kk)-C*(X_hat+h*dx3)))+B*udot;
    end
    
    X_hat=X_hat+h3*(dx2+dx3)+h6*(dx1+dx4);
    
    u=u+udot*h;
    gamma=[u_max'-u;-u_min'+u;Deltau_max';-Deltau_min'];
end

disp(['Single iter, init. error: '  num2str(num2str(sp(1)-y(1))) ', X_hat: ' num2str(X_hat')  ', Xsp: ' num2str(Xsp') ', ctrl. ' num2str(u'+u_offset) ' u dot ' num2str(udot')]);

end

