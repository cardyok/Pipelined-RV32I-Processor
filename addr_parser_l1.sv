module addr_parser_l1
(
	input [31:0] mem_addr,
	output logic [24:0] tag,
	output logic [1:0] index,
	output logic [4:0] offset
);
assign tag = mem_addr[31:7];
assign index = mem_addr[6:5];
assign offset = mem_addr[4:0];

endmodule: addr_parser_l1