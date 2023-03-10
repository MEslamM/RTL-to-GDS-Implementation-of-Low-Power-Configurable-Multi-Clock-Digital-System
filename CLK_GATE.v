/////////////////////////////////////////////////////////////
/////////////////////// Clock Gating ////////////////////////
/////////////////////////////////////////////////////////////

module CLK_GATE (
input      CLK_EN,
input      CLK,
output     GATED_CLK
);

/////////////////////////////////////////////////////////////
/////////////////////// METHOD 1 ////////////////////////
/////////////////////////////////////////////////////////////

//internal connections
reg     Latch_Out ;


//latch
always @(CLK or CLK_EN)
 begin
  if(!CLK)
   begin
    Latch_Out <= CLK_EN ;
   end
 end
 
 
// AND
assign  GATED_CLK = CLK && Latch_Out ;

/////////////////////////////////////////////////////////////
/////////////////////// METHOD 2 ////////////////////////
/////////////////////////////////////////////////////////////

//ICG cell
/*
TLATNCAX12M U0_TLATNCAX12M (
.E(CLK_EN),
.CK(CLK),
.ECK(GATED_CLK)
);
*/

endmodule