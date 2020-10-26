function [ ni_min, y_dot, u_dot] = MD_MFM_model_ident_out_LSM(inputs_nr,u,Pv,method_params,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

step_=method_params.MFM_step;


h=params.h;
n=params.n;
m=params.m;
N=params.N;
M=params.M;

%funkcja modulujaca identyfikacja
mod_func=MD_modulating_func(0:step_:h,h,N,M);
mod_func=mod_func(2:end);
max_mod=max(mod_func);
mod_func=mod_func/max_mod;


k=max(n,m);

u_dot=[];
y_dot=[];

for i=1:k-1
    mod_func_d(i,:)=(1/max_mod)*MD_modulating_func_d(i,0:step_:h,h,N,M);
end

mod_func_d=mod_func_d(:,2:end);

for i=1:inputs_nr
    input(i).u_dot=[];
end

for cnt=1:length(u)
    
    if (cnt>h/step_)
        %(cnt1<=change_end(current_interval))  (cnt1<zero_lin(current_interval+2)
        
        %disp('Ident');
        
        current_out=Pv(cnt-h/step_:cnt);
        
        for i=1:inputs_nr
            current_u(i,:)=u(i,cnt-h/step_:cnt);
        end;
        
        
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
        
        %Sterowanie i opoznienia
        
        for i=1:inputs_nr
            for j=1:n
                if j==1
                    con=conv(current_u(i,:),mod_func);
                    con=con(1:floor(length(con)/2));
                    st(j)=con(end);
                else
                    con=conv(current_u(i,:),mod_func_d(j-1,:));
                    con=con(1:floor(length(con)/2));
                    st(j)=con(end);
                end
            end
            
            input(i).u_dot=[input(i).u_dot st'];
            
        end
    end;
end;

for i=2:m
    X(i-1,:)=y_dot(i,:);
end

k=1;
for i=1:inputs_nr
    for j=1:n
        X(k+m-1,:)=input(i).u_dot(j,:);
        
        k=k+1;
    end
end

X=X';
Y=y_dot(1,:)';

ni_min=inv(X'*X)*X'*Y;

end

