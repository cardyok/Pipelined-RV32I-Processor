module BTB #(parameter width = 5)
(
    input clk,
    input load,
    input [31:0] rindex,
    input [31:0] windex,
    input [31:0] in,
    input [31:0] miss_in,
	 input miss,
	 output logic hit,
	 output logic [31:0] dest
);
logic [31:0] data [2**width][4] /* synthesis ramstyle = "logic" */;
logic [29-width:0] tag [2**width][4] /* synthesis ramstyle = "logic" */;
logic [2:0] lru[2**width];
logic [1:0] choice[2**width];
logic [2:0] next_lru,next_lru_w;
assign hit = (tag[rindex[1+width:2]][0]==rindex[31:2+width])||(tag[rindex[1+width:2]][1]==rindex[31:2+width])||(tag[rindex[1+width:2]][2]==rindex[31:2+width])||(tag[rindex[1+width:2]][3]==rindex[31:2+width]);
/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for (int i = 0; i < 2**width; i++)
    begin
		lru[i] = 0;
		for(int j = 0; j < 4; j++)
		begin
			data[i][j] = 32'hffffffff;
			tag[i][j] = 25'b1111101111111111111111111;
		end
    end
end

always_ff @(posedge clk)
begin
    if (load)
    begin
        data[windex[1+width:2]][choice[windex[1+width:2]]] <= in;
		  tag[windex[1+width:2]][choice[windex[1+width:2]]] <= windex[31:2+width];	
		  lru[windex[1+width:2]] <= next_lru_w;
    end
	 else if(miss)
	 begin
        data[windex[1+width:2]][choice[windex[1+width:2]]] <= miss_in;
		  tag[windex[1+width:2]][choice[windex[1+width:2]]] <= windex[31:2+width];	
		  lru[windex[1+width:2]] <= next_lru_w;
	 end
	 else
	 begin
		lru[rindex[1+width:2]] <= next_lru;
	 end
end

always_comb
begin
		for(int k = 0 ; k < 2**width; k++)
			choice[k] = { (!lru[windex[1+width:2]][2]) , (!lru[windex[1+width:2]][(lru[windex[1+width:2]][2])] )};
		
		next_lru = lru[rindex[1+width:2]];
		case(choice[windex[1+width:2]])
			2'b00:next_lru_w = {1'b0,1'b0,lru[windex[1+width:2]][0]};
			2'b01:next_lru_w = {1'b0,1'b1,lru[windex[1+width:2]][0]};
			2'b10:next_lru_w = {1'b1,lru[windex[1+width:2]][1],1'b0};
			2'b11:next_lru_w = {1'b1,lru[windex[1+width:2]][1],1'b1};
		endcase
		if(tag[rindex[1+width:2]][0]==rindex[31:2+width])
		begin
			next_lru = {1'b0, 1'b0,lru[rindex[1+width:2]][0]};
			dest = data[rindex[1+width:2]][0];
		end
		else if(tag[rindex[1+width:2]][1]==rindex[31:2+width])
		begin
			next_lru = {1'b0, 1'b1,lru[rindex[1+width:2]][0]};
			dest = data[rindex[1+width:2]][1];
		end
		else if(tag[rindex[1+width:2]][2]==rindex[31:2+width])
		begin
			next_lru = {1'b1,lru[rindex[1+width:2]][1], 1'b0};
			dest = data[rindex[1+width:2]][2];
		end
		else if(tag[rindex[1+width:2]][3]==rindex[31:2+width])
		begin
			next_lru = {1'b1,lru[rindex[1+width:2]][1], 1'b1};
			dest = data[rindex[1+width:2]][3];
		end
		else
		begin
			dest =32'hffffffff;
		end
end

endmodule : BTB
