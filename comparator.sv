module comparator #(parameter width = 24)
(
	input [width-1:0] target_tag, curr_tag,
	input logic valid,
	output logic hit
);
always_comb begin
	if (valid==1&&target_tag==curr_tag) begin
		hit=1'b1;
	end
	else begin
		hit=1'b0;
	end
end
endmodule: comparator
