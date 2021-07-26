clear all
close all

t = tcpip('192.168.0.100', 1100, 'NetworkRole', 'server');
fopen(t)

data=fread(t,10,'char');
data
%disp(['I received ' data]);

fwrite(t, '1234567890');



%fwrite(t, '2')
fclose(t);
delete(t);
clear t