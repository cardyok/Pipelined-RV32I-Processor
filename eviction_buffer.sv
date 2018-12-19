module eviction_buffer
(
	input clk,
	/*from arbiter*/
	input logic mem_read, mem_write,
	input [255:0] mem_wdata,
	input [31:0] mem_addr,
	/*from L2 cache*/
	input logic pmem_resp,
	/*to arbiter*/
	output logic mem_resp,
	/*to L2 cache*/
	output logic pmem_write, pmem_read,
	output [255:0] pmem_wdata,
	output [31:0] pmem_addr
);

logic load_addr_buffer, load_data_buffer;
logic [255:0] data_buffer_in, data_buffer_out;
logic [31:0] addr_buffer_in, addr_buffer_out;

register #(.width(256)) data_buffer
(
	.clk,
	.load(load_data_buffer),
	.in(data_buffer_in),
	.out(data_buffer_out)
);

register #(.width(32)) addr_buffer
(
	.clk,
	.load(load_addr_buffer),
	.in(addr_buffer_in),
	.out(addr_buffer_out)
);

buffer_control buffer_control
(
	.clk,
	/*from arbiter*/
	.mem_read(mem_read), 
	.mem_write(mem_write),
	.mem_wdata(mem_wdata),
	.mem_addr(mem_addr),
	/*from L2 cache*/	
	.pmem_resp(pmem_resp),
	/*from buffer register*/
	.addr_buffer_out(addr_buffer_out),
	.data_buffer_out(data_buffer_out),
	/*to arbiter*/
	.mem_resp(mem_resp),
	/*to L2 cache*/
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.pmem_wdata(pmem_wdata),
	.pmem_addr(pmem_addr),
	/*to buffer register*/
	.load_data_buffer(load_data_buffer),
	.data_buffer_in(data_buffer_in),
	.load_addr_buffer(load_addr_buffer),
	.addr_buffer_in(addr_buffer_in)
);

endmodule
