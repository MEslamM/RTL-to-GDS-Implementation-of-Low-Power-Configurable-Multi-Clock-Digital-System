module data_sampling (
input 		wire 			CLK,
input 		wire 			RST,
input 		wire 			data_samp_en,
input 		wire 			RX_IN,
input		wire	[4:0]	edge_cnt,
input 		wire 	[4:0]	Prescale,
output		reg 			sampled_bit,
output		reg				Fill
);

reg sample1 ;
reg sample2 ;
reg sample3 ;

reg check_probabilty ;


///////////// sampling ////////////////
always @(posedge CLK or negedge RST) 
 begin

	if (!RST) begin
		sampled_bit <= 'b0 ;		
	end

	else if (data_samp_en) begin
		if (edge_cnt == Prescale/2) begin
			sample1 <= RX_IN ;
		end

		else if (edge_cnt == (Prescale/2 + 1) ) begin
			sample2 <= RX_IN ;
		end

		else if (edge_cnt == (Prescale/2 + 2) ) begin
			sample3 <= RX_IN ;
			check_probabilty <= 1'b1 ;
		end

	end

 end


//////////////// output ////////////////
always @(posedge CLK or negedge RST) 
 begin

 	if (!RST) begin
		sampled_bit <= 'b0 ;		
 	end

 	else if (data_samp_en && check_probabilty && edge_cnt == Prescale) begin
 		
 		check_probabilty <= 1'b0 ;
 		Fill <= 1'b1 ;

 		case({sample1,sample2,sample3})
 			3'b000:begin
 				sampled_bit <= 1'b0 ;
 			end
			3'b001:begin
				sampled_bit <= 1'b0 ;
			end
			3'b010:begin
				sampled_bit <= 1'b0 ;
			end
			3'b011:begin
				sampled_bit <= 1'b1 ;
			end
			3'b100:begin
				sampled_bit <= 1'b0 ;
			end
			3'b101:begin
				sampled_bit <= 1'b1 ;
			end
			3'b110:begin
				sampled_bit <= 1'b1 ;
			end
			3'b111:begin
				sampled_bit <= 1'b1 ;
			end
			default:begin
				sampled_bit <= 1'b0 ;
			end
 		endcase

 	end

 	else begin //condition added just to see sampled bit on waveform doesn't affect functionality
 		sampled_bit <= 1'b0 ;
 		Fill <= 1'b0 ;
 	end

 end



endmodule