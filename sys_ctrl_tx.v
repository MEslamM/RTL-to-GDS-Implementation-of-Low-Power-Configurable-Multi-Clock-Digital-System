module SYS_CTRL_Tx # ( parameter DATA_WIDTH = 8 , ALU_WIDTH = 2*DATA_WIDTH)
(
 input	wire												CLK,
 input	wire												RST,
 input	wire		[DATA_WIDTH-1:0]		RdDATA,
 input	wire												RdDATA_VLD,
 input	wire												OUT_Valid,
 input	wire    [ALU_WIDTH-1:0]     ALU_OUT, 
 input	wire                   			Busy,
 input  wire												enable_pulse,
 output  reg    [DATA_WIDTH-1:0]    TX_P_DATA,
 output  reg                   			TX_D_VLD
);

// gray state encoding
localparam  [2:0]      IDLE_OUT1     		= 3'b000 ,
											 data_sync_alu1   = 3'b001 ,
											 data_sync_alu2		= 3'b011 ,
          			   		 OUT2     				= 3'b100 ,
          			   		 data_sync_mem		= 3'b101 ;


reg   [2:0]      				current_state , next_state ;


reg 	[ALU_WIDTH-1:0]		saved_ALU_OUT ;			


//state transiton 
always @ (posedge CLK or negedge RST) begin
  if(!RST) begin
    current_state <= IDLE_OUT1 ;
   end

  else begin
    current_state <= next_state ;
   end
 end


// next state logic and output logic
always @ (*) begin
TX_D_VLD = 1'b0 ;
TX_P_DATA = 8'b0000_0000 ;

  case(current_state)
	  IDLE_OUT1: begin
 						if (OUT_Valid && RdDATA_VLD == 1'b0) begin
 							TX_P_DATA = ALU_OUT[7:0] ;
		  				TX_D_VLD = 1'b1 ;
 							next_state = data_sync_alu1 ;
 						end

 						else if(OUT_Valid == 1'b0 && RdDATA_VLD) begin
 							TX_P_DATA = RdDATA ;
		  				TX_D_VLD = 1'b1 ;
 							next_state = data_sync_mem ;
 						end

 						else begin
 							next_state = IDLE_OUT1 ;
 						end
	        end

	  OUT2: begin
		  			if (Busy == 1'b0) begin
		  				TX_P_DATA = saved_ALU_OUT[15:8] ; //change ALU_OUT to saved_alu_out
		  				TX_D_VLD = 1'b1 ;
		  				next_state = data_sync_alu2 ;
		  			end

		  			else begin
		  				next_state = OUT2 ;
		  			end
	        end

data_sync_alu1: begin
	  					if (~enable_pulse) begin
	  							TX_P_DATA = saved_ALU_OUT[7:0] ;
		  						TX_D_VLD = 1'b1 ;
 									next_state = data_sync_alu1 ; 
	  						end

	  						else begin
	  						next_state = OUT2 ; 	
	  						end
	        end

data_sync_alu2: begin
	  					if (enable_pulse) begin
	  							TX_P_DATA = saved_ALU_OUT[15:8] ;
		  						TX_D_VLD = 1'b1 ;
 									next_state = data_sync_alu2 ; 
	  						end

	  						else begin
	  						next_state = IDLE_OUT1 ; 	
	  						end
	        end

data_sync_mem:begin
	  						if (~enable_pulse) begin
	  							TX_P_DATA = RdDATA ;
		  						TX_D_VLD = 1'b1 ;
 									next_state = data_sync_mem ; 
	  						end

	  						else begin
	  						next_state = IDLE_OUT1 ; 	
	  						end
	  					end

	  default: begin
				 				next_state = IDLE_OUT1 ; 
	           end
	endcase  
 end


//save ALU_OUT
always @(posedge CLK or negedge RST) begin 
	if (~RST) begin
		saved_ALU_OUT <= 'b0 ;
	end
	else if(current_state == IDLE_OUT1) begin 
		saved_ALU_OUT <= ALU_OUT ;
	end
end



endmodule