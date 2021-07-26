function [Omega,Psi,Gamma,Eae,Al,phi,phi_d,tau_del]=cmpc_2(A,B,Bd,p,N,Tp,Q,R)
[n,n_in]= size(B);
tau_del=0.001/max(p);
Tpm=max(Tp);
tau=0:tau_del:Tpm;
Np=length(tau);
N_pa=sum(N);
Omega=zeros(N_pa,N_pa);
Psi=zeros(N_pa,n);
S_in=zeros(n,N_pa);

Gamma=zeros(N_pa,N(1));
phi_d=[];

R_L=eye(N_pa,N_pa);
kk=1;

for i=1:n_in
    R_L(kk:kk-1+N(i),kk:kk-1+N(i))=R(i,i)*R_L(kk:kk-1+N(i),kk:kk-1+N(i));
    kk=kk+N(i);
end

[Al,L0]=lagc(p(1),N(1));
Eae=expm(A*tau_del);
Eap=expm(Al*tau_del);
L=Eap*L0;

Y=-B(:,1)*L'+Eae*B(:,1)*L0';
X=Iint(A,p(1),Y);
S_in(:,1:N(1))=X;
In_s=1;

% diturbances
if ~isempty(Bd)
    Yd=-Bd(:,1)*L'+Eae*Bd(:,1)*L0';
    Xd=Iint(A,p(1),Yd);
    S_in_d(:,1:N(1))=Xd;
end
    
% dla wektora B o kilku kolumnach
for jj=2:n_in;
    %jj, n_in
    [Al,L0]=lagc(p(jj),N(jj));
    Eap=expm(Al*tau_del);
    L=Eap*L0;
    Y=-B(:,jj)*L'+Eae*B(:,jj)*L0';
    X=Iint(A,p(jj),Y);              %pierwsze wywo³anie Iinit
    In_s=N(jj-1)+In_s;
    In_e=In_s+N(jj)-1;
    S_in(:,In_s:In_e)=X;            %liczone tylko raz i siê nie zmienia - dla pojedynczego czasu h
    
    %if ~isempty(Bd)
    %    S_in_d(:,In_s:In_e)=zeros(size(Xd,1),In_e-In_s+1);
    %end
end

S_sum=S_in;                         %update w ka¿dej iteracji

if ~isempty(Bd)
    S_sum_d=S_in_d;
end
    
for i=2:Np-1;
    kk=1;
    [Al,L0]=lagc(p(kk),N(kk));
    Eap=expm(Al*tau_del);
    S_sum(:,1:N(kk))=Eae*S_sum(:,1:N(kk))+S_in(:,1:N(kk))*(Eap^(i-1))';
    
    if ~isempty(Bd)
        S_sum_d(:,1:N(kk))=Eae*S_sum_d(:,1:N(kk))+S_in_d(:,1:N(kk))*(Eap^(i-1))';
    end
    In_s=1;
    
    % dla wektora B o kilku kolumnach
    for kk=2:n_in;
        [Al,L0]=lagc(p(kk),N(kk));
        Eap=expm(Al*tau_del);
        In_s=N(kk-1)+In_s;
        In_e=In_s+N(kk)-1;
        S_sum(:,In_s:In_e)=Eae*S_sum(:,In_s:In_e)+S_in(:,In_s:In_e)*(Eap^(i-1))';
    end
    
    phi=S_sum;
    
    if ~isempty(Bd)
        phi_d=S_sum_d;
        Gamma=Gamma+phi'*Q*phi_d;
    end
    
    Omega=Omega+phi'*Q*phi;
    Psi=Psi+phi'*Q*Eae^i;
end

Omega=Omega*tau_del+R_L;
Psi=Psi*tau_del;
Gamma=Gamma*tau_del;