function FH_PID_tune_Strejc( ident_section )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global Kp;
global Ki;
%global E_int;

global sim_mode_append;


if ~isempty(ident_section.current_model_Strejc)
    
    K=ident_section.current_model_Strejc.k;
    T=ident_section.current_model_Strejc.T;
    n=ident_section.current_model_Strejc.n;
    
    Kp=(1/(4*K))*((n+2)/(n-1))
    Ti=(T/3)*(n+2);
    Ki=Kp/Ti
    
    if MD_constant_values.sim_mode==2
       sim_mode_append=0;
    end
    
    %{
    if ident_section.ident_models(ident_section.current_model_nr).intervals(end-1).interval_type=='I' ||...
        ident_section.ident_models(ident_section.current_model_nr).intervals(end-1).interval_type=='R'
        E_int=0;
    end
    %}
end

end

