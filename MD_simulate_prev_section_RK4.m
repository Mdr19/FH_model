function [y_sim] = MD_simulate_prev_section_RK4(A,B,C,h,u,X0)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%global X_hat;
%global X_hat_;

X=X0;

%global u_mpc;

N_sim=length(u);
y_sim=zeros(N_sim,1);
%t=0:h:(N_sim-1)*h;
%X_hat=X_hat+K_ob*(y0-C*X_hat);


for kk=1:N_sim;
    
    

    
    
    h2 = h/2; h3 = h/3; h6 = h3/2;
    
    dx1=A*X+B*u(kk);
    dx2=A*(X+h2*dx1)+B*u(kk);
    dx3=A*(X+h2*dx2)+B*u(kk);
    dx4=A*(X+h*dx3)+B*u(kk);
    
    X=X+h3*(dx2+dx3)+h6*(dx1+dx4);
    
    y_sim(kk)=C*X;
    %X_hat=X_hat+(A*X_hat+K_ob*(y(kk)-C*X_hat))*h+B*udot*h;
    
    
    %gamma=[u_max-u;-u_min+u];
end

%disp(['Single iter, init. error: '  num2str(num2str(y(1)-sp(1))) ', X_hat: ' num2str(X_hat')  ', Xsp: ' num2str(Xsp')]);
%disp(['Single iter, init. error: '  num2str(num2str(y(1)-sp(1))) ', X_hat: ' num2str(X_hat')  ', Xsp: ' num2str(Xsp') ', ctrl. ' num2str(u')]);

end

