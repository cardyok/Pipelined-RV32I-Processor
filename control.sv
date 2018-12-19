import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module control
(
   /* Input and output port declarations */
	input clk,
	/* Datapath controls */
	input rv32i_opcode opcode,
	input logic br_en,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	output logic load_pc,
	output logic load_ir,
	output logic load_regfile,
	output logic load_mar,
	output logic load_mdr,
	output logic load_data_out,
	output logic alumux1_sel, marmux_sel, pcmux_sel, cmpmux_sel,
	output logic [1:0] alumux2_sel, regfilemux_sel,
	output alu_ops aluop,
	output branch_funct3_t cmpop,
	/* et cetera */
	
	/* Memory signals */
	input mem_resp,
	output logic mem_read,
	output logic mem_write,
	output rv32i_mem_wmask mem_byte_enable
);

enum int unsigned {
   /* List of states */
	fetch1,
	fetch2,
	fetch3,
	decode,
	s_auipc,
	s_lui,
	calc_addr_s,
	str1,
	str2,
	calc_addr_l,
	ldr1,
	ldr2,
	br,
	s_imm_other,
	s_imm_srai,
	s_imm_sltiu,
	s_imm_slti
} state, next_state;

always_comb
begin : state_actions
   /* Default output assignments */
	load_pc = 1'b0;
	load_ir = 1'b0;
	load_regfile = 1'b0;
	load_mar = 1'b0;
	load_mdr = 1'b0;
	load_data_out = 1'b0;
	alumux1_sel = 1'b0;
	alumux2_sel = 2'b00;
	regfilemux_sel = 2'b00;
	marmux_sel = 1'b0;
	pcmux_sel = 1'b0;
	//in many cases, aluop will be the same as funct3, so just typecast it
	aluop = alu_ops'(funct3);
	mem_read = 1'b0;
	mem_write = 1'b0;
	mem_byte_enable = 4'b1111;
	cmpop = branch_funct3_t'(funct3);
	cmpmux_sel = 1'b0;
	
   /* Actions for each state */
	case(state)
		fetch1: begin
			/* MAR <= PC */
			load_mar = 1;
		end
		fetch2: begin
			/* Read memory */
			mem_read = 1;
			load_mdr = 1;
		end
		fetch3: begin
			/* Load IR */
			load_ir = 1;
		end
		decode: /* Do nothing */;
		s_auipc: begin
			/* DR <= PC + u_imm */
			load_regfile = 1;
			//PC is the first input to the ALU
			alumux1_sel = 1;
			//the u-type immediate is the second input to the ALU
			alumux2_sel = 1;
			//in the case of auipc, funct3 is some random bits so we
			//must explicitly set the aluop
			aluop = alu_add;
			/* PC <= PC + 4 */
			load_pc = 1;
		end
		s_lui: begin
			load_regfile = 1;
			load_pc = 1;
			regfilemux_sel = 2;
		end
		calc_addr_s: begin
			alumux2_sel = 3;
			aluop = alu_add;
			load_mar = 1;
			load_data_out = 1;
			marmux_sel = 1;
		end
		str1: begin
			mem_write = 1;
		end
		str2: begin
			load_pc = 1;
		end 
		calc_addr_l: begin
			aluop = alu_add;
			load_mar = 1;
			marmux_sel = 1;
		end
		ldr1: begin
			load_mdr = 1;
			mem_read = 1;
		end
		ldr2: begin 
			regfilemux_sel = 3;
			load_regfile = 1;
			load_pc = 1;
		end
		br: begin
			pcmux_sel = br_en;
			load_pc = 1;
			alumux1_sel = 1;
			alumux2_sel = 2;
			aluop = alu_add;
		end
		s_imm_other: begin
			load_regfile = 1;
			load_pc = 1;
			aluop = alu_ops'(funct3);
		end
		s_imm_srai: begin
			load_regfile = 1;
			load_pc = 1;
			aluop = alu_sra;
		end
		s_imm_sltiu: begin
			load_regfile = 1;
			load_pc = 1;
			cmpop = bltu;
			regfilemux_sel = 1;
			cmpmux_sel = 1;
		end
		s_imm_slti: begin
			load_regfile = 1;
			load_pc = 1;
			cmpop = blt;
			regfilemux_sel = 1;
			cmpmux_sel = 1;
		end
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = state;
	case(state)
		fetch1: next_state = fetch2;
		fetch2: if (mem_resp) next_state = fetch3;
		fetch3: next_state = decode;
		decode: begin
			case(opcode)
				op_auipc: next_state = s_auipc;
				op_lui: next_state = s_lui;
				op_store: next_state = calc_addr_s;
				op_load: next_state = calc_addr_l;
				op_br: next_state = br;
				op_imm: begin
					if (funct3 == slt)
						next_state = s_imm_slti;
					else if (funct3 == sltu)
						next_state = s_imm_sltiu;
					else if (funct3 == sr && funct7 == 7'b0100000)
						next_state = s_imm_srai;
					else
						next_state = s_imm_other;
				end
				default: $display("Unknown␣opcode");
			endcase
		end
		calc_addr_s: next_state = str1;
		str1: begin
			if (mem_resp == 0)
				next_state = str1;
			else 
				next_state = str2;
		end 
		calc_addr_l: next_state = ldr1;
		ldr1: begin
			if (mem_resp == 0)
				next_state = ldr1;
			else
				next_state = ldr2;
		end 
		default: next_state = fetch1;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
   /* Assignment of next state on clock edge */
	state <= next_state;
end

endmodule : control
