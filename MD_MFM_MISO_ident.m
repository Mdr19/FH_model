function [ ni_min ] = MD_MFM_MISO_ident(inputs_nr,u,Pv,method,eta,method_params,model_params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


h=model_params.h;
step_=method_params.step_;
n=model_params.n;
m=model_params.m;
N=model_params.N;
M=model_params.M;

G_length=method_params.G_length;

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
        
        %{
        for i=1:inputs_nr
            con=conv(current_u(i,:),mod_func);
            con=con(1:floor(length(con)/2));
            st(i)=con(end);
        end
        
        u_dot=[u_dot st'];
        %}
        
        %{
        for j=1:m
            for k=1:inputs_nr
                if length(y_dot)<=G_length
                    G2(j,k)=integr(-y_dot(j,:)*u_dot(k,:)',1);
                else
                    G2(j,k)=integr(-y_dot(j,end-G_length:end)*u_dot(k,end-G_length:end)',1);
                end
            end
        end
        %}
        
        G2=[];
        
        
        for k=1:inputs_nr
            for i=1:m
                for j=1:n
                    if length(y_dot)<=G_length
                        G2_(i,j)=integr(-y_dot(i,:)*input(k).u_dot(j,:)',1);
                    else
                        G2_(i,j)=integr(-y_dot(i,end-G_length:end)*input(k).u_dot(j,end-G_length:end)',1);
                    end
                end
            end
            G2=[G2 G2_];
        end
        
        
        %{
        for j=1:inputs_nr
            for k=1:m
                if length(y_dot)<=G_length
                    G3(j,k)=integr(-u_dot(j,:)*y_dot(k,:)',1);
                else
                    G3(j,k)=integr(-u_dot(j,end-G_length:end)*y_dot(k,end-G_length:end)',1);
                end
            end
        end
        %}
        
        G3=[];
        
        
        for k=1:inputs_nr
            for i=1:n
                for j=1:m
                    if length(y_dot)<=G_length
                        G3_(i,j)=integr(-input(k).u_dot(i,:)*y_dot(j,:)',1);
                    else
                        G3_(i,j)=integr(-input(k).u_dot(i,end-G_length:end)*y_dot(j,end-G_length:end)',1);
                    end
                end
            end
            G3=[G3; G3_];
        end
        
        %{
        for j=1:inputs_nr
            for k=1:inputs_nr
                if length(y_dot)<=G_length
                    G4(j,k)=integr(u_dot(j,:)*u_dot(k,:)',1);
                else
                    G4(j,k)=integr(u_dot(j,end-G_length:end)*u_dot(k,end-G_length:end)',1);
                end
            end
        end
        %}
        
        G4=[];
        %disp('---------------------------------------------');
        for k=1:inputs_nr
            G4_=[];
            
            for l=1:inputs_nr
                for i=1:n
                    for j=1:n
                        %disp(['Inputs ' num2str(k) ' ' num2str(l) ' params ' num2str(i) ' ' num2str(j)]);
                        if length(y_dot)<=G_length
                            G4__(i,j)=integr(input(k).u_dot(i,:)*input(l).u_dot(j,:)',1);
                        else
                            G4__(i,j)=integr(input(k).u_dot(i,end-G_length:end)*input(l).u_dot(j,end-G_length:end)',1);
                        end
                    end
                end
                %G4__
                G4_=[G4_ G4__];
                %G4_
            end
            G4=[G4; G4_];
        end
        
        
        Gi=[G1 G2; G3 G4];
        
    end;
    
end;

if method ==1
    
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
    %drugi sposób liczenia
    ni_min=(inv(Gi)*eta)/(eta'*inv(Gi)*eta);
end


end

