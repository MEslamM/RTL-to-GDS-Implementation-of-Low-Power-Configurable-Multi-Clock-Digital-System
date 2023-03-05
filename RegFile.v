module RegFile #(parameter WIDTH = 8, DEPTH = 16, ADDR = 4 )
(
input    wire                CLK,
input    wire                RST,
input    wire                WrEn,
input    wire                RdEn,
input    wire                regfile_operation_flag,
input    wire   [ADDR-1:0]   Address,
input    wire   [WIDTH-1:0]  WrData,
output   reg    [WIDTH-1:0]  RdData,
output   reg                 RdData_VLD,
output   wire   [WIDTH-1:0]  REG0, //OP_A
output   wire   [WIDTH-1:0]  REG1, //OP_B
output   wire   [WIDTH-1:0]  REG2, //UART_Config
output   wire   [WIDTH-1:0]  REG3  //Div_ratio
);


integer i ;

reg [WIDTH-1:0] mem [DEPTH-1:0] ;  


always @(posedge CLK or negedge RST) begin

  if(!RST) begin
    RdData_VLD <= 1'b0 ;
    RdData     <= 1'b0 ;
    for (i=0 ; i < DEPTH ; i = i +1) begin  //for UART_Config & Div_ratio (system configuration)
		 if(i==2) begin
        mem[i] <= 'b001000_01 ;  //parity enable=1 //parity type=0(even) //prescale=8
		 end
     else if (i==3) begin
        mem[i] <= 'b0000_1000 ;  //divided ratio=8
     end
     else begin
        mem[i] <= 'b0 ;
     end		 
    end
  end

  else if (WrEn && !RdEn && regfile_operation_flag) begin   // Register Write Operation
    mem[Address] <= WrData ;
  end

  else if (RdEn && !WrEn && regfile_operation_flag) begin  // Register Read Operation    
    RdData <= mem[Address] ;
    RdData_VLD <= 1'b1 ;
  end 

  else begin
    RdData_VLD <= 1'b0 ;
  end	

 end



assign REG0 = mem[0] ; //OP_A
assign REG1 = mem[1] ; //OP_B
assign REG2 = mem[2] ; //UART_Config
assign REG3 = mem[3] ; //Div_ratio

endmodule