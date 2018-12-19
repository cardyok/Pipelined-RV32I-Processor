module data_calc_read_hit_l2
(
	input logic hit1, hit2,
	input [255:0] data1, data2, 
	input [4:0] offset,
	output logic [255:0] mem_rdata
);
//logic [31:0] start_bit; //start_bit is the position to get the 32-bit data

always_comb begin
	//start_bit = offset*8;  //check whether multiply can be used
	// if way 1 hits
	if (hit1==1) begin
		/*if (start_bit<=224) 
			mem_rdata=data1[(start_bit+31) -: 32];
		else if (start_bit<=240)
			mem_rdata={16'd0, data1[(start_bit+15) -: 16]};
		else
			mem_rdata={24'd0, data1[(start_bit+7) -: 8]};*/
		mem_rdata=data1;
	end
	// else if way 2 hits
	else if (hit2==1) begin
		/*if (start_bit<=224) 
			mem_rdata=data2[(start_bit+31) -: 32];
		else if (start_bit<=240)
			mem_rdata={16'd0, data2[(start_bit+15) -: 16]};
		else
			mem_rdata={24'd0, data2[(start_bit+7) -: 8]};*/
		mem_rdata=data2;
	end
	//if not hit in both way !!!!need double check!!!!!!!!!!
	else 
		mem_rdata = 256'd0;
end
endmodule: data_calc_read_hit_l2
