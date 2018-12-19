module cache_l2_datapath
(
	input clk,
	/*signals given by CPU*/
	input [31:0] mem_address, 
	input [255:0] mem_wdata,
	input logic mem_read, mem_write,    ////double check!!!!!!!!!!!!!
	//input [3:0] mem_byte_enable,
	/*signals given by cache control unit*/
	input logic pmem_we, pmarmux_sel, datamux_sel,load_addr,
	/*signals given by physical memory*/
	input [255:0] pmem_rdata,
	
	/*signals to CPU*/
	output [255:0] mem_rdata,
	/*signals to cache control unit*/
	output logic hit, replace, dirty,
	/*signals to physical memory*/
	output logic [31:0] pmem_address,
	output logic [255:0] pmem_wdata
);

logic [21:0] target_tag;
logic [4:0] index;
logic [4:0] offset;
logic [31:0] pmem_address_temp;

logic valid1, valid2, dirty1, dirty2, lru;
logic [21:0] tag1, tag2;
logic [255:0] data1, data2;

logic hit1, hit2;
logic [255:0] cache_wdata;

logic update_way;

logic we_out1, we_out2;
logic [255:0] dmux_out1, dmux_out2;

logic [21:0] tagmux_out, pmarmux_out;

assign pmem_address_temp = {pmarmux_out, index, 5'd0};

register addr_reg
(
	.clk(clk),
   .load(load_addr),
   .in(pmem_address_temp),
   .out(pmem_address)
);

addr_parser #(.width(5)) addr_parser 
(
	.mem_addr(mem_address),
	.tag(target_tag),
	.index(index),
	.offset(offset)
);

array #(.width(1)) valid_array0
(
	.clk,
	.write((pmem_we&(~update_way))), ///////////////////////////////////
	.index(index),
	.datain(1'b1),
	.dataout(valid1)
);

array #(.width(1)) valid_array1
(
	.clk,
	.write((pmem_we&update_way)), ///////////////////////////////////
	.index(index),
	.datain(1'b1),
	.dataout(valid2)
);

array #(.width(22)) tag_array0
(
	.clk,
	.write((pmem_we&(~update_way))), ///////////////////////////////////
	.index(index),
	.datain(target_tag),
	.dataout(tag1)
);

array #(.width(22)) tag_array1
(
	.clk,
	.write((pmem_we&update_way)), ///////////////////////////////////
	.index(index),
	.datain(target_tag),
	.dataout(tag2)
);

array #(.width(256)) data_array0
(
	.clk,
	.write(we_out1), ///////////////////////////////////
	.index(index),
	.datain(dmux_out1),
	.dataout(data1)
);

array #(.width(256)) data_array1
(
	.clk,
	.write(we_out2), ///////////////////////////////////
	.index(index),
	.datain(dmux_out2),
	.dataout(data2)
);

array #(.width(1)) dirty_array0
(
	.clk,
	.write(we_out1), ///////////////////////////////////
	.index(index),
	.datain(mem_write),
	.dataout(dirty1)
);

array #(.width(1)) dirty_array1
(
	.clk,
	.write(we_out2), ///////////////////////////////////
	.index(index),
	.datain(mem_write),
	.dataout(dirty2)
);

array #(.width(1)) lru_array
(
	.clk,
	.write((hit1|hit2)), ///////////////////////////////////
	.index(index),
	.datain(hit1),
	.dataout(lru)
);

array_we array_we_1
(
	.hit(hit1),
	.mem_write(mem_write),
	.pmem_write(pmem_we),
	.update_way((~update_way)),
	.write_enable(we_out1)
);

array_we array_we_2
(
	.hit(hit2),
	.mem_write(mem_write),
	.pmem_write(pmem_we),
	.update_way(update_way),
	.write_enable(we_out2)
);

mux2 #(.width(256)) datamux_1
(
	.sel(datamux_sel),
	.a(pmem_rdata),
	.b(cache_wdata),
	.f(dmux_out1)
);

mux2 #(.width(256)) datamux_2
(
	.sel(datamux_sel),
	.a(pmem_rdata),
	.b(cache_wdata),
	.f(dmux_out2)
);

comparator #(.width(22)) comparator1
(
	.target_tag(target_tag),
	.curr_tag(tag1),
	.valid(valid1),
	.hit(hit1)
);

comparator #(.width(22)) comparator2
(
	.target_tag(target_tag),
	.curr_tag(tag2),
	.valid(valid2),
	.hit(hit2)
);

data_calc_read_hit_l2 data_calc_read_hit_l2
(
	.hit1(hit1),
	.hit2(hit2),
	.data1(data1),
	.data2(data2),
	.offset(offset),
	.mem_rdata(mem_rdata)
);

data_calc_write_hit_l2 data_calc_write_hit_l2
(
	.hit1(hit1),
	.hit2(hit2),
	.data1(data1),
	.data2(data2),
	.offset(offset),
	.mem_wdata(mem_wdata),
	//.mem_byte_enable(mem_byte_enable),
	.cache_wdata(cache_wdata)
);

cache_control_signal_handler cache_control_signal_handler
(
	.hit1(hit1),
	.hit2(hit2),
	.valid1(valid1),
	.valid2(valid2),
	.dirty1(dirty1),
	.dirty2(dirty2),
	.lru(lru),
	.update_way(update_way),
	.replace(replace), 
	.dirty(dirty),
	.hit(hit)
);

mux2 #(.width(22)) tagmux
(
	.sel(update_way),
	.a(tag1),
	.b(tag2),
	.f(tagmux_out)
);

mux2 #(.width(22)) pmarmux
(
	.sel(pmarmux_sel),
	.a(target_tag),
	.b(tagmux_out),
	.f(pmarmux_out)
);

mux2 #(.width(256)) pmdrmux
(
	.sel(update_way),
	.a(data1),
	.b(data2),
	.f(pmem_wdata)
);
endmodule: cache_l2_datapath
