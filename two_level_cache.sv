module two_level_cache
(
	 input clk,
	/* Port A I_Cache*/
    input read_a,
    input write_a,
    input [3:0] wmask_a,
    input [31:0] address_a,
    input [31:0] wdata_a,
	 output logic resp_a,
    output logic [31:0] rdata_a,
	 
    /* Port B D_Cache*/
    input read_b,
    input write_b,
    input [3:0] wmask_b,
    input [31:0] address_b,
    input [31:0] wdata_b,
	 output logic resp_b,
    output logic [31:0] rdata_b,
	 
	 /*Communication with main memory*/
	 input [255:0] pmem_rdata,
	 input logic pmem_resp,
	 output [31:0] pmem_address,
    output [255:0] pmem_wdata,
	 output logic pmem_read, pmem_write,
	 
	 /*To pipeline, for counter*/
	 output logic l2_resp,
	 output logic l2_access
);

logic [31:0] pmem_addr_i, pmem_addr_d;
logic pmem_resp_i, pmem_resp_d;
logic [255:0] pmem_rdata_i, pmem_rdata_d, pmem_wdata_i, pmem_wdata_d;
logic pmem_read_i, pmem_write_i, pmem_read_d, pmem_write_d;

logic [31:0] mem_addr_l2,mem_addr_phys;
logic [255:0] mem_rdata_l2, mem_wdata_l2,mem_wdata_phys;
logic mem_read_l2, mem_write_l2, mem_resp_l2,mem_read_phys,mem_write_phys,mem_resp_phys;

logic mem_write_l2_buf, mem_read_l2_buf, mem_resp_l2_buf;
logic [255:0] mem_wdata_l2_buf;
logic [31:0] mem_addr_l2_buf;

//logic mem_resp_comb;
//assign mem_resp_comb=(mem_read_l2 & mem_resp_l2)|(mem_write_l2 & mem_resp_l2_buf);
assign l2_resp = mem_resp_l2;
assign l2_access = mem_read_l2||mem_write_l2;

icache i_cache_l1
(
	.clk(clk),
	/*inputs from port A*/
	.mem_address(address_a), 
	.mem_wdata(wdata_a), 
	.mem_read(read_a), 
	.mem_write(write_a), 
	.mem_byte_enable(wmask_a),
	/*inputs from arbiter*/
	.pmem_rdata(pmem_rdata_i),
	.pmem_resp(pmem_resp_i),
	/*outputs to port A*/
	.mem_rdata(rdata_a),
	.mem_resp(resp_a),
	/*outputs to arbiter*/
	.pmem_address(pmem_addr_i),
	.pmem_wdata(pmem_wdata_i),
	.pmem_read(pmem_read_i), 
	.pmem_write(pmem_write_i)
	//.arbiter_hold(arbiter_hold_i)
);

cache d_cache_l1
(
   .clk(clk),
	/*inputs from port A*/
	.mem_address(address_b), 
	.mem_wdata(wdata_b), 
	.mem_read(read_b), 
	.mem_write(write_b), 
	.mem_byte_enable(wmask_b),
	/*inputs from arbiter*/
	.pmem_rdata(pmem_rdata_d),
	.pmem_resp(pmem_resp_d),
	/*outputs to port A*/
	.mem_rdata(rdata_b),
	.mem_resp(resp_b),
	/*outputs to arbiter*/
	.pmem_address(pmem_addr_d),
	.pmem_wdata(pmem_wdata_d),
	.pmem_read(pmem_read_d), 
	.pmem_write(pmem_write_d)
	//.arbiter_hold(arbiter_hold_d)
);

arbiter arbiter
(
	.pmem_addr_i(pmem_addr_i), 
	.pmem_addr_d(pmem_addr_d), 
	.pmem_read_i(pmem_read_i), 
	.pmem_read_d(pmem_read_d), 
	.pmem_write_i(pmem_write_i), 
	.pmem_write_d(pmem_write_d),
	.pmem_wdata_i(pmem_wdata_i), 
	.pmem_wdata_d(pmem_wdata_d),
	.pmem_resp_i(pmem_resp_i), 
	.pmem_resp_d(pmem_resp_d),
	.pmem_rdata_i(pmem_rdata_i), 
	.pmem_rdata_d(pmem_rdata_d),
	//.arbiter_hold_i(arbiter_hold_i),
	//.arbiter_hold_d(arbiter_hold_d),
	/*communicate with L2 cache*/
	.mem_resp_l2(mem_resp_l2),
	.mem_rdata_l2(mem_rdata_l2),
	.mem_read_l2(mem_read_l2), 
	.mem_write_l2(mem_write_l2),
	.mem_addr_l2(mem_addr_l2),
	.mem_wdata_l2(mem_wdata_l2)
);

eviction_buffer eviction_buffer
(
	.clk,
	.mem_read(mem_read_l2), 
	.mem_write(mem_write_l2),
	.mem_wdata(mem_wdata_l2),
	.mem_addr(mem_addr_l2),
	.pmem_resp(mem_resp_l2_buf),
	.mem_resp(mem_resp_l2),
	.pmem_write(mem_write_l2_buf), 
	.pmem_read(mem_read_l2_buf),
	.pmem_wdata(mem_wdata_l2_buf),
	.pmem_addr(mem_addr_l2_buf)
);

cache_l2 cache_l2
(
	.clk(clk),
	/*communicate with arbiter*/
	.mem_addr_l2(mem_addr_l2_buf),
	.mem_read_l2(mem_read_l2_buf),
	.mem_write_l2(mem_write_l2_buf),
	.mem_wdata_l2(mem_wdata_l2_buf),
	.mem_rdata_l2(mem_rdata_l2),
	.mem_resp_l2(mem_resp_l2_buf),
	/*communicate with main memory*/
	.pmem_rdata(pmem_rdata),
	.pmem_resp(mem_resp_phys),
	.pmem_address(mem_addr_phys),
   .pmem_wdata(mem_wdata_phys),
	.pmem_read(mem_read_phys), 
	.pmem_write(mem_write_phys)
);

eviction_buffer eviction_buffertwo
(
	.clk,
	.mem_read(mem_read_phys), 
	.mem_write(mem_write_phys),
	.mem_wdata(mem_wdata_phys),
	.mem_addr(mem_addr_phys),
	.pmem_resp(pmem_resp),
	.mem_resp(mem_resp_phys),
	.pmem_write(pmem_write), 
	.pmem_read(pmem_read),
	.pmem_wdata(pmem_wdata),
	.pmem_addr(pmem_address)
);

endmodule 

