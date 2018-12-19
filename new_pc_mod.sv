module new_pc_mod
(
    input [1:0] sel,
    input br,
	 input pc,
	 input cmp,
	 input BTB_found,
	 input predict_result,
	 output logic flush,
	 output logic[1:0] out
);
always_comb
begin
	flush = 0;
	out = 0;
	
	if (predict_result && BTB_found)
	begin
		out = 3;
	end
	
	if((!br)&&(((sel==1) && cmp)||(sel==2)))
	begin
		flush = 1;
		out = 2;
	end
	else if((sel==1) && (!pc) && (!cmp))
	begin
		flush = 1;
		out = 1;
	end
end

endmodule : new_pc_mod