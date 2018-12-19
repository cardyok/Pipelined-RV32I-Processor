module forward
(
	input MEM_write,
	input WB_write,
	input EX_write,
	input [4:0] reg_MEM,
	input [4:0] reg_WB,
	input [4:0] reg_EX,
	input [4:0] curr_a,
	input [4:0] curr_b,
	output logic [1:0] sel_a,
	output logic [1:0] sel_b
);

always_comb
begin
	if((curr_a == reg_EX)&&(EX_write == 1)&&(curr_a!=0))
		sel_a = 1;
	else if((curr_a == reg_MEM)&&(MEM_write == 1)&&(curr_a!=0))
		sel_a = 2;
	else if((curr_a == reg_WB)&&(WB_write == 1)&&(curr_a!=0))
		sel_a = 3;
	else
		sel_a = 0;

	if((curr_b == reg_EX)&&(EX_write == 1)&&(curr_b!=0))
		sel_b = 1;
	else if((curr_b == reg_MEM)&&(MEM_write == 1)&&(curr_b!=0))
		sel_b = 2;
	else if((curr_b == reg_WB)&&(WB_write == 1)&&(curr_b!=0))
		sel_b = 3;
	else
		sel_b = 0;
end
endmodule : forward