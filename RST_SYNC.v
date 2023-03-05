module RST_SYNC (
input    wire     RST,
input    wire     CLK,
output   wire     SYNC_RST
);

reg     meta_flop ;
reg     sync_flop ;

always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    meta_flop <= 1'b0 ;
    sync_flop <= 1'b0 ;	
   end

  else begin
    meta_flop <= 1'b1 ;
    sync_flop <= meta_flop ;
   end  
 end
 
 assign  SYNC_RST = sync_flop ;

endmodule