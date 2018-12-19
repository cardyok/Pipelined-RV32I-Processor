module array_we
(
	input logic hit, mem_write, pmem_write, update_way,
	output logic write_enable
);

always_comb begin
	if ((hit==1 && mem_write==1)||(pmem_write==1 && update_way==1))
		write_enable = 1'b1;
	else 
		write_enable = 1'b0;
end
endmodule: array_we