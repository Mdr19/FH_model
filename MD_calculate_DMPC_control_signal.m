function [ u, X0] = MD_calculate_DMPC_control_signal(A,B,Bd,C,K_ob,Phi_Phi,Phi_R,Phi_F,Phi_Phi_d,Nc,u0,u_max,u_min,d_max,d_min,X0,u_offset,Y,SP,prev_zone_signal,prev_sec_corr)

%X0=zeros(size(A,1),1);

disp([num2str(X0(end)) ' ' num2str(Y)]);


%X0(end)=Y;

n=size(B,2);
%Xsp=[zeros(n-1,1);SP];
Xf=X0;
%-Xsp;
%Xf=Xsp-X0;

%d_max=0.15*10;
%d_min=-d_max;

u_min=u_min-u_offset;
u_max=u_max-u_offset;

if n==1
    
    M1=[-tril(ones(Nc));tril(ones(Nc))];
    gamma1=[(-u_min+u0)*ones(Nc,1); (u_max-u0)*ones(Nc,1);];
    
    M2=[-eye(Nc); eye(Nc)];
    gamma2=[-d_min*ones(Nc,1); d_max*ones(Nc,1)];
else
    
    %{
   gamma1=[zeros(Nc*n,1); zeros(Nc*n,1)];
    
   for i=0:Nc-1
       gamma1(i*n+1:i*n+n,:)=-u_min'+u0;
   end
   
   for i=Nc:2*Nc-1
       gamma1(i*n+1:i*n+n,1)=u_max'-u0;
   end
    %}
    
    M1=[zeros(Nc*n); zeros(Nc*n)];
    
    for i=1:Nc*n
        for j=1:Nc*n
            if j<=i
                if mod(i,2)==1 && mod(j,2)==1
                    M1(i,j)=-1;
                elseif mod(i,2)==0 && mod(j,2)==0
                    M1(i,j)=-1;
                end
            end
        end
    end
    
    for i=1:Nc*n
        for j=1:Nc*n
            if j<=i
                if mod(i,2)==1 && mod(j,2)==1
                    M1(i+Nc*n,j)=1;
                elseif mod(i,2)==0 && mod(j,2)==0
                    M1(i+Nc*n,j)=1;
                end
            end
        end
    end
    
    gamma1=[];
    
    for i=0:Nc-1
        gamma1(i*n+1:i*n+n,:)=-u_min'+u0;
    end
    
    for i=Nc:2*Nc-1
        gamma1(i*n+1:i*n+n,1)=u_max'-u0;
    end
    
    
    M2=[zeros(Nc*n); zeros(Nc*n)];
    
    for i=0:Nc-1
        M2(i*n+1:i*n+n,i*n+1:i*n+n)=-eye(n);
        
        M2((i+Nc)*n+1:(i+Nc)*n+n,i*n+1:i*n+n)=eye(n);
    end
    
    for i=0:Nc-1
        gamma2(i*n+1:i*n+n,:)=-d_min';
    end
    
    for i=Nc:2*Nc-1
        gamma2(i*n+1:i*n+n,1)=d_max';
    end
    
    
    %M2=[-eye(Nc*n); eye(Nc*n)];
    %gamma2=[-d_min*ones(Nc*n,1); d_max*ones(Nc*n,1)];
    
end
%E=

M=[M1; M2];
gamma=[gamma1; gamma2];

penalty=10;

%DeltaU=inv(Phi_Phi+penalty*eye(Nc,Nc))*(Phi_R*SP-Phi_F*Xf);

if prev_sec_corr
    H=Phi_Phi+penalty*eye(Nc*n,Nc*n);
    f=Phi_F*Xf-Phi_R*SP+Phi_Phi_d*prev_zone_signal;
else
    H=Phi_Phi+penalty*eye(Nc*n,Nc*n);
    f=Phi_F*Xf-Phi_R*SP;
end
%DeltaU'

DeltaU_C=QPhild(H,f,M,gamma);

%DeltaU_C=DeltaU;

DeltaU_C'

deltau=DeltaU_C(1:n,1);
%deltau=DeltaU(1,1);

for i=1:length(deltau)
    if deltau(i)>d_max(i)
        deltau(i)=d_max(i);
    elseif deltau(i)<d_min(i)
        deltau(i)=d_min(i);
    end
    
    if u0(i)+deltau(i)>u_max(i)
        deltau(i)=u_max(i)-u0(i);
    elseif u0(i)+deltau(i)<u_min(i)
        deltau(i)=u_min(i)-u0(i);
    end
    
end

%{
if deltau>0.15
    deltau=0.15;
elseif deltau<-0.15
    deltau=-0.15;
end
%}

u=u0+deltau;

%X0=A*X0+B*deltau;

if prev_sec_corr
    deltad=prev_zone_signal(1);
    X0=A*X0+B*deltau+Bd*deltad+K_ob*(Y-C*X0);
else
    X0=A*X0+B*deltau+K_ob*(Y-C*X0);
end

%{
if u+u_offset>6
    u=6-u_offset;
elseif u+u_offset<0.6
    u=0.6-u_offset;
end
%}

disp(['Single iter, init. error: '  num2str(num2str(SP-Y)) ', X0: ' num2str(X0')  ', SP: ' num2str(SP) ', ctrl. ' num2str(u'+u_offset) ' u dot ' num2str(deltau')]);
%DeltaU_C'
end

