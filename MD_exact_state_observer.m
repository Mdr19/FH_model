function [ X_T ] = MD_exact_state_observer(state_space,t,u,y)

A=state_space.A;
B=state_space.B;
C=state_space.C;

n=size(A,1);

for i=1:length(t)
    M0(i,:,:)=expm(A'*t(i))*C'*C*expm(A*t(i));
end

M0_=trapz(t,M0);
%M0=

for i=2:length(t)
    
   
   G1_y(i,:,:)=expm(A*t(end))*inv(reshape(M0_,[n,n]))*expm(A'*t(i))*C'*y(i);
   
   G2_u(i,:,:)=expm(A*t(end))*inv(reshape(M0_,[n,n]))*reshape(trapz(t(1:i),M0(1:i,:,:)),...
       [n,n])*expm(-A*t(i))*B*u(:,i);
   
end

%disp('X end');
X_T=trapz(t,G1_y)+trapz(t,G2_u);

end

