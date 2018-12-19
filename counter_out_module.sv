module counter_out_module
(
	input [31:0] origin,
   input [31:0] address,
	input [31:0] branch,
	input [31:0] mispredict,
	input [31:0] I_cache_hit,
	input [31:0] I_cache_miss,
	input [31:0] D_cache_hit,
	input [31:0] D_cache_miss,
	input [31:0] l2_cache_hit,
	input [31:0] l2_cache_miss,
	input [31:0] stall_counter,
	output logic [31:0] out
);
always_comb
begin
	if(address == 32'h0000)
		out = branch;
	else if(address == 32'h0004)
		out = mispredict;
	else if(address == 32'h0008)
		out = I_cache_hit;
	else if(address == 32'h000c)
		out = I_cache_miss;
	else if(address == 32'h0010)
		out = D_cache_hit;
	else if(address == 32'h0014)
		out = D_cache_miss;
	else if(address == 32'h0018)
		out = l2_cache_hit;
	else if(address == 32'h001c)
		out = l2_cache_miss;
	else if(address == 32'h0020)
		out = stall_counter;
	else
		out = origin;
end

endmodule : counter_out_module