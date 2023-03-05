module ClkDiv #(parameter RATIO_WD = 4)
(
 input      wire                        i_ref_clk ,
 input      wire                        i_rst ,                 
 input      wire                        i_clk_en,               
 input      wire    [RATIO_WD-1 : 0]    i_div_ratio,            
 output     wire                        o_div_clk               
);

wire                        clk_en;
reg     [RATIO_WD-2 : 0]    count ;
reg                         div_clk ;

reg                         odd_edge_tog ;
wire    [RATIO_WD-2 :0]     edge_flip_half ;  
wire    [RATIO_WD-2 :0]     edge_flip_full ;
wire                        odd;                                                                       
 
wire                        one_div_ratio ;
wire                        zero_div_ratio;




always @(posedge i_ref_clk or negedge i_rst)
 begin

    if(!i_rst) begin
        count <= 0 ;
    	div_clk <= 0 ;	
        odd_edge_tog <= 1 ;
    end

    else if(clk_en) begin
        if(!odd && (count == edge_flip_half))              // even edge flip condition 
           begin
            count <= 0 ;
            div_clk <= ~div_clk ;		
           end
        else if((odd && (count == edge_flip_half) && odd_edge_tog ) || (odd && (count == edge_flip_full) && !odd_edge_tog ))  // odd edge flip condition
           begin  
            count <= 0 ;
            div_clk <= ~div_clk ;
            odd_edge_tog <= ~odd_edge_tog ;                      
           end
        else
         count <= count + 1'b1 ;
   end

 end



assign odd = i_div_ratio[0] ;
assign edge_flip_half = ((i_div_ratio >> 1) - 1 ) ;
assign edge_flip_full = (i_div_ratio >> 1) ;

assign zero_div_ratio = ~|i_div_ratio ;                               // check if ratio equals to 0 
assign one_div_ratio  = (i_div_ratio == 1'b1) ;                       // check if ratio equals to 1 
assign clk_en = i_clk_en & !one_div_ratio & !zero_div_ratio;          // Enable if div_ratio not equal to 0 or 1 and block is enabled

assign o_div_clk = clk_en ? div_clk : i_ref_clk ;                     // clk divider(disabled):generated clock is the reference clock


endmodule