module PHT_write_control
(
	input logic branch_result,
	input logic [1:0] prev_data,
	output logic [1:0] PHT_datain
);

always_comb begin
	case (prev_data)
		2'b00: 
			if (branch_result==0)
				PHT_datain=2'b00;
			else
				PHT_datain=2'b01;
		2'b01:
			if (branch_result==0)
				PHT_datain=2'b00;
			else
				PHT_datain=2'b10;
		2'b10:
			if (branch_result==0)
				PHT_datain=2'b01;
			else
				PHT_datain=2'b11;
		2'b11:
			if (branch_result==0)
				PHT_datain=2'b10;
			else
				PHT_datain=2'b11;
	endcase
end
endmodule
