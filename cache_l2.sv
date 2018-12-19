module cache_l2
(
	input clk,
	input logic [31:0] mem_addr_l2,
	input logic mem_read_l2, mem_write_l2,
	input logic [255:0] mem_wdata_l2,
	/************/
	input [255:0] pmem_rdata,
	input logic pmem_resp,
	
	output logic mem_resp_l2,
	output logic [255:0] mem_rdata_l2,
	
	output [31:0] pmem_address,
   output [255:0] pmem_wdata,
	output logic pmem_read, pmem_write
);
logic pmem_we, pmarmux_sel, hit, replace, dirty, datamux_sel,load_addr;

cache_l2_datapath cache_l2_datapth
(
	.clk(clk),
	/*signals given by CPU*/
	.mem_address(mem_addr_l2),
	.mem_wdata(mem_wdata_l2),
	.mem_read(mem_read_l2),
	.mem_write(mem_write_l2),    ////double check!!!!!!!!!!!!!
	//.mem_byte_enable(mem_byte_enable),
	/*signals given by cache control unit*/
	.pmem_we(pmem_we), 
	.pmarmux_sel(pmarmux_sel),
	.datamux_sel(datamux_sel),
	.load_addr(load_addr),
	/*signals given by physical memory*/
	.pmem_rdata(pmem_rdata),
	/*signals to CPU*/
	.mem_rdata(mem_rdata_l2),
	/*signals to cache control unit*/
	.hit(hit), 
	.replace(replace), 
	.dirty(dirty),
	/*signals to physical memory*/
	.pmem_address(pmem_address),
	.pmem_wdata(pmem_wdata)
);

cache_l2_control cache_l2_control
(
	.clk(clk),
	/*signals from datapath*/
	.hit(hit), 
	.replace(replace), 
	.dirty(dirty),
	/*signals from cpu*/
	.mem_read(mem_read_l2), 
	.mem_write(mem_write_l2),
	/*signals from pmem*/
	.pmem_resp(pmem_resp),
	/*signals to datapath*/
	.pmem_we(pmem_we), 
	.pmarmux_sel(pmarmux_sel),
	.datamux_sel(datamux_sel),
	.load_addr(load_addr),
	/*signals to cpu*/
	.mem_resp(mem_resp_l2),
	/*signals to pmem*/
	.pmem_read(pmem_read), 
	.pmem_write(pmem_write)
);

endmodule 
