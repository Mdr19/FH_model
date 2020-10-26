function [ result ] = PNV_ctrl_function_Z3_cln_vlv(u,t)

%disp(['Czas ' num2str(t)]);
%load('PNV_FH_signals','input_signal_2');

global input_signal

if t==0
    t=1;
elseif t>length(input_signal.Z3_input_2)
    t=length(input_signal.Z3_input_2);
end

%t

%u

%result=input_signal(ceil(t))*ones(size(u));
result=input_signal.Z3_input_2(ceil(t(1)))*ones(size(u));

end

