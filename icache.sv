 module icache
(
	input clk,
	/*inputs from cpu*/
	input [31:0] mem_address, mem_wdata, 
	input logic mem_read, mem_write, 
	input [3:0] mem_byte_enable,
	/*inputs from pmem*/
	input [255:0] pmem_rdata,
	input logic pmem_resp,
	/*outputs to cpu*/
	output [31:0] mem_rdata,
	output logic mem_resp,
	/*outputs to pmem*/
	output [31:0] pmem_address,
	output [255:0] pmem_wdata,
	output logic pmem_read, pmem_write
);

logic pmem_we, pmarmux_sel, hit, replace, dirty, datamux_sel,load_addr;

icache_datapath datapath
(
	.clk(clk),
	/*signals given by CPU*/
	.mem_address(mem_address),
	.mem_wdata(mem_wdata),
	.mem_read(mem_read),
	.mem_write(mem_write),    ////double check!!!!!!!!!!!!!
	.mem_byte_enable(mem_byte_enable),
	/*signals given by cache control unit*/
	.pmem_we(pmem_we), 
	.pmarmux_sel(pmarmux_sel),
	.datamux_sel(datamux_sel),
	.load_addr(load_addr),
	/*signals given by physical memory*/
	.pmem_rdata(pmem_rdata),
	/*signals to CPU*/
	.mem_rdata(mem_rdata),
	/*signals to cache control unit*/
	.hit(hit), 
	.replace(replace), 
	.dirty(dirty),
	/*signals to physical memory*/
	.pmem_address(pmem_address),
	.pmem_wdata(pmem_wdata)
);

icache_control cache_control
(
	.clk(clk),
	/*signals from datapath*/
	.hit(hit), 
	.replace(replace), 
	.dirty(dirty),
	/*signals from cpu*/
	.mem_read(mem_read), 
	.mem_write(mem_write),
	/*signals from pmem*/
	.pmem_resp(pmem_resp),
	/*signals to datapath*/
	.pmem_we(pmem_we), 
	.pmarmux_sel(pmarmux_sel),
	.datamux_sel(datamux_sel),
	.load_addr(load_addr),
	/*signals to cpu*/
	.mem_resp(mem_resp),
	/*signals to pmem*/
	.pmem_read(pmem_read), 
	.pmem_write(pmem_write)
);

endmodule: icache