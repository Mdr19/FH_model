function [ A,B,C,D,ni_min ] = MD_MFM_SISO_ident( u,Pv,method,eta)


h=MD_constant_values.h;
step_=MD_constant_values.step_;
n=MD_constant_values.n;
m=MD_constant_values.m;
G_length=MD_constant_values.G_length;

%funkcja modulujaca identyfikacja
mod_func=MD_modulating_func(0:step_:h,h);
mod_func=mod_func(2:end);
max_mod=max(mod_func);
mod_func=mod_func/max_mod;


k=max(n,m);

u_dot=[];
y_dot=[];

for i=1:k-1
    mod_func_d(i,:)=(1/max_mod)*MD_modulating_func_d(i,0:step_:h,h);
end

mod_func_d=mod_func_d(:,2:end);


%IDENTYFIKACJA I SYMULACJA
for cnt=1:length(Pv)
    
if (cnt>h/step_) 
    %(cnt1<=change_end(current_interval))  (cnt1<zero_lin(current_interval+2)
    
    %disp('Ident');

    current_out=Pv(cnt-h/step_:cnt);
    current_u=u(cnt-h/step_:cnt);
    
    %IDENTYFIKACJA DLA DLUGIEGO OKNA
    %Wyjscie i jego pochodne
    for i=1:m
        if i==1 
            con=conv(current_out,mod_func);
            con=con(1:floor(length(con)/2));
            s(i)=con(end);
        else
            con=conv(current_out,mod_func_d(i-1,:));
            con=con(1:floor(length(con)/2));
            s(i)=con(end);
        end
    end
    
    y_dot=[y_dot s'];
    
    %Sterowanie i jego pochodne
    for i=1:n
        if i==1 
            con=conv(current_u,mod_func);
            con=con(1:floor(length(con)/2));
            st(i)=con(end);
        else
            con=conv(current_u,mod_func_d(i-1,:));
            con=con(1:floor(length(con)/2));
            st(i)=con(end);
        end
    end
    
    u_dot=[u_dot st'];
    
    for j=1:m
        for k=1:m
            %disp(['Wspolzedne ' num2str(j) ' ' num2str(k)]);
            if length(y_dot)<=G_length
                G1(j,k)=integr(y_dot(j,:)*y_dot(k,:)',1);
            else
                G1(j,k)=integr(y_dot(j,end-G_length:end)*y_dot(k,end-G_length:end)',1);
            end
        end
    end
    
    for j=1:m
        for k=1:n   
            if length(y_dot)<=G_length
                G2(j,k)=integr(-y_dot(j,:)*u_dot(k,:)',1);
            else
                G2(j,k)=integr(-y_dot(j,end-G_length:end)*u_dot(k,end-G_length:end)',1);
            end
        end
    end
    
    for j=1:n
        for k=1:m            
            if length(y_dot)<=G_length
                G4(j,k)=integr(-u_dot(j,:)*y_dot(k,:)',1);
            else
                G4(j,k)=integr(-u_dot(j,end-G_length:end)*y_dot(k,end-G_length:end)',1);
            end
        end
    end
    
    for j=1:n
        for k=1:n    
            if length(y_dot)<=G_length
                G5(j,k)=integr(u_dot(j,:)*u_dot(k,:)',1);
            else
                G5(j,k)=integr(u_dot(j,end-G_length:end)*u_dot(k,end-G_length:end)',1);
            end
        end
    end

  
    %Gi=[G1 G2 G3; G4 G5 G6; G7 G8 G9];
    
  
end;
end

Gi=[G1 G2; G4 G5];

%pierwszy sposob liczenia
if method==1   
    [x,l]=eig(Gi);
    for j=1:size(Gi,1)
        if j==1 
            min_eig=l(j,j);
            ni_min=x(:,j);
        elseif l(j,j)<min_eig
            min_eig=l(j,j);
            ni_min=x(:,j);
        end
    end    
else 
    %drugi ni_min_u sposob liczenia
    ni_min=(inv(Gi)*eta)/(eta'*inv(Gi)*eta);
end
    
%------------------------------------------------------------------------%

for i=1:m-1
  for j=1:m-1
      if i==m-1
        A(j,i)=-ni_min(j)/ni_min(m);
      elseif j==i+1
        A(j,i)=1;
      else
        A(j,i)=0; 
      end
  end
end
    
%disp('Budowa B');
B=zeros(m-1,1);
             
for i=1:n
  %B(:,i)=zeros(m-1,1);
  B(i,1)=ni_min(m+i)/ni_min(m);
end
    
%disp('Budowa C');
for i=1:m-1
  for j=1:m-1
    if i==j
      C(i,j)=1;
    else
      C(i,j)=0;
    end
  end
end
            
%disp('Budowa D');
%D=[0];
D=zeros(m-1,1);