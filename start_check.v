module start_check (
input 		wire 			CLK,
input 		wire 			RST,
input 		wire 			strt_chk_en,
input 		wire 			sampled_bit,
output		reg 			strt_glitch
);

always @(posedge CLK or negedge RST) 
begin

	if (!RST) begin
		strt_glitch <= 1'b0 ;	
	end

	else if (strt_chk_en) begin
		if (sampled_bit == 1'b0) begin //no glitch
			strt_glitch <= 1'b0 ;	
		end

		else begin //glitch
			strt_glitch <= 1'b1 ;
		end
	end

end

endmodule