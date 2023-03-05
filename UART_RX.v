module UART_RX(
input 	wire			CLK,
input 	wire			RST,
input 	wire			PAR_EN,
input 	wire			PAR_TYP,
input 	wire			RX_IN,
input 	wire	[4:0]	Prescale,
output					data_valid,
output			[7:0]	P_DATA,
output  wire            par_err,
output  wire            stp_err
);

wire			data_samp_en ;
wire	[4:0]	edge_cnt ;
wire	[3:0]	bit_cnt ;
wire			enable ;
wire			par_chk_en ;
wire			strt_chk_en ;
wire			strt_glitch ;
wire			stp_chk_en ;
wire			deser_en ;
wire			Fill ;
wire			sampled_bit ;

par_chk DUT1 (
.CLK(CLK),
.RST(RST),
.parity_type(PAR_TYP),
.sampled_bit(sampled_bit),
.Enable(par_chk_en),
.P_DATA(P_DATA),
.par_err(par_err)
);

start_check DUT2 (
.CLK(CLK),
.RST(RST),
.strt_chk_en(strt_chk_en),
.sampled_bit(sampled_bit),
.strt_glitch(strt_glitch)
);

stop_check DUT3 (
.CLK(CLK),
.RST(RST),
.stp_chk_en(stp_chk_en),
.sampled_bit(sampled_bit),
.stp_err(stp_err)
);

edge_bit_counter DUT4(
.CLK(CLK),
.RST(RST),
.enable(enable),
.Prescale(Prescale),
.data_valid(data_valid),
.bit_cnt(bit_cnt),
.edge_cnt(edge_cnt)
);

data_sampling DUT5(
.CLK(CLK),
.RST(RST),
.data_samp_en(data_samp_en),
.RX_IN(RX_IN),
.edge_cnt(edge_cnt),
.Prescale(Prescale),
.sampled_bit(sampled_bit),
.Fill(Fill)
);

deserializer DUT6(
.CLK(CLK),
.RST(RST),
.deser_en(deser_en),
.sampled_bit(sampled_bit),
.Fill(Fill),
.data_valid(data_valid),
.P_DATA(P_DATA)
);

UART_RX_FSM DUT7(
.CLK(CLK),
.RST(RST),
.PAR_EN(PAR_EN),
.RX_IN(RX_IN),
.bit_cnt(bit_cnt),
.par_err(par_err),
.strt_glitch(strt_glitch),
.stp_err(stp_err),
.data_samp_en(data_samp_en),
.enable(enable),
.deser_en(deser_en),
.data_valid(data_valid),
.par_chk_en(par_chk_en),
.strt_chk_en(strt_chk_en),
.stp_chk_en(stp_chk_en)
);

endmodule