function FH_update_state_MPC_model( ident_section,section_name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%global DC_model
%global DC_delay
%global DC_initial_state
%global DC_offset
%global control_offset

global MPC_model
%global X_hat;
%global X_hat_;
%global u_mpc;

if ~isempty(ident_section.MPC_model)
    
    disp('Updating state MPC model');
    
    if size(ident_section.current_model)==1
        
        %{
        X0=ident_section.current_model.A*ident_section.current_initial_state'+...
            ident_section.current_model.B(:,2)*(ident_section.signals_intervals(end).original_signals(2,end)-...
                    ident_section.ident_models(ident_section.current_model_nr).offset_value(2));
       %}         
                
        X0=ident_section.current_model.A*ident_section.current_initial_state'+...
                    ident_section.current_model.B(:,2:end)*(ident_section.signals_intervals(end).original_signals(2:2+size(ident_section.current_model.B,2)-2,end)-...
                    ident_section.ident_models(ident_section.current_model_nr).offset_value(2:2+size(ident_section.current_model.B,2)-2)');                 
                
        X0=[X0; ident_section.signals_intervals(end).original_signals(3,end)-...
            ident_section.ident_models(ident_section.current_model_nr).offset_value(end)];
        

        %n=rank(ident_section.current_model.A);
        %X0=[zeros(n,1); ident_section.signals_intervals(end).original_signals(3,end)-...
        %ident_section.ident_models(ident_section.current_model_nr).offset_value(end)];
    else
        
        %{
        X0=ident_section.current_model(2).A*ident_section.current_initial_state(2,:)'+...
            ident_section.current_model(2).B*(ident_section.signals_intervals(end).original_signals(2,end)-...
                    ident_section.ident_models(ident_section.current_model_nr).offset_value(2));
        %}
        
          X0=ident_section.current_model(2).A*ident_section.current_initial_state(2,:)'+...
                    ident_section.current_model(2).B*(ident_section.signals_intervals(end).original_signals(2:2+size(ident_section.current_model(2).B,2)-1,end)-...
                    ident_section.ident_models(ident_section.current_model_nr).offset_value(2:2+size(ident_section.current_model(2).B,2)-1)');
        
        X0=[X0; ident_section.signals_intervals(end).original_signals(3,end)-...
            ident_section.ident_models(ident_section.current_model_nr).offset_value(end)];
        
        %n=rank(obj.current_model(2).A);
        %X0=[zeros(n,1); obj.signals_intervals(end).original_signals(3,end)-...
        %obj.ident_models(obj.current_model_nr).offset_value(end)];
        
    end
    
    %X0
    MPC_model.(section_name).X0=X0;
    
    %MPC_model.(section_name).X0=X0;
    
    %MPC_model.(section_name)=ident_section.MPC_model;
    
    %u_mpc.(section_name)=X0;
    
end

end

