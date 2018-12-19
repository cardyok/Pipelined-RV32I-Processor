module addfour #(parameter width = 32)
(
	input [width-1:0] pc_out,
	output logic [width-1:0] pc_plus_4
);

assign pc_plus_4 = pc_out+32'h00000004;

endmodule : addfour