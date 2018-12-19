module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic resp;
logic read;
logic write;
logic [31:0] address;
logic [255:0] wdata;
logic [255:0] rdata;


/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;


mp3 dut
(
    .*
);

physical_memory memory
(
   .*
);


endmodule : mp3_tb
