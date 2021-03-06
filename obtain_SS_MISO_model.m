function [A,B,C,D ] = obtain_SS_MISO_model(ni_min,inputs_nr,model_params)

n=model_params.n;
m=model_params.m;


%disp('Budowa A');
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
B=zeros(m-1,inputs_nr);
%{
for i=1:ident_inputs_nr
    B(:,i)=zeros(m-1,1);
    B(1,i)=ni_min(m+i)/ni_min(m);
end
%}
k=1;
for i=1:inputs_nr
    for j=1:n
        B(j,i)=-ni_min(m+k)/ni_min(m);
        k=k+1;
    end
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
D=zeros(m-1,inputs_nr);

end

