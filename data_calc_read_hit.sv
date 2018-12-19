module data_calc_read_hit
(
	input logic hit1, hit2,
	input [255:0] data1, data2, 
	input [4:0] offset,
	output logic[31:0] mem_rdata
);
logic [31:0] start_bit; //start_bit is the position to get the 32-bit data
//assign start_bit = 255-(offset*8);
//assign PADWIDTH = 31-start_bit;
always_comb begin
	start_bit = offset*8;  //check whether multiply can be used
	// if way 1 hits
	if (hit1==1) begin
		if (start_bit<=224) 
			mem_rdata=data1[(start_bit+31) -: 32];
		else if (start_bit<=240)
			mem_rdata={16'd0, data1[(start_bit+15) -: 16]};
		else
			mem_rdata={24'd0, data1[(start_bit+7) -: 8]};
//		case (offset)
//			5'd0: mem_rdata=data1[255:224];
//			5'd1: mem_rdata=data1[247:216];
//			5'd2: mem_rdata=data1[239:208];
//			5'd3: mem_rdata=data1[231:200];
//			5'd4: mem_rdata=data1[223:192];
//			5'd5: mem_rdata=data1[215:184];
//			5'd6: mem_rdata=data1[207:176];
//			5'd7: mem_rdata=data1[199:168];
//			5'd8: mem_rdata=data1[191:160];
//			5'd9: mem_rdata=data1[183:152];
//			5'd10: mem_rdata=data1[175:144];
//			5'd11: mem_rdata=data1[167:136];
//			5'd12: mem_rdata=data1[159:128];
//			5'd13: mem_rdata=data1[151:120];
//			5'd14: mem_rdata=data1[143:112];
//			5'd15: mem_rdata=data1[135:104];
//			5'd16: mem_rdata=data1[127:96];
//			5'd17: mem_rdata=data1[119:88];
//			5'd18: mem_rdata=data1[111:80];
//			5'd19: mem_rdata=data1[103:72];
//			5'd20: mem_rdata=data1[95:64];
//			5'd21: mem_rdata=data1[87:56];
//			5'd22: mem_rdata=data1[79:48];
//			5'd23: mem_rdata=data1[71:40];
//			5'd24: mem_rdata=data1[63:32];
//			5'd25: mem_rdata=data1[55:24];
//			5'd26: mem_rdata=data1[47:16];
//			5'd27: mem_rdata=data1[39:8];
//			5'd28: mem_rdata=data1[31:0];
//			5'd29: mem_rdata={8'd0, data1[23:0]};
//			5'd30: mem_rdata={16'd0, data1[15:0]};
//			5'd31: mem_rdata={24'd0, data1[7:0]};
//		endcase 
	end
	// else if way 2 hits
	else if (hit2==1) begin
		if (start_bit<=224) 
			mem_rdata=data2[(start_bit+31) -: 32];
		else if (start_bit<=240)
			mem_rdata={16'd0, data2[(start_bit+15) -: 16]};
		else
			mem_rdata={24'd0, data2[(start_bit+7) -: 8]};
//		case (offset)
//			5'd0: mem_rdata=data2[255:224];
//			5'd1: mem_rdata=data2[247:216];
//			5'd2: mem_rdata=data2[239:208];
//			5'd3: mem_rdata=data2[231:200];
//			5'd4: mem_rdata=data2[223:192];
//			5'd5: mem_rdata=data2[215:184];
//			5'd6: mem_rdata=data2[207:176];
//			5'd7: mem_rdata=data2[199:168];
//			5'd8: mem_rdata=data2[191:160];
//			5'd9: mem_rdata=data2[183:152];
//			5'd10: mem_rdata=data2[175:144];
//			5'd11: mem_rdata=data2[167:136];
//			5'd12: mem_rdata=data2[159:128];
//			5'd13: mem_rdata=data2[151:120];
//			5'd14: mem_rdata=data2[143:112];
//			5'd15: mem_rdata=data2[135:104];
//			5'd16: mem_rdata=data2[127:96];
//			5'd17: mem_rdata=data2[119:88];
//			5'd18: mem_rdata=data2[111:80];
//			5'd19: mem_rdata=data2[103:72];
//			5'd20: mem_rdata=data2[95:64];
//			5'd21: mem_rdata=data2[87:56];
//			5'd22: mem_rdata=data2[79:48];
//			5'd23: mem_rdata=data2[71:40];
//			5'd24: mem_rdata=data2[63:32];
//			5'd25: mem_rdata=data2[55:24];
//			5'd26: mem_rdata=data2[47:16];
//			5'd27: mem_rdata=data2[39:8];
//			5'd28: mem_rdata=data2[31:0];
//			5'd29: mem_rdata={8'd0, data2[23:0]};
//			5'd30: mem_rdata={16'd0, data2[15:0]};
//			5'd31: mem_rdata={24'd0, data2[7:0]};
//		endcase 
	end
	//if not hit in both way !!!!need double check!!!!!!!!!!
	else 
		mem_rdata = 32'd0;
end
endmodule: data_calc_read_hit
