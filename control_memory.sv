import rv32i_types::*;

module control_memory
(
	input rv32i_opcode opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	output EX_struct EX_struct_out,
	output MEM_struct MEM_struct_out,
	output WB_struct WB_struct_out
);

always_comb
begin
	EX_struct_out.opcode = opcode;
	EX_struct_out.pcadd_sel = 0;
	EX_struct_out.alumux_sel = 0;
	EX_struct_out.alumux_sel_a = 0;
	EX_struct_out.pc_adder_arg = 0;
	EX_struct_out.cmpmux_sel = 0;
	EX_struct_out.aluop = alu_ops'(funct3);
	EX_struct_out.cmpop = branch_funct3_t'(funct3);
	
	MEM_struct_out.opcode = opcode;
	MEM_struct_out.pcmux_if_sel = 0;
	MEM_struct_out.mem_read = 0;
	MEM_struct_out.mem_write = 0;
	MEM_struct_out.mem_byte_enable = 4'b1111;
	MEM_struct_out.mask_sel = 0;
	MEM_struct_out.load_predictor = 0;
	
	WB_struct_out.opcode = opcode;
	WB_struct_out.wbmux_sel = 0;
	WB_struct_out.load_regfile = 0;
	
	case (opcode)
		op_auipc: begin
			WB_struct_out.load_regfile=1;
			EX_struct_out.alumux_sel=1;
			EX_struct_out.aluop=alu_add;
			EX_struct_out.alumux_sel_a = 1;
		end
		op_lui: begin
			WB_struct_out.load_regfile=1;
			WB_struct_out.wbmux_sel=2;
		end
		op_store: begin
			case (funct3)
				sw: begin
					EX_struct_out.alumux_sel = 3;
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_write = 1;
					MEM_struct_out.mem_byte_enable = 4'b1111;
				end
				sh: begin
					EX_struct_out.alumux_sel = 3;
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_write = 1;
					MEM_struct_out.mem_byte_enable = 4'b0011;
				end
				sb: begin
					EX_struct_out.alumux_sel = 3;
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_write = 1;
					MEM_struct_out.mem_byte_enable = 4'b0001;
				end
				default :;
			endcase
		end
		op_load: begin
			case (funct3) 
				lw: begin
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_read = 1;
					MEM_struct_out.mask_sel = 0;
					WB_struct_out.wbmux_sel = 3;
					WB_struct_out.load_regfile = 1;
				end
				lh: begin
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_read = 1;
					MEM_struct_out.mask_sel = 1;
					WB_struct_out.wbmux_sel = 3;
					WB_struct_out.load_regfile = 1;
				end
				lhu: begin
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_read = 1;
					MEM_struct_out.mask_sel = 2;
					WB_struct_out.wbmux_sel = 3;
					WB_struct_out.load_regfile = 1;
				end
				lb: begin
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_read = 1;
					MEM_struct_out.mask_sel = 3;
					WB_struct_out.wbmux_sel = 3;
					WB_struct_out.load_regfile = 1;
				end
				lbu: begin
					EX_struct_out.aluop = alu_add;
					MEM_struct_out.mem_read = 1;
					MEM_struct_out.mask_sel = 4;
					WB_struct_out.wbmux_sel = 3;
					WB_struct_out.load_regfile = 1;
				end
				default :;
			endcase
		end
		//////////////////////////////////////////////////////
		op_br: begin
			MEM_struct_out.pcmux_if_sel = 1;
			MEM_struct_out.load_predictor = 1;
		end
		//////////////////////////////////////////////////////
		op_imm: begin
			case (funct3)
				slt: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.cmpop = blt;
					WB_struct_out.wbmux_sel = 1;
					EX_struct_out.cmpmux_sel = 1;
				end
				sltu: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.cmpop = bltu;
					WB_struct_out.wbmux_sel = 1;
					EX_struct_out.cmpmux_sel = 1;
				end
				sr: begin
					if (funct7 == 7'b0100000) begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.aluop = alu_sra;
					end
					else begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.aluop = alu_ops'(funct3);
					end
				end
				default: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.aluop = alu_ops'(funct3);
				end
			endcase
		end
		op_reg: begin
			case (funct3)
				add: begin
					if (funct7 == 7'b0000000) begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.alumux_sel = 5;
						EX_struct_out.aluop = alu_add;
					end
					else begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.alumux_sel = 5;
						EX_struct_out.aluop = alu_sub;
					end
				end
				sll: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.alumux_sel = 5;
					EX_struct_out.aluop = alu_sll;
				end
				axor: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.alumux_sel = 5;
					EX_struct_out.aluop = alu_xor;
				end
				sr: begin
					if (funct7 == 7'b0000000) begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.alumux_sel = 5;
						EX_struct_out.aluop = alu_srl;
					end
					else begin
						WB_struct_out.load_regfile = 1;
						EX_struct_out.alumux_sel = 5;
						EX_struct_out.aluop = alu_sra;
					end
				end
				aor: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.alumux_sel = 5;
					EX_struct_out.aluop = alu_or;
				end
				aand: begin
					WB_struct_out.load_regfile = 1;
					EX_struct_out.alumux_sel = 5;
					EX_struct_out.aluop = alu_and;
				end
				slt: begin
					WB_struct_out.load_regfile = 1;
					WB_struct_out.wbmux_sel = 1;
					EX_struct_out.cmpop = blt;
				end
				sltu: begin
					WB_struct_out.load_regfile = 1;
					WB_struct_out.wbmux_sel = 1;
					EX_struct_out.cmpop = bltu;
				end
				default: ;
			endcase
		end
		op_jal: begin
			EX_struct_out.pcadd_sel = 1;  //j_imm
			WB_struct_out.wbmux_sel = 4;
			WB_struct_out.load_regfile = 1;
			MEM_struct_out.pcmux_if_sel = 2;
			MEM_struct_out.load_predictor = 1;
		end
		op_jalr: begin
			EX_struct_out.pcadd_sel = 2;  //i_imm
			EX_struct_out.pc_adder_arg = 1;
			WB_struct_out.wbmux_sel = 4;
			WB_struct_out.load_regfile = 1;
			MEM_struct_out.pcmux_if_sel = 2;
			MEM_struct_out.load_predictor = 1;
		end
		default:;
	endcase
end 
endmodule : control_memory
