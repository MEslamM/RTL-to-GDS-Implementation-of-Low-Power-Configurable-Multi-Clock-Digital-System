module SYS_CTRL # (parameter DATA_WIDTH = 8 , ADDR = 4 , ALU_WIDTH = 2*DATA_WIDTH)
(
 input	wire						CLK,
 input	wire						RST,
 input	wire	[DATA_WIDTH-1:0]	RX_P_DATA,
 input	wire						RX_D_VLD,
 output wire                   		WrEn,  
 output wire                   		RdEn, 
 output wire    [ADDR-1:0]          Address, 
 output wire    [DATA_WIDTH-1:0]    Wr_D, 
 output wire                   		Gate_EN,
 output wire    [3:0]               ALU_FUN,
 output wire                   		ALU_EN,
 input	wire	[DATA_WIDTH-1:0]	RdDATA,
 input	wire						RdDATA_VLD,
 input	wire						OUT_Valid,
 input	wire    [ALU_WIDTH-1:0]     ALU_OUT, 
 input	wire                   		Busy,
 input  wire                        enable_pulse,
 output wire    [DATA_WIDTH-1:0]    TX_P_DATA,
 output wire                   		TX_D_VLD,
 output wire                        regfile_operation_flag
);

SYS_CTRL_Rx U0_SYS_CTRL_Rx(
.CLK(CLK),
.RST(RST),
.RX_P_DATA(RX_P_DATA),
.RX_D_VLD(RX_D_VLD),
.WrEn(WrEn),  
.RdEn(RdEn), 
.Address(Address), 
.Wr_D(Wr_D), 
.Gate_EN(Gate_EN),
.ALU_FUN(ALU_FUN),
.ALU_EN(ALU_EN),
.regfile_operation_flag(regfile_operation_flag)
);

SYS_CTRL_Tx U0_SYS_CTRL_Tx(
.CLK(CLK),
.RST(RST),
.RdDATA(RdDATA),
.RdDATA_VLD(RdDATA_VLD),
.OUT_Valid(OUT_Valid),
.ALU_OUT(ALU_OUT), 
.Busy(Busy),
.enable_pulse(enable_pulse),
.TX_P_DATA(TX_P_DATA),
.TX_D_VLD(TX_D_VLD)
);

endmodule