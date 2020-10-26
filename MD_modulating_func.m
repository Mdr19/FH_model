function [ y ] = MD_modulating_func( t, h, N, M)

y=t.^N.*(h-t).^M;

end

