module COREMACFILTER_C0_COREMACFILTER_C0_0_COREMACFILTER
(
RESETN,
RXCLK,
RXCLK_SEL0,    
//SGMII interface.
RCGI,         // PE-TBI Receive  Code Group
PMA_RX_CLK0,   // PMA Receive Clock #0
//PMA_RX_CLK1,   // PMA Receive Clock #1
RCGO,
//GMII Interface.
RXDV,
RXD, 
RXERI,
RXERO,
//APB INTERFACE.
PCLK,
PRESETN,
PWRITE,
PADDR,
PSEL,
PENABLE,
PWDATA,
PRDATA,
PSLVERR,
PREADY
);	


input        RESETN ; 
input        RXCLK ;
output       RXCLK_SEL0 ;      

// SGMII Interface.
input  [9:0] RCGI ;         // PE-TBI Receive  Code Group
input        PMA_RX_CLK0 ;   // PMA Receive Clock #0
//input        PMA_RX_CLK1 ;   // PMA Receive Clock #1
output [9:0] RCGO ;
// GMII Interface.
input        RXDV ;
input   [7:0]RXD ;  
input        RXERI ;
output       RXERO ;
// APB INTERFACE.
input         PCLK ;
input         PRESETN ;
input         PWRITE ;
input [31:0]  PADDR ;
input         PSEL ;
input         PENABLE ;
input  [31:0] PWDATA ;
output [31:0] PRDATA ;
output        PSLVERR ;
output        PREADY ;


parameter GMII_SGMII = 1 ; // By default GMII Filtering is enable.
parameter FAMILY = 19 ;    


COREMACFILTER_C0_COREMACFILTER_C0_0_frame_fltr_top1 #(.GMII_SGMII(GMII_SGMII)) frame_fltr_top_inst
(
.hreset_ni(RESETN),
.rxclk125_25_i(RXCLK),
.rxclk_sel0_o(RXCLK_SEL0),
// SGMII Interface
.rcg_i(RCGI ),   // PE-TBI Receive  Code Group
.pma_rx_clk0(PMA_RX_CLK0 ),   // PMA Receive Clock #0
//.pma_rx_clk1(PMA_RX_CLK1 ),   // PMA Receive Clock #1
.pma_rx_clk1( ),   // PMA Receive Clock #1

.rcg_o(RCGO ),
// GMII Interface.
.rx_dv_i(RXDV ),
.rxd_i(RXD),  
.rx_er_i(RXERI),
.rx_er_o(RXERO),
// APB INTERFACE.
.pclk_i(PCLK),
.prst_i(PRESETN),
.pwrite_i(PWRITE),
.paddr_i(PADDR),
.psel_i(PSEL),
.penable_i(PENABLE),
.pwdata_i(PWDATA),
.prdata_o(PRDATA),
.pslverr_o(PSLVERR),
.pready_o(PREADY)
);

endmodule


