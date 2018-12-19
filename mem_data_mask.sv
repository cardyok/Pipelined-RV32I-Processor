module mem_data_mask 
(
	input logic [31:0] in,
	input logic [2:0] sel,
	output logic [31:0] out
);

always_comb 
begin
	case (sel)
		3'b000: out = in;  //32-bit in and out
		3'b001: out = {{16{in[15]}}, in[15:0]}; //16-bit in and sign extension to 32-bit out
		3'b010: out = {16'd0, in[15:0]}; //16-bit in and zero extension to 32-bit out
		3'b011: out = {{24{in[7]}}, in[7:0]}; //8-bit in and sign extension to 32-bit out
		3'b100: out = {24'd0, in[7:0]}; //8-bit in and zero extension to 32-bit out
		default: out = in;
	endcase 
end
endmodule 
