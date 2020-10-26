clear all
close all

t = tcpip('192.168.142.129', 1100, 'NetworkRole', 'client');
fopen(t)

fwrite(t, '2')




