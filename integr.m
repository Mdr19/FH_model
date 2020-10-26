%
% INTEGR.M
%
% function intg=integr(x,delta)
%

function intg=integr(x,delta)

[row,col]=size(x);
col_=2*floor((col-1)/2)+1;
coeff=[2 4];
si_coeff=2;
while(si_coeff<col_);
  coeff=[coeff coeff];
  [aux,si_coeff]=size(coeff);
end;
coeff=coeff(1:col_);
coeff(1)=1;
coeff(col_)=1;

intg=0;
intg=intg+x(1:col_)*coeff';
intg=intg/3;
if col>col_
  intg=intg+x(col);
end;

intg=delta*intg;
