module icache_control
(
	input clk,
	/*signals from datapath*/
	input logic hit, replace, dirty,
	/*signals from cpu*/
	input logic mem_read, mem_write,
	/*signals from pmem*/
	input logic pmem_resp,
	/*signals to datapath*/
	output logic pmem_we, pmarmux_sel, datamux_sel,load_addr,
	/*signals to cpu*/
	output logic mem_resp,
	/*signals to pmem*/
	output logic pmem_read, pmem_write
);

enum int unsigned {
   /* List of states */
	read_write_hit,
	write_back,
	load_pmem
	//update_cache
} state, next_state;

always_comb begin
	pmem_we = 0;
	mem_resp = 0;
	pmem_read = 0;
	pmem_write = 0;
	load_addr = 0;
	pmarmux_sel = 0;
	datamux_sel = 0;
	case (state)
		read_write_hit: begin
			mem_resp=hit;
			datamux_sel=1;
			if ((hit==0 && replace==1 && dirty==1)&&(mem_read==1||mem_write==1))
			begin
				load_addr = 1;
				pmarmux_sel = 1;
			end
			
			else if(((hit==0&&replace==0)||(hit==0&&replace==1&&dirty==0))&&(mem_read==1||mem_write==1))
				load_addr = 1;
		end
		write_back: begin
			pmem_write=1;
			if(pmem_resp==1)
			begin
				load_addr = 1;
			end
		end
		load_pmem: begin
			pmem_we=pmem_resp;
			pmem_read=1;
		end
		default:;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = state;
	case(state)
		read_write_hit: begin
			if (mem_read==1||mem_write==1) begin 
				if (hit==0 && replace==1 && dirty==1)
					next_state=write_back;
				else if ((hit==0&&replace==0)||(hit==0&&replace==1&&dirty==0))
					next_state=load_pmem;
				else next_state=read_write_hit;
			end
			else next_state=read_write_hit;
		end
		write_back: begin
			if (pmem_resp==0)
				next_state=write_back;
			else next_state=load_pmem;
		end
		load_pmem: begin
			if (pmem_resp==0)
				next_state=load_pmem;
			else next_state=read_write_hit;
		end
		//update_cache: next_state=read_write_hit;
		default:;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
   /* Assignment of next state on clock edge */
	state <= next_state;
end

endmodule : icache_control