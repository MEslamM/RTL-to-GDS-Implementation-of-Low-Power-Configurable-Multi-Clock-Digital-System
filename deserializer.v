module deserializer (
input 		wire 				CLK,
input 		wire 				RST,
input 		wire 				deser_en,
input 		wire 				sampled_bit,
input		wire				Fill,
input		wire				data_valid,
output		reg 	[7:0]		P_DATA
);

reg [7:0] P_DATA_C ;
integer i ;

///////////// operation /////////////
always @(posedge CLK or negedge RST) 
begin

	if (!RST || data_valid) begin
		P_DATA_C <= 'b0 ;
		i <= 'b0 ;
	end

	else if (deser_en && i < 8 && Fill == 1'b1) begin
		P_DATA_C[i] <= sampled_bit ;
		i = i + 1 ;
	end

end


///////////// regestier output /////////////
always @(posedge CLK or negedge RST) 
begin

	if (!RST) begin
		P_DATA <= 'b0 ;	
	end

	else begin
		P_DATA <= P_DATA_C ;
	end

end
endmodule