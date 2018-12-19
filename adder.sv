module adder
(
	input logic [31:0] a, b,
	output logic [31:0] f
);

always_comb 
begin
	f = a + b;
end
endmodule
