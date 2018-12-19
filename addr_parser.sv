module addr_parser #(parameter width = 3)
(
	input [31:0] mem_addr,
	output logic [26-width:0] tag,
	output logic [width-1:0] index,
	output logic [4:0] offset
);
assign tag = mem_addr[31:5+width];
assign index = mem_addr[4+width:5];
assign offset = mem_addr[4:0];

endmodule: addr_parser