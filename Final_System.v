module Final_system # (parameter DATA_WIDTH = 8 ,  RF_ADDR = 4) 
(
 input   wire                          RST_N,
 input   wire                          UART_CLK,
 input   wire                          REF_CLK,
 input   wire                          UART_RX_IN,
 output  wire                          UART_TX_O,
 output  wire                          parity_error,
 output  wire                          framing_error
);

//RST_Sync
wire                                   SYNC_UART_RST;
wire                                   SYNC_REF_RST;
/////////////////////////////////////////////////////////////////////

//REG-ALU-UART
wire      [DATA_WIDTH-1:0]             Operand_A;
wire      [DATA_WIDTH-1:0]			   Operand_B;
wire      [DATA_WIDTH-1:0]			   UART_Config;
wire      [DATA_WIDTH-1:0]			   DIV_RATIO;
/////////////////////////////////////////////////////////////////////
									   
//UART_RX-Data_Sync									   
wire      [DATA_WIDTH-1:0]             UART_RX_D_OUT;
wire         						   UART_RX_V_OUT;
wire      [DATA_WIDTH-1:0]			   UART_RX_D_SYNC;
wire                                   UART_RX_V_SYNC;
/////////////////////////////////////////////////////////////////////

//UART_TX-Data_Sync
wire      [DATA_WIDTH-1:0]             UART_TX_D_IN;
wire        						   UART_TX_V_IN;
wire      [DATA_WIDTH-1:0]             UART_TX_D_SYNC;
wire        						   UART_TX_V_SYNC;

wire                                   UART_TX_Busy;	
wire                                   UART_TX_Busy_SYNC;

wire					               UART_TX_CLK;
/////////////////////////////////////////////////////////////////////
									   
//REG-SYS_CTRL
wire                                   RF_WrEn;
wire                                   RF_RdEn;
wire      [RF_ADDR-1:0]                RF_Address;
wire      [DATA_WIDTH-1:0]             RF_WrData;
wire      [DATA_WIDTH-1:0]             RF_RdData;
wire                                   RF_RdData_VLD;									   

wire                                   CLKG_EN;
wire                                   ALU_EN;
wire      [3:0]                        ALU_FUN; 
wire      [DATA_WIDTH*2-1:0]           ALU_OUT;
wire                                   ALU_OUT_VLD; 
									   
wire                                   ALU_CLK ;

wire								   regfile_operation_flag;								   
/////////////////////////////////////////////////////////////////////
								   
///********************************************************///
//////////////////// Reset synchronizers /////////////////////
///********************************************************///

RST_SYNC U0_RST_SYNC_2 (
.RST(RST_N),
.CLK(UART_CLK),
.SYNC_RST(SYNC_UART_RST)
);

RST_SYNC U1_RST_SYNC_1 (
.RST(RST_N),
.CLK(REF_CLK),
.SYNC_RST(SYNC_REF_RST)
);

///********************************************************///
////////////////////// Data Synchronizer /////////////////////
///********************************************************///

DATA_SYNC U0_ref_sync (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.unsync_bus(UART_RX_D_OUT),
.bus_enable(UART_RX_V_OUT),
.sync_bus(UART_RX_D_SYNC),
.enable_pulse(UART_RX_V_SYNC)
);

DATA_SYNC U1_uart_sync (
.CLK(UART_TX_CLK),
.RST(SYNC_UART_RST),
.unsync_bus(UART_TX_D_IN),
.bus_enable(UART_TX_V_IN),
.sync_bus(UART_TX_D_SYNC),
.enable_pulse(UART_TX_V_SYNC)
);

///********************************************************///
////////////////////// Bit Synchronizer /////////////////////
///********************************************************///

BIT_SYNC  U0_bit_sync (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.ASYNC(UART_TX_Busy),
.SYNC(UART_TX_Busy_SYNC)
);


///********************************************************///
//////////////////////// Clock Divider ///////////////////////
///********************************************************///

ClkDiv U0_ClkDiv (
.i_ref_clk(UART_CLK),             
.i_rst(SYNC_UART_RST),                 
.i_clk_en(1'b1),               
.i_div_ratio(DIV_RATIO[3:0]),           
.o_div_clk(UART_TX_CLK)             
);


///********************************************************///
/////////////////////////// UART /////////////////////////////
///********************************************************///

UART U0_UART (
.RST(SYNC_UART_RST),
.TX_CLK(UART_TX_CLK),
.RX_CLK(UART_CLK),
.RX_IN_S(UART_RX_IN),
.RX_OUT_P(UART_RX_D_OUT),                      
.RX_OUT_V(UART_RX_V_OUT),                      
.TX_IN_P(UART_TX_D_SYNC), 
.TX_IN_V(UART_TX_V_SYNC), 
.TX_OUT_S(UART_TX_O),
.TX_OUT_V(UART_TX_Busy),
.Prescale(UART_Config[6:2]),
.parity_enable(UART_Config[0]),
.parity_type(UART_Config[1]),
.parity_error(parity_error),
.stop_error(framing_error)                  
);


///********************************************************///
//////////////////// System Controller ///////////////////////
///********************************************************///

SYS_CTRL U0_SYS_CTRL (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.RX_P_DATA(UART_RX_D_SYNC), 
.RX_D_VLD(UART_RX_V_SYNC),
.WrEn(RF_WrEn),
.RdEn(RF_RdEn),
.Address(RF_Address),
.Wr_D(RF_WrData),
.Gate_EN(CLKG_EN),
.ALU_FUN(ALU_FUN),
.ALU_EN(ALU_EN),
.RdDATA(RF_RdData),
.RdDATA_VLD(RF_RdData_VLD),
.OUT_Valid(ALU_OUT_VLD),
.ALU_OUT(ALU_OUT),
.Busy(UART_TX_Busy_SYNC),
.enable_pulse(UART_TX_V_SYNC),
.TX_P_DATA(UART_TX_D_IN), 
.TX_D_VLD(UART_TX_V_IN),
.regfile_operation_flag(regfile_operation_flag)
);

///********************************************************///
/////////////////////// Register File ////////////////////////
///********************************************************///

RegFile U0_RegFile (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.WrEn(RF_WrEn),
.RdEn(RF_RdEn),
.regfile_operation_flag(regfile_operation_flag),
.Address(RF_Address),
.WrData(RF_WrData),
.RdData(RF_RdData),
.RdData_VLD(RF_RdData_VLD),
.REG0(Operand_A),
.REG1(Operand_B),
.REG2(UART_Config),
.REG3(DIV_RATIO)
);

///********************************************************///
//////////////////////////// ALU /////////////////////////////
///********************************************************///
 
ALU U0_ALU (  
.A(Operand_A), 
.B(Operand_B),
.EN(ALU_EN),
.ALU_FUN(ALU_FUN),
.CLK(ALU_CLK),
.RST(SYNC_REF_RST),
.ALU_OUT(ALU_OUT),
.OUT_VALID(ALU_OUT_VLD)
);

///********************************************************///
///////////////////////// Clock Gating ///////////////////////
///********************************************************///

CLK_GATE U0_CLK_GATE (
.CLK_EN(CLKG_EN),
.CLK(REF_CLK),
.GATED_CLK(ALU_CLK)
);


endmodule