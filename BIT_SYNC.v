module BIT_SYNC (
input    wire   CLK,
input    wire   RST,
input    wire   ASYNC,
output   wire   SYNC
);


reg     meta_flop  ; 
reg     sync_flop  ;
					 
always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    meta_flop <= 1'b0 ;
    sync_flop <= 1'b0 ;	
   end

  else begin
    meta_flop <= ASYNC;
    sync_flop <= meta_flop ;
   end  
 end
 

assign  SYNC = sync_flop ;

endmodule