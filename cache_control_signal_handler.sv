module cache_control_signal_handler
(
	input logic hit1, hit2, valid1, valid2, dirty1, dirty2, lru,
	output logic update_way, hit, replace, dirty 		//hit, replace, dirty giving to control unit
);

always_comb begin
	//assign hit 
	if ((valid1==1&&hit1==1) || (valid2==1&&hit2==1)) 
		hit = 1;
	else hit = 0;
	
	//assign the rest control signals
	//if hit 
	if (hit==1) begin
		update_way=0; ///actually don't care in this case
		replace=0;
		dirty=0;
	end
	//if not hit
	else begin 
		if (valid1 == 0) begin
			update_way = 0;
			replace = 0;
			dirty = 0;
		end
		else if (valid2 == 0) begin
			update_way = 1;
			replace = 0;
			dirty = 0;
		end
		else begin
			update_way = lru;
			replace = 1;
			if (lru == 0 && dirty1 == 1) 
				dirty = 1;
			else if (lru == 1 && dirty2 == 1)
				dirty = 1;
			else
				dirty = 0;
		end
	end
end
endmodule: cache_control_signal_handler
