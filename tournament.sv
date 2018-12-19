module tournament_write_control
(
	input a,
	input b,
	input [1:0] prev_data,
	output logic [1:0] PHT_datain
);

always_comb
begin
	if(a==b)
	PHT_datain = prev_data;
	else
	begin
		case (prev_data)
			2'b00: 
				if (a==1)
					PHT_datain=2'b00;
				else
					PHT_datain=2'b01;
			2'b01:
				if (a==1)
					PHT_datain=2'b00;
				else
					PHT_datain=2'b10;
			2'b10:
				if (a==1)
					PHT_datain=2'b01;
				else
					PHT_datain=2'b11;
			2'b11:
				if (a==1)
					PHT_datain=2'b10;
				else
					PHT_datain=2'b11;
		endcase
	end
end

endmodule 