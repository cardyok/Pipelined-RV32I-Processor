module counter_state
(
	input clk,
	input sel,
   input load,
	input cache_resp,
	output logic [31:0] out
);
logic enable;
counter actual_counter
(
	.clk,
   .load(load&&enable),
	.sel,
	.out
);

enum int unsigned {
		run,
		stay
}state, next_state;

always_comb
begin : state_action
	enable = 1;
	if(state == stay)
		enable = 0;
end


always_comb
begin : next_state_logic
	next_state = state;
	case(state)
		run: if(load && (!sel)) next_state = stay;
		stay: if(cache_resp) next_state = run; 
	endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
   /* Assignment of next state on clock edge */
	state <= next_state;
end
endmodule : counter_state


