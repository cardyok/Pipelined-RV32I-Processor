module counter
(
	input clk,
	input sel,
   input load,
	output logic [31:0] out
);

logic [31:0] data;

initial
begin
    data = 1'b0;
end

always_ff @(posedge clk)
begin
    if (load)
    begin
		if(!sel)
			data = data+1;
		else
			data = 32'h0000;
    end
end

always_comb
begin
    out = data;
end

endmodule : counter


