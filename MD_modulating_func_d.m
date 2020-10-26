function [ y ] = MD_modulating_func_d(k, t, h, N, M )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

 %N=4;
 %M=5;
 % bylo N=6, M=7

 %N=MD_constant_values.N;
 %M=MD_constant_values.M;
 
 g=[];

y=0;
for i=0:k
  aux=((-1)^i)*factorial(k)/(factorial(i)*factorial(k-i));
  aux=aux*(factorial(N)/factorial(N-k+i))*(factorial(M)/factorial(M-i));
  y=y+aux.*(t.^(N-k+i)).*((h-t).^(M-i));
end;
    
    %y=sum(g(1:rank-1));
    %y=1;
    
    %y=t.^N.*(h-t).^M;
    %y=ones(h, 1);
    %y1=zeros(10, 1);
    %y=[y1; y(10:h)];
    %y=zeros(h,1);
    %y(1)=100000;
end