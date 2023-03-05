module SYS_CTRL_Rx # ( parameter DATA_WIDTH = 8 , ADDR = 4)
(
 input	wire												CLK,
 input	wire												RST,
 input	wire		[DATA_WIDTH-1:0]		RX_P_DATA,
 input	wire												RX_D_VLD,
 output  reg                   			WrEn,  
 output  reg                   			RdEn, 
 output  reg    [ADDR-1:0]        	Address, 
 output  reg    [DATA_WIDTH-1:0]  	Wr_D, 
 output  reg                   			Gate_EN,
 output  reg    [3:0]             	ALU_FUN,
 output  reg                   			ALU_EN,
 output  reg												regfile_operation_flag
);


// gray state encoding
localparam  [2:0]      idle_check  = 3'b000 ,
                       addresswr   = 3'b001 ,
                       addressrd   = 3'b010 ,
          			   		 data     	 = 3'b011 ,
          			   		 op_a        = 3'b100 ,
          			   		 op_b        = 3'b101 ,
          			   		 alu_fun     = 3'b110 ,
          			   		 done				 = 3'b111 ;


reg         [2:0]      				current_state , next_state ;
reg 				[ADDR-1:0]				saved_address	;
/*reg 				[DATA_WIDTH-1:0]	saved_operation ;*/


//state transiton 
always @ (posedge CLK or negedge RST) begin
  if(!RST) begin
    current_state <= idle_check ;
   end

  else begin
    current_state <= next_state ;
   end
 end



// next state logic
always @ (*) begin
RdEn = 1'b0 ;
Gate_EN = 1'b0 ;
WrEn = 1'b0 ;
ALU_EN = 1'b0 ;
ALU_FUN = 4'b0000 ;
Address = saved_address ;
Wr_D = 8'b0000_0000 ;
regfile_operation_flag = 1'b0 ;

  case(current_state)
	  idle_check:begin
	  						if (RX_P_DATA == 8'hAA && RX_D_VLD) begin
	  							next_state = addresswr ;
	  						end

	  						else if (RX_P_DATA == 8'hBB && RX_D_VLD) begin
	  							next_state = addressrd ;
	  						end

	  						else if (RX_P_DATA == 8'hCC && RX_D_VLD) begin
									next_state = op_a ;
	  						end

	  						else if (RX_P_DATA == 8'hDD && RX_D_VLD) begin
	  							Gate_EN = 1'b1 ;
	  							next_state = alu_fun ;
	  						end

	  						else begin
	  							next_state = idle_check ;
	  						end
	  					 end

	  addresswr:begin
	  					if (RX_D_VLD) begin
	  						WrEn = 1'b1 ;
	  						Address = saved_address ;
	  						next_state = data ;
	  					end

	  					else begin
	  						next_state = addresswr ;
	  					end
	  				end

		addressrd:begin
	  					if(RX_D_VLD) begin
	  						RdEn = 1'b1 ;
	  						regfile_operation_flag = 1'b1 ;
	  						Address = saved_address ;
	  						next_state = idle_check ;
	  					end

	  					else begin
	  						next_state = addressrd ;
	  					end
	  				end

		data:begin
						if (RX_D_VLD) begin
			  			WrEn = 1'b1 ;
			  			regfile_operation_flag = 1'b1 ;
		  				Wr_D = RX_P_DATA ;
		  				next_state = idle_check ;
						end

						else begin
							next_state = data ;
						end
	      	end
	
	  op_a:begin
	  				if (RX_D_VLD) begin
			  			WrEn = 1'b1 ;
		  				regfile_operation_flag = 1'b1 ;
		  				Address = 4'b0000 ;
	  					Wr_D = RX_P_DATA ;
	  					next_state = op_b ;  					
	  				end

	  				else begin
							next_state = op_a ;
						end
	      	end

	  op_b:begin
	  				if (RX_D_VLD) begin
	  					WrEn = 1'b1 ;
			  			regfile_operation_flag = 1'b1 ;
			  			Gate_EN = 1'b1 ;
			  			Address = 4'b0001 ;
		  				Wr_D = RX_P_DATA ;
		  				next_state = alu_fun ;
	  				end

		  			else begin
							next_state = op_b ;
						end
	       end

	  alu_fun:begin
	  					if (RX_D_VLD) begin
	  						ALU_EN = 1'b1 ;
	  						Gate_EN = 1'b1 ;
	  						ALU_FUN = RX_P_DATA ;
	  						next_state = done ;
	  					end

	  					else begin
							next_state = alu_fun ;
	  					end
	      		end

	  done:begin
	  			next_state = idle_check ;
	       end

	  default:begin
	  					next_state = idle_check ;	           
						end
	endcase
 end


//save address in case of write_mem
always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		saved_address <= 'b0 ;
	end
	else begin 
		if(current_state == addresswr)begin
		saved_address <= RX_P_DATA[3:0] ;
		end
	end
end

/*
//save operation to determine write_mem OR read_mem
always @(posedge CLK or negedge RST) begin 
	if (~RST) begin
		saved_operation <= 'b0 ;
	end
	else if(current_state == idle_check && RX_D_VLD) begin 
		saved_operation <= RX_P_DATA ;
	end
end
*/

endmodule