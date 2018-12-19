import rv32i_types::*;

module datapath
(
	 input clk,
    /* Port A I_Cache*/
	 
    input logic resp_a,
    input logic [31:0] rdata_a,
    output read_a,
    output write_a,
    output [3:0] wmask_a,
    output [31:0] address_a,
    output [31:0] wdata_a,
	 
    /* Port B D_Cache*/
	 
    input logic resp_b,
    input logic [31:0] rdata_b,
    output read_b,
    output write_b,
    output [3:0] wmask_b,
    output [31:0] address_b,
    output [31:0] wdata_b,
	 
	 
	 /*From cache, for counter*/
	 input l2_resp,
	 input l2_access
);

logic cmpmux_sel;
logic [1:0] pcadd_sel;
logic [2:0] alumux_sel,  wbmux_sel;
logic [31:0] pcmux_if_out;
logic [31:0] b_imm, j_imm, i_imm, u_imm, s_imm, b_imm_out, j_imm_out, i_imm_out, u_imm_out, s_imm_out,u_imm_mem;
logic [31:0] pcmux_ex_out, alumux_out, alumux_out_a, cmpmux_out;
logic [31:0] alu_out_mem,alu_out_wb, br_en_wb, br_en_mem, br_en_ex, u_imm_wb, mem_data_mask_wb,mem_data_mask_wb_pseudo; 
logic [31:0] instruction_raw;
logic [31:0] pc_reg_out_if, pcadder_out_if, pcadder_mux_out, pc_reg_out_id, pc_reg_out_ex,pc_reg_out_mem,pc_reg_out_wb,pc_new;
logic [31:0] mem_rdata_wb;
logic pc_reg_load;
logic [2:0] mask_sel;
rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
EX_struct EX_struct_ID,EX_struct_EX;
MEM_struct MEM_struct_ID,MEM_struct_EX,MEM_struct_MEM;
WB_struct WB_struct_ID,WB_struct_EX,WB_struct_MEM,WB_struct_WB;
logic load_regfile;
logic [31:0] reg_datain,alu_out,rs1_out, rs2_out, rs1_out_EX, rs2_out_EX, rs1_out_old, rs2_out_old, mem_forward,ex_forward,ex_forward_out;
logic [4:0] rs1, rs2, rd, rd_EX, rd_MEM, rd_WB;
logic alumux_sel_a;

logic [1:0] forward_sel_a;
logic [1:0] forward_sel_b;
alu_ops aluop;
logic cmp_out;
branch_funct3_t cmpop;
logic flush_IF_ID, flush_IF_ID_EX,flush_counter,flush_counter_EX,predictor_a_hit,predictor_b_hit;
logic br_counter_ld,br_ms_counter_ld,I_cache_hit_ld,D_cache_hit_ld,l2_cache_hit_ld,I_cache_miss_ld,D_cache_miss_ld,l2_cache_miss_ld,stall_counter_ld,predictor_a_ld,predictor_b_ld;
logic br_counter_sel, br_ms_counter_sel,I_cache_hit_sel,D_cache_hit_sel,l2_cache_hit_sel,I_cache_miss_sel,D_cache_miss_sel,l2_cache_miss_sel,stall_counter_sel,predictor_a_sel,predictor_b_sel;
logic [31:0] rdata;
logic [31:0] br_counter;
logic [31:0] br_ms_counter;
logic [31:0] I_cache_hit;
logic [31:0] D_cache_hit;
logic [31:0] l2_cache_hit;
logic [31:0] I_cache_miss;
logic [31:0] D_cache_miss;
logic [31:0] l2_cache_miss;
logic [31:0] stall_counter;
logic [31:0] predictor_a;
logic [31:0] predictor_b;

/*latch signals*/
logic IF_ID_load;
logic ID_EX_load;
logic EX_MEM_load;
logic MEM_WB_load;

/*global predictor signals*/
logic [9:0] PHT_idx;
logic [1:0] PHT_wdata_a, PHT_wdata_b, PHT_rdata,PHT_rdata_a,PHT_rdata_b,PHT_rdata_a_temp,PHT_rdata_b_temp,PHT_rdata_temp,tournament_sel_prev,tournament_sel,tournament_write;
logic BTB_load,BTB_found,BTB_found_ID,BTB_counter_ID;
logic [31:0] BTB_data;
logic [31:0] BTB_input;
logic [31:0] pc_input;
logic [1:0] ID_PC_sel;
logic flush;

logic [2:0] funct3_temp;
logic[6:0] funct7_temp;
logic[6:0] opcode_temp,opcode_out;
logic [31:0] i_imm_out_temp;
logic [31:0] s_imm_out_temp;
logic [31:0] b_imm_out_temp;
logic [31:0] u_imm_out_temp;
logic [31:0] j_imm_out_temp;
logic [4:0] rs1_temp;
logic [4:0] rs2_temp;
logic [4:0] rd_temp;

assign opcode = rv32i_opcode' (opcode_out);
assign BTB_load = ((EX_struct_EX.opcode==op_jal)||(EX_struct_EX.opcode==op_jalr)||(EX_struct_EX.opcode==op_br))&&(!BTB_counter_ID);


/*Assigning load signals*/
assign instruction_raw = rdata_a;
assign address_a = pc_reg_out_if;
assign write_a = 1'b0;
assign wmask_a = 4'b0;
assign wdata_a = 32'b0;

assign read_a = 1;

assign br_counter_ld = ((MEM_struct_EX.opcode==op_br)||(MEM_struct_EX.opcode==op_jal)||(MEM_struct_EX.opcode==op_jalr)||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0000)))&&(EX_MEM_load);
assign br_ms_counter_ld = (flush_counter_EX||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0004)))&&(EX_MEM_load);
assign I_cache_hit_ld = ((resp_a&&(read_a||write_a))||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0008)))&&(EX_MEM_load);
assign D_cache_hit_ld = ((resp_b&&(read_b||write_b))||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0010)))&&(EX_MEM_load);
assign l2_cache_hit_ld = ((l2_resp&&l2_access)||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0018)));
assign I_cache_miss_ld = ((!resp_a&&(read_a||write_a))||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h000c)));
assign D_cache_miss_ld = ((!resp_b&&(read_b||write_b))||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0014)));
assign l2_cache_miss_ld = ((!l2_resp&&l2_access)||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h001c)));
assign stall_counter_ld = (flush_IF_ID_EX)||(!EX_MEM_load)||((MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0020));
assign predictor_a_ld = (predictor_a_hit)&&((MEM_struct_EX.opcode==op_br)||(MEM_struct_EX.opcode==op_jal)||(MEM_struct_EX.opcode==op_jalr))&&(EX_MEM_load);
assign predictor_b_ld = (predictor_b_hit)&&((MEM_struct_EX.opcode==op_br)||(MEM_struct_EX.opcode==op_jal)||(MEM_struct_EX.opcode==op_jalr))&&(EX_MEM_load);
assign br_counter_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0000);
assign br_ms_counter_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0004);
assign I_cache_hit_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0008);
assign I_cache_miss_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h000c);
assign D_cache_hit_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0010);
assign D_cache_miss_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0014);
assign l2_cache_hit_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0018);
assign l2_cache_miss_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h001c);
assign stall_counter_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0020);
assign predictor_a_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0024);
assign predictor_b_sel = (MEM_struct_EX.opcode==op_store) && (alu_out == 32'h0028);


/*
assign pc_reg_load = 1'b1&resp_a;
assign IF_ID_load = 1'b1&resp_a;
assign ID_EX_load = 1'b1 &d_mem_ready;
assign EX_MEM_load = 1'b1&d_mem_ready;
assign MEM_WB_load = 1'b1&d_mem_ready;
*/
assign pc_reg_load = (!(read_a||write_a)||resp_a)&&(!(read_b||write_b)||resp_b) &&(!((opcode == op_load)&& ((rd == instruction_raw[19:15])||(rd == instruction_raw[24:20]))));
assign IF_ID_load = (!(read_a||write_a)||resp_a)&&(!(read_b||write_b)||resp_b);
assign ID_EX_load = (!(read_a||write_a)||resp_a)&&(!(read_b||write_b)||resp_b);
assign EX_MEM_load = (!(read_a||write_a)||resp_a)&&(!(read_b||write_b)||resp_b);
assign MEM_WB_load = (!(read_a||write_a)||resp_a)&&(!(read_b||write_b)||resp_b);
assign flush_IF_ID = ((opcode == op_load)&& ((rd == instruction_raw[19:15])||(rd == instruction_raw[24:20]))) || flush;

assign read_b = MEM_struct_MEM.mem_read;
assign write_b = MEM_struct_MEM.mem_write && (address_b>=32'h0060);
assign wmask_b = MEM_struct_MEM.mem_byte_enable;
assign address_b = alu_out_mem;

/*Assign state signals*/
/*EX*/
assign pcadd_sel = EX_struct_ID.pcadd_sel;
assign alumux_sel = EX_struct_EX.alumux_sel;
assign alumux_sel_a = EX_struct_EX.alumux_sel_a;
assign aluop = EX_struct_EX.aluop;
assign cmpop = EX_struct_ID.cmpop;
assign cmpmux_sel = EX_struct_ID.cmpmux_sel;
/*MEM*/
/*WB*/
assign load_regfile = WB_struct_WB.load_regfile;
assign mask_sel = MEM_struct_MEM.mask_sel;
assign wbmux_sel = WB_struct_WB.wbmux_sel; 
/****************  IF stage  ********************/
//BTB
BTB #(.width(5)) BTB
(
    .clk,
    .load(flush_counter),
    .rindex(pc_reg_out_if),
    .windex(pc_reg_out_ex),
	 .in(pc_reg_out_if),
	 .miss(BTB_load),
	 .miss_in(pc_reg_out_id),
	 .hit(BTB_found),
	 .dest(BTB_data)
);


mux4 pcmux_if
(
	.sel(ID_PC_sel),
   .a(pcadder_out_if),
   .b(pc_reg_out_id+4),
	.c(pc_new),
	.d(BTB_data),
   .f(pc_input)
);


adder add_if
(
	.a(pc_reg_out_if),
	.b(32'd4),
	.f(pcadder_out_if)
);



pc_register pc_reg
(
	.clk(clk),
   .load(pc_reg_load),
   .in(pc_input),
   .out(pc_reg_out_if)
);

global_history GHT
(
	.clk(clk),
	.load_GHT(MEM_struct_ID.load_predictor), //////
	.in(cmp_out),
	.out(PHT_idx)
);
register #(.width(2)) tournament
(
    .clk,
    .load(MEM_struct_ID.load_predictor),
    .in(tournament_write),
    .out(tournament_sel)
);

PHT PHT
(
	.clk(clk),
	.write(MEM_struct_ID.load_predictor), //////
	.rindex(PHT_idx[9:2]^pc_reg_out_if[9:2]),
	.windex(PHT_idx[9:2]^pc_reg_out_id[9:2]),
	.datain(PHT_wdata_a),
	.dataout(PHT_rdata_a)
);


PHT LHT
(
	.clk(clk),
	.write(MEM_struct_ID.load_predictor), //////
	.rindex({pc_reg_out_if[9:2]}),
	.windex({pc_reg_out_id[9:2]}),
	.datain(PHT_wdata_b),
	.dataout(PHT_rdata_b)
);

mux2 #(.width(2)) tournament_mux
(
	.sel(tournament_sel[1]),
	.a(PHT_rdata_a),
	.b(PHT_rdata_b),
	.f(PHT_rdata)
);
/********************************* I-Cache TODO **************/
//IN mem_read, mem_address 
//OUT instruction
/****************  IF/ID latch*********************/

register #(.width(1)) BTB_hit_latch
(
    .clk,
    .load(IF_ID_load),
    .in(BTB_found),
    .out(BTB_found_ID)
);

register #(.width(1)) flush_counter_latch
(
    .clk,
    .load(IF_ID_load),
    .in(flush),
    .out(flush_counter)
);
register #(.width(1)) flush_ID_EX
(
    .clk,
    .load(IF_ID_load),
    .in(flush_IF_ID),
    .out(flush_IF_ID_EX)
);
register #(.width(2)) PHT_rdata_temp_latch
(
    .clk,
    .load(IF_ID_load),
    .in(PHT_rdata),
    .out(PHT_rdata_temp)
);
register #(.width(2)) PHT_rdata_a_temp_latch
(
    .clk,
    .load(IF_ID_load),
    .in(PHT_rdata_a),
    .out(PHT_rdata_a_temp)
);
register #(.width(2)) PHT_rdata_b_temp_latch
(
    .clk,
    .load(IF_ID_load),
    .in(PHT_rdata_b),
    .out(PHT_rdata_b_temp)
);
register #(.width(2)) tournament_latch
(
    .clk,
    .load(IF_ID_load),
    .in(tournament_sel),
    .out(tournament_sel_prev)
);
register #(.width(32)) pc_latch_IF_ID
(
    .clk,
    .load(IF_ID_load),
    .in(pc_reg_out_if),
    .out(pc_reg_out_id)
);
ir ir
(
    .clk,
    .load(IF_ID_load),
    .in(instruction_raw),
    .funct3(funct3_temp),
	 .funct7(funct7_temp),
    .opcode(opcode_temp),
    .i_imm(i_imm_out_temp),
	 .s_imm(s_imm_out_temp),
	 .b_imm(b_imm_out_temp),
	 .u_imm(u_imm_out_temp),
	 .j_imm(j_imm_out_temp),
	 .rs1(rs1_temp),
	 .rs2(rs2_temp),
	 .rd(rd_temp)
);
/****************  ID stage *********************/

mux2 #(.width(5)) rs1_flush
(
	.sel(flush_IF_ID_EX),
	.a(rs1_temp),
	.b(5'b0),
	.f(rs1)
);
mux2 #(.width(5)) rs2_flush
(
	.sel(flush_IF_ID_EX),
	.a(rs2_temp),
	.b(5'b0),
	.f(rs2)
);
mux2 #(.width(5)) rd_flush
(
	.sel(flush_IF_ID_EX),
	.a(rd_temp),
	.b(5'b0),
	.f(rd)
);
mux2 s_imm_flush
(
	.sel(flush_IF_ID_EX),
	.a(s_imm_out_temp),
	.b(32'b0),
	.f(s_imm_out)
);
mux2 b_imm_flush
(
	.sel(flush_IF_ID_EX),
	.a(b_imm_out_temp),
	.b(32'b0),
	.f(b_imm_out)
);
mux2 u_imm_flush
(
	.sel(flush_IF_ID_EX),
	.a(u_imm_out_temp),
	.b(32'b0),
	.f(u_imm_out)
);
mux2 j_imm_flush
(
	.sel(flush_IF_ID_EX),
	.a(j_imm_out_temp),
	.b(32'b0),
	.f(j_imm_out)
);
mux2 i_imm_flush
(
	.sel(flush_IF_ID_EX),
	.a(i_imm_out_temp),
	.b(32'b0),
	.f(i_imm_out)
);
mux2 #(.width(3)) funct3_flush
(
	.sel(flush_IF_ID_EX),
	.a(funct3_temp),
	.b(3'b0),
	.f(funct3)
);
mux2 #(.width(7)) funct7_flush
(
	.sel(flush_IF_ID_EX),
	.a(funct7_temp),
	.b(7'b0),
	.f(funct7)
);
mux2 #(.width(7)) opcode_flush
(
	.sel(flush_IF_ID_EX),
	.a(opcode_temp),
	.b(7'b0110011),
	.f(opcode_out)
);

control_memory control_memory
(
	.opcode(opcode),
	.funct3(funct3),
	.funct7(funct7),
	.EX_struct_out(EX_struct_ID),
	.MEM_struct_out(MEM_struct_ID),
	.WB_struct_out(WB_struct_ID)
);

regfile regfile
(
	.clk(clk),
   .load(load_regfile),
   .in(reg_datain),
   .src_a(rs1),
	.src_b(rs2), 
	.dest(rd_WB),
   .reg_a(rs1_out), 
	.reg_b(rs2_out)
);
//branch section
mux4 pcmux_ex
(
	.sel(pcadd_sel),
	.a(b_imm_out),
	.b(j_imm_out),
	.c(i_imm_out),
	.d(i_imm_out),
	.f(pcmux_ex_out)
);
mux2 pcadder_sel_mux
(
	.sel(EX_struct_ID.pc_adder_arg),
	.a(pc_reg_out_id+pcmux_ex_out),
	.b(rs1_out_old+pcmux_ex_out),
	.f(pc_new)
);
//Forwarding section 

mux4 forward_mux_a
(
	.sel(forward_sel_a),
	.a(rs1_out),
	.b(ex_forward),
	.c(mem_forward),
	.d(reg_datain),
	.f(rs1_out_old)
);
mux4 forward_mux_b
(
	.sel(forward_sel_b),
	.a(rs2_out),
	.b(ex_forward),
	.c(mem_forward),
	.d(reg_datain),
	.f(rs2_out_old)
);
forward foward
(
	.MEM_write(WB_struct_MEM.load_regfile),
	.WB_write(WB_struct_WB.load_regfile),
	.EX_write(WB_struct_EX.load_regfile),
	.reg_MEM(rd_MEM),
	.reg_WB(rd_WB),
	.reg_EX(rd_EX),
	.sel_a(forward_sel_a),
	.sel_b(forward_sel_b),
	.curr_a(rs1),
	.curr_b(rs2)
);

mux2 cmpmux
(
	.sel(cmpmux_sel),
	.a(rs2_out_old),
	.b(i_imm_out),
	.f(cmpmux_out)
);

cmp cmp
(
	.a(rs1_out_old), 
	.b(cmpmux_out), 
	.cmpop(cmpop),
	.br_en(cmp_out)
);

PHT_write_control PHT_write_control_a
(
	.branch_result(cmp_out||(MEM_struct_ID.pcmux_if_sel==2)),
	.prev_data(PHT_rdata_a_temp),
	.PHT_datain(PHT_wdata_a)
);
PHT_write_control PHT_write_control_b
(
	.branch_result(cmp_out||(MEM_struct_ID.pcmux_if_sel==2)),
	.prev_data(PHT_rdata_b_temp),
	.PHT_datain(PHT_wdata_b)
);

tournament_write_control tournament_write_control
(
	.a(PHT_rdata_a_temp[1]==(cmp_out||(MEM_struct_ID.pcmux_if_sel==2))),
	.b(PHT_rdata_b_temp[1]==(cmp_out||(MEM_struct_ID.pcmux_if_sel==2))),
	.prev_data(tournament_sel_prev),
	.PHT_datain(tournament_write)
);

new_pc_mod new_pc_mod
(
	.sel(MEM_struct_ID.pcmux_if_sel),
	.br(pc_new==pc_reg_out_if),
	.cmp(cmp_out),
	.pc((pc_reg_out_id+4)==pc_reg_out_if),
	.predict_result(PHT_rdata[1]),
	.BTB_found(BTB_found),
	.flush(flush),
	.out(ID_PC_sel)
);
/****************  ID/EX latch*********************/

register #(.width(1)) BTB_counter_ID_latch
(
    .clk,
    .load(ID_EX_load),
    .in(BTB_found_ID),
    .out(BTB_counter_ID)
);
register #(.width(1)) flush_counter_EX_latch
(
    .clk,
    .load(ID_EX_load),
    .in(flush_counter),
    .out(flush_counter_EX)
);

register #(.width(1)) predictor_a_latch
(
    .clk,
    .load(ID_EX_load),
    .in(PHT_rdata_a_temp==cmp_out),
    .out(predictor_a_hit)
);

register #(.width(1)) predictor_b_latch
(
    .clk,
    .load(ID_EX_load),
    .in(PHT_rdata_b_temp==cmp_out),
    .out(predictor_b_hit)
);

register #(.width(32)) pc_latch_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(pc_reg_out_id),
    .out(pc_reg_out_ex)
);

register #(.width($bits(EX_struct))) EX_struct_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(EX_struct_ID),
    .out(EX_struct_EX)
);
register #(.width($bits(MEM_struct))) MEM_struct_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(MEM_struct_ID),
    .out(MEM_struct_EX)
);
register #(.width($bits(WB_struct))) WB_struct_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(WB_struct_ID),
    .out(WB_struct_EX)
);
register #(.width(32)) rs1_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(rs1_out_old),
    .out(rs1_out_EX)
);
register #(.width(32)) rs2_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(rs2_out_old),
    .out(rs2_out_EX)
);
register #(.width(5)) rd_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(rd),
    .out(rd_EX)
);
register #(.width(32)) br_en_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in({31'b0,cmp_out}),
    .out(br_en_ex)
);
/* immediate number registeres*/
register #(.width(32)) b_imm_out_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(b_imm_out),
    .out(b_imm)
);
register #(.width(32)) j_imm_out_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(j_imm_out),
    .out(j_imm)
);
register #(.width(32)) i_imm_out_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(i_imm_out),
    .out(i_imm)
);
register #(.width(32)) u_imm_out_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(u_imm_out),
    .out(u_imm)
);
register #(.width(32)) s_imm_out_ID_EX
(
    .clk,
    .load(ID_EX_load),
    .in(s_imm_out),
    .out(s_imm)
);
/*****************  EX stage *********************/

mux8 alumux
(
	.sel(alumux_sel),
	.a(i_imm),
	.b(u_imm),
	.c(b_imm),
	.d(s_imm),
	.e(j_imm),
	.f(rs2_out_EX),
	.g(32'd0),
	.h(32'd0),
	.out(alumux_out)
);

mux2 alumux_a
(
	.sel(alumux_sel_a),
	.a(rs1_out_EX),
	.b(pc_reg_out_ex),
	.f(alumux_out_a)
);

ex_forward_mod ex_forward_mod
(
	.sel(WB_struct_EX.wbmux_sel),
	.a(alu_out),
	.b(br_en_ex),
	.c(u_imm),
	.d(pc_reg_out_ex+4),
	.f(ex_forward)
);
//TODO change input to forwarding out
alu alu
(
	.aluop(aluop),
   .a(alumux_out_a), 
	.b(alumux_out),
   .f(alu_out)
);

/****************  EX/MEM latch *********************/

//Counter for Branch
counter branch_counter
(
	.clk,
   .load(br_counter_ld),
	.sel(br_counter_sel),
	.out(br_counter)
);
counter mispredict_counter
(
	.clk,
   .load(br_ms_counter_ld),
	.sel(br_ms_counter_sel),
	.out(br_ms_counter)
);
counter I_cache_hit_counter
(
	.clk,
   .load(I_cache_hit_ld),
	.sel(I_cache_hit_sel),
	.out(I_cache_hit)
);

counter D_cache_hit_counter
(
	.clk,
   .load(D_cache_hit_ld),
	.sel(D_cache_hit_sel),
	.out(D_cache_hit)
);
counter l2_cache_hit_counter
(
	.clk,
   .load(l2_cache_hit_ld),
	.sel(l2_cache_hit_sel),
	.out(l2_cache_hit)
);
counter_state I_cache_miss_counter
(
	.clk,
   .load(I_cache_miss_ld),
	.sel(I_cache_miss_sel),
	.cache_resp(resp_a),
	.out(I_cache_miss)
);

counter_state D_cache_miss_counter
(
	.clk,
   .load(D_cache_miss_ld),
	.sel(D_cache_miss_sel),
	.cache_resp(resp_b),
	.out(D_cache_miss)
);
counter_state l2_cache_miss_counter
(
	.clk,
   .load(l2_cache_miss_ld),
	.sel(l2_cache_miss_sel),
	.cache_resp(l2_resp),
	.out(l2_cache_miss)
);

counter miss_stall_counter
(
	.clk,
   .load(stall_counter_ld),
	.sel(stall_counter_sel),
	.out(stall_counter)
);

counter predictor_a_counter
(
	.clk,
   .load(predictor_a_ld),
	.sel(predictor_a_sel),
	.out(predictor_a)
);
counter predictor_b_counter
(
	.clk,
   .load(predictor_b_ld),
	.sel(predictor_b_sel),
	.out(predictor_b)
);
register #(.width(32)) pc_latch_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(pc_reg_out_ex),
    .out(pc_reg_out_mem)
);
register #(.width($bits(MEM_struct))) MEM_struct_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(MEM_struct_EX),
    .out(MEM_struct_MEM)
);
register #(.width($bits(WB_struct))) WB_struct_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(WB_struct_EX),
    .out(WB_struct_MEM)
);
register #(.width(32)) alu_out_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(alu_out),
    .out(alu_out_mem)
);
register #(.width(32)) mem_data_out_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(rs2_out_EX),
    .out(wdata_b)
);
register #(.width(32)) br_en_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(br_en_ex),
    .out(br_en_mem)
);
register #(.width(5)) rd_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(rd_EX),
    .out(rd_MEM)
);
register #(.width(32)) u_imm_out_EX_MEM
(
    .clk,
    .load(EX_MEM_load),
    .in(u_imm),
    .out(u_imm_mem)
);

register #(.width(32)) EX_MEM_forwarding
(
    .clk,
    .load(EX_MEM_load),
    .in(ex_forward),
    .out(ex_forward_out)
);
/******************** MEM stage ***********************/



mem_forward_mod mem_forward_mod
(
	.sel(WB_struct_MEM.wbmux_sel),
	.old(ex_forward_out),
	.mem(mem_data_mask_wb_pseudo),
	.out(mem_forward)
);

counter_out_module counter_out_module
(
	.origin(rdata_b),
	.address(alu_out_mem),
	.branch(br_counter),
	.mispredict(br_ms_counter),
	.I_cache_hit(I_cache_hit),
	.I_cache_miss(I_cache_miss),
	.D_cache_hit(D_cache_hit),
	.D_cache_miss(D_cache_miss),
	.l2_cache_hit(l2_cache_hit),
	.l2_cache_miss(l2_cache_miss),
	.stall_counter(stall_counter),
	.out(rdata)
);


mem_data_mask mem_data_mask_pse
(
	.in(rdata_b),
	.sel(mask_sel),
	.out(mem_data_mask_wb_pseudo)
);

mem_data_mask mem_data_mask
(
	.in(rdata),
	.sel(mask_sel),
	.out(mem_data_mask_wb)
);

/****************  MEM/WB latch *********************/
register #(.width(32)) pc_latch_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(pc_reg_out_mem),
    .out(pc_reg_out_wb)
);
register #(.width($bits(WB_struct))) WB_struct_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(WB_struct_MEM),
    .out(WB_struct_WB)
);
register #(.width(32)) alu_out_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(alu_out_mem),
    .out(alu_out_wb)
);
register #(.width(32)) mem_data_out_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(mem_data_mask_wb),
    .out(mem_rdata_wb)
);
register #(.width(32)) br_en_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(br_en_mem),
    .out(br_en_wb)
);
register #(.width(5)) rd_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(rd_MEM),
    .out(rd_WB)
);
register #(.width(32)) u_imm_out_MEM_WB
(
    .clk,
    .load(MEM_WB_load),
    .in(u_imm_mem),
    .out(u_imm_wb)
);
/******************** WB stage ***********************/

mux8 wbmux
(
	.sel(wbmux_sel),
	.a(alu_out_wb),
	.b(br_en_wb),
	.c(u_imm_wb),
	.d(mem_rdata_wb),
	.e(pc_reg_out_wb+4),
	.f(32'd0),
	.g(32'd0),
	.h(32'd0),
	.out(reg_datain)
);
endmodule
