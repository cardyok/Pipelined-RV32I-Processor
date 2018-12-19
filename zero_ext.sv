module zero_ext
(
	input logic a,
	output [31:0] a_zext 
);
assign a_zext={31'd0, a};
endmodule : zero_ext
