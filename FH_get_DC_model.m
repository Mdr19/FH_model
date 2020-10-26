function FH_get_DC_model( ident_section )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global DC_model
global DC_delay
global DC_initial_state
global DC_offset
global control_offset

if ~isempty(ident_section.current_model)
    
    disp('Obtaining the current model');
    
    DC_delay=ident_section.current_delay;
    %DC_initial_state=ident_section.current_initial_state(1,:);
    DC_offset=ident_section.ident_models(ident_section.current_model_nr).offset_value(1);
    
    if size(ident_section.current_model,2)==1
        DC_model.A=ident_section.current_model_FF.A;
        DC_model.B=ident_section.current_model_FF.B(:,1);
        DC_model.C=ident_section.current_model_FF.C;
        DC_model.D=ident_section.current_model_FF.D;
        DC_initial_state=0;
        control_offset=ident_section.ident_models(ident_section.current_model_nr).offset_value(MD_constant_values.Strejc_signal_nr);
    else
        DC_model.A=ident_section.current_model_FF.A;
        DC_model.B=ident_section.current_model_FF.B;
        DC_model.C=ident_section.current_model_FF.C;
        DC_model.D=ident_section.current_model_FF.D;
        
        if isempty(DC_initial_state)
            DC_initial_state=ident_section.current_model_FF_state;
        end
        
        control_offset=ident_section.ident_models(ident_section.current_model_nr).offset_value(MD_constant_values.Strejc_signal_nr);
        
        %DC_model.D=ident_section.current_model(1).D;
    end
    
end

end

