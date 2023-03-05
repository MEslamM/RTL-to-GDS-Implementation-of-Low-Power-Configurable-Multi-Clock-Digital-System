module UART_RX_FSM (
input 		wire 				CLK,
input 		wire 				RST,
input 		wire 				PAR_EN,
input 		wire 				RX_IN,
input		wire	[3:0]		bit_cnt,
input 		wire 				par_err,
input 		wire 				strt_glitch,
input 		wire 				stp_err,
output		reg 				data_samp_en,
output		reg 				enable,
output		reg 				deser_en,
output		reg 				data_valid,
output		reg 				par_chk_en,
output		reg 				strt_chk_en,
output		reg 				stp_chk_en
);

///////////// states /////////////
localparam 	[1:0]		IDLE = 2'b00 ;
localparam 	[1:0]		edge_bit_cnt_data_sample = 2'b01 ;
localparam 	[1:0]		finish = 2'b10 ;


reg         [1:0]      current_state , next_state ;
reg                    data_valid_c ;

integer cnt_parity ; 
	

///////////// state transiton /////////////
always @ (posedge CLK or negedge RST)
 begin

  if(!RST)
   begin
    current_state <= IDLE ;
   end

  else
   begin
    current_state <= next_state ;
   end

 end


///////////// next state logic , output logic /////////////
always @(*)
 begin

 	enable = 1'b0 ;
 	data_samp_en = 1'b0 ;
 	par_chk_en = 1'b0 ;
 	strt_chk_en = 1'b0 ;
 	stp_chk_en = 1'b0 ;
 	deser_en = 1'b0 ;
 	data_valid_c = 1'b0 ;

	case(current_state)
		IDLE:begin
			if (RX_IN == 1'b0) begin //TO edge_bit_counter AND data_sampling blocks
				enable = 1'b1 ;
				data_samp_en = 1'b1 ;
				next_state = edge_bit_cnt_data_sample ;
				cnt_parity = 1'b0 ; //for parity bit later on
			end

			else begin
				next_state = current_state ;
			end
		end

		edge_bit_cnt_data_sample:begin
			if (bit_cnt == 4'b0001) begin //FOR start_check
				strt_chk_en = 1'b1 ;
				enable = 1'b1 ;
				data_samp_en = 1'b1 ;
				next_state = current_state ;
			end

			else if (bit_cnt >= 4'b0010 && bit_cnt <= 4'b1001) begin //FOR deserilaizer
				deser_en = 1'b1 ;
				enable = 1'b1 ;
				data_samp_en = 1'b1 ;
				next_state = current_state ;
			end

			else if(bit_cnt == 4'b1010) begin //FOR parity_check or stop_check(without parity)
				if (PAR_EN == 1'b1 && cnt_parity == 'b00) begin //FOR parity_check
					par_chk_en = 1'b1 ;
					enable = 1'b1 ;
					data_samp_en = 1'b1 ;
					cnt_parity = ~cnt_parity  ;
					next_state = current_state ;
				end

				else if(PAR_EN == 1'b0) begin //FOR stop_check without parity
					stp_chk_en = 1'b1 ;
					enable = 1'b1 ;
					data_samp_en = 1'b1 ;
					next_state = finish ;
				end

				else begin
					enable = 1'b1 ;
					data_samp_en = 1'b1 ;
					next_state = current_state ;
					par_chk_en = 1'b0 ;
				end
			end

			else if(bit_cnt == 4'b1011) begin //FOR stop_check with parity
				stp_chk_en = 1'b1 ;
				enable = 1'b1 ;
				data_samp_en = 1'b1 ;
				next_state = finish ;
			end

			else if(bit_cnt > 4'b1011) begin //FOR what happen after i finished
				next_state = IDLE ;
			end

			else begin //TO stay in this state untill bit_cnt = 1 to start cycle
				enable = 1'b1 ;
				data_samp_en = 1'b1 ;
				next_state = current_state ;
			end
		end

		finish:begin
			/*if (par_err == 1'b0 && stp_err == 1'b0 && strt_glitch == 1'b0) begin
				data_valid_c = 1'b1 ;
				next_state = IDLE ;
			end

			else begin
				data_valid_c = 1'b0 ;
				next_state = IDLE ;
			end*/
			data_valid_c = 1'b1 ;
			next_state = IDLE ;
		end

		default:begin
			next_state = IDLE ;
		end
	endcase

 end

///////////// register output /////////////
always @ (posedge CLK or negedge RST)
 begin

  if(!RST)
   begin
    data_valid <= 1'b0 ;
   end
   
  else
   begin
    data_valid <= data_valid_c ;
   end

 end

endmodule