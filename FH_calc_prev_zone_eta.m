function [ eta_d ] = FH_calc_prev_zone_eta(A,Bd,tau,X0,Ap,Lzerot,phi,phi_d,t0,T_p,signal )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Eae=expm(A*T_p);
t=0:1:T_p;

t0=floor(t0(1));

if t0<=0
    t0=1;
elseif t0>T_p
    t0=T_p;
end

y_=interp1([0 T_p],[signal(t0) signal(end)],t);
yd=diff(y_);

for i=1:length(t)
    L_t(i,:)=expm(Ap*t(i))*Lzerot';
end

L_t=L_t(1:end-1,:);
%figure(15)
%plot(t,y_);

%prev_sec_diff=ones(size(y_))*((signal(end)-signal(t0))/T_p)*tau;

%ddot=((signal(end)-signal(t0))/T_p)*tau;

%phi_d=1;

%C=eye(size(A));
%D=zeros(size(C,1),1);

%t=t(1:end-1);

%y=lsim(ss(A,Bd,C,D),prev_sec_diff,t,X0);
%eta_d=(inv(phi_d*phi_d')*phi_d)'*(y(end,:)'-Eae*X0);

%[phi_d*eta_d y(end,:)'-Eae*X0]

eta_d=inv(L_t'*L_t)*L_t'*(yd)';

Lzerot*eta_d

end

