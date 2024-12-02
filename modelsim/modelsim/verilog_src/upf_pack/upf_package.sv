package UPF;
	typedef struct packed {
		int voltage;// voltage in μV
		bit [31:0] state;// net state
	} supply_net_type;

	typedef enum {OFF, ON, PARTIAL_ON} net_state;
	function bit supply_on( string pad_name, real value );
	 	supply_net_type final_value;
        int result;
        integer volt;
		value = value * 1000000; //converting volt to uV.
		final_value.voltage = $rtoi(value);
        final_value.state = 1;
		$upf_set_signal_value( pad_name, final_value, result );
	 	return result;
	endfunction
	function bit supply_off( string pad_name );
	 	supply_net_type final_value;
        int result;
		final_value.voltage = 0;
        final_value.state = 0;
		$upf_set_signal_value( pad_name, final_value, result );
	 	return result;
	endfunction
	function bit supply_partial_on( string pad_name, real value );
	 	supply_net_type final_value;
        int result;
        integer volt;
		value = value * 1000000; //converting volt to uV.
		final_value.voltage = $rtoi(value);
        final_value.state = 3;
		$upf_set_signal_value( pad_name, final_value, result );
	 	return result;
	endfunction
	function supply_net_type get_supply_value( string name );
        supply_net_type temp;
        int result;
        $upf_get_signal_value(name, temp, result);
        return temp;
	endfunction
	function real get_supply_voltage( supply_net_type arg );
		real voltage;
		voltage = $itor(arg.voltage);
		voltage = voltage / 1000000;
		return voltage;
	endfunction
	function bit get_supply_on_state( supply_net_type arg );
		return arg.state[0];
	endfunction
	function bit [1:0] get_supply_state( supply_net_type arg );
		return arg.state[1:0];
	endfunction
endpackage : UPF
