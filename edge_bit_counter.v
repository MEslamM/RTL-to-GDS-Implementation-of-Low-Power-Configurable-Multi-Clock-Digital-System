module edge_bit_counter (
input 		wire 			CLK,
input 		wire 			RST,
input 		wire 			enable,
input 		wire 	[4:0]	Prescale,
input		wire			data_valid,
output		reg		[3:0]	bit_cnt,
output		reg		[4:0]	edge_cnt
);


always @(posedge CLK or negedge RST) 
 begin

	if (!RST || data_valid) begin
		bit_cnt <= 'b0 ;
		edge_cnt <= 'b0 ;
	end

	else if (enable) begin
		if (edge_cnt == Prescale) begin
			bit_cnt <= bit_cnt + 1'b1 ;
			edge_cnt <= 4'b0001 ;
		end

		else begin
			edge_cnt <= edge_cnt + 1'b1 ;	
		end
	end

 end

endmodule