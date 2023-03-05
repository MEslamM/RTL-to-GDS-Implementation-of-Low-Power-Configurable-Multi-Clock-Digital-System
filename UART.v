module UART # ( parameter DATA_WIDTH = 8 , PRESCALE_WIDTH = 5 )
(
 input   wire                          RST,
 input   wire                          TX_CLK,
 input   wire                          RX_CLK,
 input   wire                          RX_IN_S,
 output  wire   [DATA_WIDTH-1:0]       RX_OUT_P, 
 output  wire                          RX_OUT_V,
 input   wire   [DATA_WIDTH-1:0]       TX_IN_P, 
 input   wire                          TX_IN_V, 
 output  wire                          TX_OUT_S,
 output  wire                          TX_OUT_V,  
 input   wire   [PRESCALE_WIDTH-1:0]   Prescale,
 input   wire                          parity_enable,
 input   wire                          parity_type,
 output  wire                          parity_error,
 output  wire                          stop_error
);


UART_TX  U0_UART_TX (
.CLK(TX_CLK),
.RST(RST),
.P_DATA(TX_IN_P),
.Data_Valid(TX_IN_V),
.parity_enable(parity_enable),
.parity_type(parity_type), 
.TX_OUT(TX_OUT_S),
.busy(TX_OUT_V)
);
 
 
UART_RX U0_UART_RX (
.CLK(RX_CLK),
.RST(RST),
.PAR_EN(parity_enable),
.PAR_TYP(parity_type),
.RX_IN(RX_IN_S),
.Prescale(Prescale),
.data_valid(RX_OUT_V),
.P_DATA(RX_OUT_P), 
.par_err(parity_error),
.stp_err(stop_error)
);
 

endmodule