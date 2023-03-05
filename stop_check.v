module stop_check (
input 		wire 			CLK,
input 		wire 			RST,
input 		wire 			stp_chk_en,
input 		wire 			sampled_bit,
output		reg 			stp_err
);

always @(posedge CLK or negedge RST) 
begin

	if (!RST) begin
		stp_err <= 1'b0 ;	
	end

	else if (stp_chk_en) begin
		if (sampled_bit == 1'b1) begin //no error
			stp_err <= 1'b0 ;	
		end

		else begin //error
			stp_err <= 1'b1 ;
		end
	end

end

endmodule