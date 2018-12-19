module arbiter
(
	input [31:0] pmem_addr_i, pmem_addr_d,
	input logic pmem_read_i, pmem_read_d, pmem_write_i, pmem_write_d,
	input [255:0] pmem_wdata_i, pmem_wdata_d,
	input logic mem_resp_l2,
	input [255:0] mem_rdata_l2,
	//input logic arbiter_hold_i, arbiter_hold_d,
	output logic pmem_resp_i, pmem_resp_d,
	output logic [255:0] pmem_rdata_i, pmem_rdata_d,
	output logic mem_read_l2, mem_write_l2,
	output logic [31:0] mem_addr_l2,
	output logic [255:0] mem_wdata_l2
);

always_comb begin
	pmem_resp_i=0;
	pmem_resp_d=0;
	pmem_rdata_i=mem_rdata_l2;
	pmem_rdata_d=mem_rdata_l2;
	mem_read_l2=0;
	mem_write_l2=0;
	mem_addr_l2=0;
	mem_wdata_l2=0;
	if (pmem_read_i==1&& pmem_read_d==0 && pmem_write_d==0) begin
		mem_read_l2=pmem_read_i;
		mem_addr_l2=pmem_addr_i;
		pmem_resp_i=mem_resp_l2;
		pmem_rdata_i=mem_rdata_l2;
		mem_write_l2=pmem_write_i;
		mem_wdata_l2=pmem_wdata_i;
	end
	else if (pmem_read_i==0 && (pmem_read_d==1 || pmem_write_d==1)) begin
		mem_read_l2=pmem_read_d;
		mem_addr_l2=pmem_addr_d;
		pmem_resp_d=mem_resp_l2;
		pmem_rdata_d=mem_rdata_l2;
		mem_write_l2=pmem_write_d;
		mem_wdata_l2=pmem_wdata_d;
	end
	else if (pmem_read_i==1 && (pmem_read_d==1 || pmem_write_d==1)) begin
		mem_read_l2=pmem_read_d;
		mem_addr_l2=pmem_addr_d;
		pmem_resp_d=mem_resp_l2;
		pmem_rdata_d=mem_rdata_l2;
		mem_write_l2=pmem_write_d;
		mem_wdata_l2=pmem_wdata_d;
	end
end	
endmodule
