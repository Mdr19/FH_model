function FH_set_MPC_model( ident_section,section_name,prev_section_model)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%global DC_model
%global DC_delay
%global DC_initial_state
%global DC_offset
%global control_offset

global MPC_model
global PZ_model
%global MPC_model_Z4_new_model_set
%global X_hat;
%global X_hat_;
%global u_mpc;

if ~isempty(ident_section.MPC_model)  
    
    disp('Obtaining the current MPC model');
    
    %MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;  
    MPC_model.(strcat(section_name,'_new'))=ident_section.MPC_model;    
    MPC_model.(strcat(section_name,'_new_model_set'))=true;
    
    if prev_section_model
       PZ_model.(strcat(section_name,'_new'))=ident_section.PZ_model;    
    end
    
    
    %u_mpc.(section_name)=0;
    
    %control_offset=ident_section.ident_models(ident_section.current_model_nr).offset_value(MD_constant_values.Strejc_signal_nr);

    %n=size(ident_section.MPC_model.A,1);
    %X_hat=zeros(n,1);
    
    %{
    X_hat_=ident_section.current_model(2).A*ident_section.current_initial_state(2,:)'+...
        ident_section.current_model(2).B*ident_section.signals_intervals(end).original_signals(2,end);
    X_hat_=[X_hat_; ident_section.signals_intervals(end).original_signals(3,end)-MPC_model.output_offset];
    
    X_hat=ident_section.current_model(2).A*ident_section.current_initial_state(2,:)'+...
        ident_section.current_model(2).B*ident_section.signals_intervals(end).original_signals(2,end);
    X_hat=[X_hat; ident_section.signals_intervals(end).original_signals(3,end)-MPC_model.output_offset];
    %}
    
    %u_mpc=0;
    
end

end

