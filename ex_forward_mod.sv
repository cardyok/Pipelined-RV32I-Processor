module ex_forward_mod #(parameter width = 32)
(
	input logic[2:0]sel,
	input [width-1:0] a, b, c, d,
	output logic [width-1:0] f
);

always_comb
begin
	if (sel == 3'b00)
		f = a;
	else if (sel == 3'b01)
		f = b;
	else if (sel == 3'b10)
		f = c;
	else 
		f = d;
end
endmodule : ex_forward_mod