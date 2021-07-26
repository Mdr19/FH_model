function [Phi_Phi,Phi_F,Phi_R,Phi_Phi_d,A_e, B_e, B_d, C_e]=dmpc_2(Ap,Bp,Bd,Cp,Nc,Np)
[m1,n1]=size(Cp);
[n1,n_in]=size(Bp);
A_e=eye(n1+m1,n1+m1);
A_e(1:n1,1:n1)=Ap;
A_e(n1+1:n1+m1,1:n1)=Cp*Ap;
B_e=zeros(n1+m1,n_in);
B_e(1:n1,:)=Bp;
B_e(n1+1:n1+m1,:)=Cp*Bp;

B_d=zeros(n1+m1,1);
B_d(1:n1,:)=Bd;
B_d(n1+1:n1+m1,:)=Cp*Bd;

C_e=zeros(m1,n1+m1);
C_e(:,n1+1:n1+m1)=eye(m1,m1);

n=n1+m1;
h(1,:)=C_e;
F(1,:)=C_e*A_e;

for kk=2:Np
h(kk,:)=h(kk-1,:)*A_e;
F(kk,:)= F(kk-1,:)*A_e;
end

v=h*B_e;
vd=h*B_d;

nr_inp=size(Bp,2);

Phi=zeros(Np,Nc*nr_inp); %declare the dimension of Phi
Phi(:,1:nr_inp)=v; % first column of Phi

Phi_d=zeros(Np,Nc);
Phi_d(:,1)=vd;

k=2;
for i=nr_inp+1:nr_inp:Nc*nr_inp
Phi(:,i:i+nr_inp-1)=[zeros(k-1,nr_inp);v(1:Np-k+1,1:nr_inp)]; %Toeplitz matrix
Phi_d(:,k)=[zeros(k-1,1);vd(1:Np-k+1,1)];
k=k+1;
end

BarRs=ones(Np,1);
Phi_Phi= Phi'*Phi;
Phi_Phi_d=Phi'*Phi_d;
Phi_F= Phi'*F;
Phi_R=Phi'*BarRs;


end