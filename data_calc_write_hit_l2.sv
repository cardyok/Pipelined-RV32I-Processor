module data_calc_write_hit_l2
(
	input logic hit1, hit2, 
	input [255:0] data1, data2, 
	input [4:0] offset,
	input [255:0] mem_wdata,
	//input [3:0] mem_byte_enable,
	output logic [255:0] cache_wdata
);
//logic [31:0] start_bit; //start_bit is the position to get the 32-bit data
always_comb begin
	//start_bit = offset*8;  //check whether multiply can be used
	// if way 1 hits
	if (hit1==1) begin
		cache_wdata=mem_wdata;
		/*if (mem_byte_enable[3]==1)
			cache_wdata[(start_bit+31)-:8]=mem_wdata[31:24];
		if (mem_byte_enable[2]==1)
			cache_wdata[(start_bit+23)-:8]=mem_wdata[23:16];
		if (mem_byte_enable[1]==1)
			cache_wdata[(start_bit+15)-:8]=mem_wdata[15:8];
		if (mem_byte_enable[0]==1)
			cache_wdata[(start_bit+7)-:8]=mem_wdata[7:0];*/
	end
	// else if way 2 hits
	else if (hit2==1) begin
		cache_wdata=mem_wdata;
		/*if (mem_byte_enable[3]==1)
			cache_wdata[(start_bit+31)-:8]=mem_wdata[31:24];
		if (mem_byte_enable[2]==1)
			cache_wdata[(start_bit+23)-:8]=mem_wdata[23:16];
		if (mem_byte_enable[1]==1)
			cache_wdata[(start_bit+15)-:8]=mem_wdata[15:8];
		if (mem_byte_enable[0]==1)
			cache_wdata[(start_bit+7)-:8]=mem_wdata[7:0];*/
	end
	//if not hit in both way !!!!need double check!!!!!!!!!!
	else 
		cache_wdata=256'd0; 
end
endmodule: data_calc_write_hit_l2