module global_history
(
	input clk,
	input logic load_GHT,
	input logic in,
	output logic [9:0] out
);

logic [9:0] data;

initial
begin
    data = 10'b0;
end

always_ff @(posedge clk)
begin
    if (load_GHT)
    begin
        data = {in, data[9:1]};
    end
end

always_comb
begin
    out = data;
	 //prev_data = data;
end

endmodule 
