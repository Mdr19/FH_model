function [ X_0 ] = MD_exact_state_observer_initial(state_space,t,u,y)

A=state_space.A;
B=state_space.B;
C=state_space.C;

n=size(A,1);

for i=1:length(t)
    M0(i,:,:)=expm(A'*t(i))*C'*C*expm(A*t(i));
end

M0_=trapz(t,M0);
%M0=

for i=1:length(t)-1
   G1_y(i,:,:)=inv(reshape(M0_,[n,n]))*expm(A'*t(i))*C'*y(i,:)';
   
   G2_u(i,:,:)=inv(reshape(M0_,[n,n]))*reshape(trapz(t(i:end),M0(i:end,:,:)),...
       [n,n])*expm(-A*t(i))*B*u(:,i);
   
end

t=t(1:end-1);

%disp('X start');
X_0=trapz(t,G1_y)+trapz(t,G2_u);
end

