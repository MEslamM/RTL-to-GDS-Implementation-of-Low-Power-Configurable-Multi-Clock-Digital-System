module DATA_SYNC # ( parameter bus_width = 8 )
(
input    wire                      CLK,
input    wire                      RST,
input    wire     [bus_width-1:0]  unsync_bus,
input    wire                      bus_enable,
output   reg      [bus_width-1:0]  sync_bus,
output   reg                       enable_pulse
);


reg                     meta_flop ;
reg                     sync_flop ;
reg                     enable_flop ;
					 
wire                    enable_pulse_c ;
wire  [bus_width-1:0]   sync_bus_c ;
					 

//////////// double FF synchronizer ////////////
always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    meta_flop <= 1'b0 ;
    sync_flop <= 1'b0 ;	
   end

  else begin
    meta_flop <= bus_enable;
    sync_flop <= meta_flop ;
   end  
 end
 


//////////// pulse generator ////////////
always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    enable_flop <= 1'b0 ;	
   end

  else begin
    enable_flop <= sync_flop ;
   end  
 end

assign enable_pulse_c = sync_flop && !enable_flop ;



//////////// MUXING ////////////
assign sync_bus_c =  enable_pulse_c ? unsync_bus : sync_bus ;  



//////////// sync_bus FF ////////////
always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    sync_bus <= 'b0 ;	
   end

  else begin
    sync_bus <= sync_bus_c ;
   end  
 end
 
//////////// enable_pulse FF ////////////
always @(posedge CLK or negedge RST) begin
  if(!RST) begin
    enable_pulse <= 1'b0 ;	
   end

  else begin
    enable_pulse <= enable_pulse_c ;
   end  
 end
 

endmodule