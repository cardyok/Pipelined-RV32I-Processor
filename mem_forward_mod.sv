module mem_forward_mod #(parameter width = 32)
(
	input logic[2:0]sel,
	input [width-1:0] mem,old,
	output logic [width-1:0] out
);

always_comb
begin
	if (sel == 3)
		out = mem;
	else 
		out = old;
end
endmodule : mem_forward_mod