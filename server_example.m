clear all
close all

t = tcpip('192.168.142.129', 1100, 'NetworkRole', 'server');
fopen(t)

data=fread(t,10,'string');
data
%disp(['I received ' data]);

fwrite(t, '2');



%fwrite(t, '2')
fclose(t);
delete(t);
clear t