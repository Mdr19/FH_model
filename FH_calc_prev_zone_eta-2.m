function [ eta_d ] = FH_calc_prev_zone_eta(ident_sec,horizon,prev_sec_inp)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

tau=ident_sec.MPC_model.tau;

t=0:tau:horizon-1;
avg=2000;

prev_sec_res=interp1(0:length(prev_sec_inp)-1,prev_sec_inp,t);
%prev_sec_div=filter(-smooth_diff(avg),1,prev_sec_res)/step;
prev_sec_div=diff(prev_sec_res)/tau;
t=t(1:end-1);

figure(15)
subplot(2,1,1)
plot(t,prev_sec_res(1:end-1));
subplot(2,1,2)
plot(t,prev_sec_div);


X0=ident_sec.MPC_model.X0;
Eae=ident_sec.MPC_model.Eae;
phi_d=ident_sec.MPC_model.phi_d;

Omega=ident_sec.MPC_model.Omega;
Gamma=ident_sec.MPC_model.Gamma;


A=ident_sec.MPC_model.A;
Bd=ident_sec.MPC_model.Bd;
C=eye(size(A));
D=zeros(size(C,1),1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y=lsim(ss(A,Bd,C,D),prev_sec_div,t,X0);

eta_d=(inv(phi_d*phi_d')*phi_d)'*(y(end,:)'-Eae*X0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
delta_t=0.01;
Tm=horizon;
N_sample=Tm/delta_t;
t=0:delta_t:(N_sample-1)*delta_t;
[Ap,L0]=lagc(0.6,5);
for i=1:N_sample;
L(:,i)=expm(Ap*t(i))*L0;
end
%}

Omega\Gamma*(inv(phi_d*phi_d')*phi_d)'*(y(end,:)'-Eae*X0)

end

