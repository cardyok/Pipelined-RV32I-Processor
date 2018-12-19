module mp3
(
	 input clk,
	 input logic resp,
    input logic [255:0] rdata,
    output logic read,
    output logic write,
    output logic [31:0] address,
    output logic [255:0] wdata
);

logic resp_a, resp_b;
logic read_a, write_a, read_b, write_b;
logic [3:0] wmask_a, wmask_b;
logic [31:0] address_a, address_b, rdata_a, rdata_b, wdata_a, wdata_b;
logic l2_resp, l2_access;
datapath datapath
(
	 .clk(clk),
    /* Port A I_Cache*/
	 .resp_a(resp_a),
    .rdata_a(rdata_a),
    .read_a(read_a),
    .write_a(write_a),
    .wmask_a(wmask_a),
    .address_a(address_a),
    .wdata_a(wdata_a),
	 
    /* Port B D_Cache*/	 
    .resp_b(resp_b),
    .rdata_b(rdata_b),
    .read_b(read_b),
    .write_b(write_b),
    .wmask_b(wmask_b),
    .address_b(address_b),
    .wdata_b(wdata_b),
	 
	 /*From cache, for counter*/
	 .l2_resp,
	 .l2_access
);

two_level_cache two_level_cache
(
	 .clk(clk),
	/* Port A I_Cache*/
    .read_a(read_a),
    .write_a(write_a),
    .wmask_a(wmask_a),
    .address_a(address_a),
    .wdata_a(wdata_a),
	 .resp_a(resp_a),
    .rdata_a(rdata_a),
	 
    /* Port B D_Cache*/
    .read_b(read_b),
    .write_b(write_b),
    .wmask_b(wmask_b),
    .address_b(address_b),
    .wdata_b(wdata_b),
	 .resp_b(resp_b),
    .rdata_b(rdata_b),
	 
	 /*Communication with main memory*/
	 .pmem_rdata(rdata),
	 .pmem_resp(resp),
	 .pmem_address(address),
    .pmem_wdata(wdata),
	 .pmem_read(read), 
	 .pmem_write(write),
	 
	 /*To pipeline, for counter*/
	 .l2_resp,
	 .l2_access
);

endmodule
