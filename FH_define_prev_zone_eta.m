function [ eta_d ] = FH_define_prev_zone_eta(Ap,Lzerot,signal,T_p)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

t=0:1:T_p;


y_=interp1([0 T_p],[signal(1) signal(end)],t);
yd=diff(y_);

if size(Lzerot,2)>1
    Lzerot=(nonzeros(Lzerot(1,:)))';
end

for i=1:length(t)
    L_t(i,:)=expm(Ap*t(i))*Lzerot';
end

L_t=L_t(1:end-1,:);
eta_d2=inv(L_t'*L_t)*L_t'*(yd)';


figure(30)
plot(L_t*eta_d2)
%}

figure(30)
plot(y_);

n=length(Lzerot);
eta_d=ones(n,1)*yd(1)/(n*Lzerot(1))

Lzerot*eta_d2

Lzerot*eta_d

end


