module buffer_control
(
	input clk,
	/*from arbiter*/
	input logic mem_read, mem_write,
	input [255:0] mem_wdata,
	input [31:0] mem_addr,
	/*from L2 cache*/	
	input logic pmem_resp,
	/*from buffer registers*/
	input [255:0] data_buffer_out,
	input [31:0] addr_buffer_out,
	/*to arbiter*/
	output logic mem_resp,
	/*to L2 cache*/
	output logic pmem_write, pmem_read,
	output logic [255:0] pmem_wdata,
	output logic [31:0] pmem_addr,
	/*to buffer registers*/
	output logic load_data_buffer,
	output logic [255:0] data_buffer_in,
	output logic load_addr_buffer,
	output logic [31:0] addr_buffer_in
	
);

enum int unsigned {
   /* List of states */
	done,
	load,
	writeback
	//update_cache
} state, next_state;

always_comb begin
	mem_resp=0;
	pmem_write=0;
	pmem_read=0;
	pmem_wdata=256'd0;
	pmem_addr=32'd0;
	load_data_buffer=0;
	data_buffer_in=256'd0;
	load_addr_buffer=0;
	addr_buffer_in=32'd0;
	case (state)
		done: begin
			pmem_read=mem_read;
			pmem_addr=mem_addr;
			mem_resp=(pmem_resp & mem_read) | mem_write;
			load_addr_buffer=mem_write;
			load_data_buffer=mem_write;
			pmem_write=0;
			addr_buffer_in=mem_addr;
			data_buffer_in=mem_wdata;
		end
		load: begin
			pmem_read=mem_read;
			pmem_addr=mem_addr;
			mem_resp=pmem_resp & mem_read;
			load_addr_buffer=0;
			load_data_buffer=0;
			pmem_write=0;
		end
		writeback: begin
			pmem_addr=addr_buffer_out;
			pmem_wdata=data_buffer_out;
			pmem_write=1;
			pmem_read=0;
			mem_resp=0;
		end
		default: ;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = state;
	case(state)
		done: begin
			if (mem_write)
				next_state=load;
			else
				next_state=done;
		end
		load: begin
			if (!mem_read) 
				next_state=writeback;
			else	
				next_state=load;
		end
		writeback: begin
			if (pmem_resp)
				next_state=done;
			else	
				next_state=writeback;
		end
		default:;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
   /* Assignment of next state on clock edge */
	state <= next_state;
end
endmodule
