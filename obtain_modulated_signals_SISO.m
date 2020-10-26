function [ u_dot, y_dot ] = obtain_modulated_signals_SISO( input, output,method_params,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

m=params.m;
n=params.n;
h=params.h;
N=params.N;
M=params.M;

step_=method_params.MFM_step;

mod_func=MD_modulating_func(0:step_:h,h,N,M);
mod_func=mod_func(2:end);
max_mod=max(mod_func);
mod_func=mod_func/max_mod;

u_dot=[];
y_dot=[];

for i=1:m-1
    mod_func_d(i,:)=(1/max_mod)*MD_modulating_func_d(i,0:step_:h,h,N,M);
end

mod_func_d=mod_func_d(:,2:end);

for cnt=1:length(output)
    
    if (cnt>h/step_)
        %(cnt1<=change_end(current_interval))  (cnt1<zero_lin(current_interval+2)
        
        %disp('Ident');
        
        current_out=output(cnt-h/step_:cnt);
        
        current_u(1,:)=input(1,cnt-h/step_:cnt);
        
        
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
        %con=conv(current_u(1,:),mod_func);
        %con=con(1:floor(length(con)/2));
        %st=con(end);
        
        for j=1:n
            if j==1
                con=conv(current_u,mod_func);
                con=con(1:floor(length(con)/2));
                st(j)=con(end);
            else
                con=conv(current_u,mod_func_d(j-1,:));
                con=con(1:floor(length(con)/2));
                st(j)=con(end);
            end
        end
        
        u_dot=[u_dot st'];
        
    end;
    
end;


end

