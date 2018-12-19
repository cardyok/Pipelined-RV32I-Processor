module PHT #(parameter width = 2)
(
    input clk,
    input write,
    input [7:0] rindex,
    input [7:0] windex,
    input [1:0] datain,
    output logic [1:0] dataout
);

logic [1:0] data [255:0] /* synthesis ramstyle = "logic" */;

/* Initialize array */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 2'b01;
    end
end

always_ff @(posedge clk)
begin
    if (write == 1)
    begin
        data[windex] = datain;
    end
end

assign dataout = data[rindex];

endmodule 

