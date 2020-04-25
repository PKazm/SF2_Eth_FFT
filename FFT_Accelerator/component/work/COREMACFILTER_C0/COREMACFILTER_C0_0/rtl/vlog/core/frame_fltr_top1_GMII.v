module COREMACFILTER_C0_COREMACFILTER_C0_0_frame_fltr_top1 # 
(parameter GMII_SGMII = 1) // By default GMII Filtering is enable. 
(
input        hreset_ni,
input        rxclk125_25_i,
output       rxclk_sel0_o,     
  

// SGMII Interface.
input  [9:0] rcg_i,         // PE-TBI Receive  Code Group
input        pma_rx_clk0,   // PMA Receive Clock #0
input        pma_rx_clk1,   // PMA Receive Clock #1
output [9:0] rcg_o,
// GMII Interface.
input        rx_dv_i,
input   [7:0]rxd_i,  
input        rx_er_i,
output       rx_er_o,

// APB INTERFACE.
input         pclk_i,
input         prst_i,
input         pwrite_i,
input [31:0]  paddr_i,
input         psel_i,
input         penable_i,
input  [31:0] pwdata_i,
output [31:0] prdata_o,
output        pslverr_o,
output        pready_o
);

// --------------------------------------------------------------------------
// -- Internal Signal Declarations
wire         drpfrm;
wire  [15:0] rxdlcl0;    // GMII/MII receive data       local 0
wire   [1:0] rx_dvlcl0;  // GMII/MII receive enable     local 0
wire   [1:0] rx_erlcl0;  // GMII/MII receive error      local 0
wire   [7:0] rxdlcl1;    // GMII/MII receive data       local 1
wire         rx_dvlcl1;  // GMII/MII receive data valid local 1
wire         rx_erlcl1;  // GMII/MII receive error      local 1
wire   [2:0] txrdptr;    // Transmit buffer read pointeer 
wire   [3:0] rxrdptr;    // Receive buffer read pointeer 
wire   [3:0] rxhdptr;    // Receive  frame head pointer
wire         rxhdptrpls; // Receive  frame head pointer pulse
wire         srrex0;     // PMA Receive Clock #0 reset
wire          rrrex;
reg           rrex1, rrex2;
wire          srrex_i;
reg           rrex11, rrex12;
wire          srrex1_i;
wire          srrex1;
reg           rrex01, rrex02;
wire          srrex0_i;
wire   [19:0] rdcg;   // rdcg[9:0]   ::= Receive Dual Code Group
wire          rdcerr; // rdcerr      ::= Receive Dual Code Error
wire bcad,mcad,ucad,hashe,mcadp;
wire [8:0] hashv;
wire rrrfn,srrfn;
reg  rrfn1,rrfn2;

wire  [5:0]     fltrctrl;   
wire  [31:0]    hashtblreg0;
wire  [31:0]    hashtblreg1;
wire  [31:0]    hashtblreg2;
wire  [31:0]    hashtblreg3;
wire  [10:0]    tsm_control;
wire  [47:0]    sta_addr;
wire  [1:0]     speed;
wire            fulld;
wire  [7:0]     mifg;
wire dat;
wire       count_en;
reg [3:0] rxcen_cntr;
wire rxcen;

wire [7:0] rxd;
wire       rx_dv;
wire       rx_er;

wire rxdrp_evnt, drp_cnt_en ;

assign speed[1:0] = tsm_control[1:0];
assign fulld      = tsm_control[2];
assign mifg [7:0] = tsm_control[10:3];

assign pslverr_o = 1'b0;


assign rxclk_sel0_o = !speed[1];

assign rxclk_i = rxclk125_25_i;

always @ ( posedge rxclk_i)
begin
  if(!srrfn) rxcen_cntr <= 4'h0;
  else if (rxcen_cntr == 4'h9) rxcen_cntr <= 4'h0;
  else if (speed == 2'b00) rxcen_cntr <= rxcen_cntr + 4'h1;
  else rxcen_cntr <= rxcen_cntr;
end


//assign rxcen = (speed == 2'b00) ? (rxcen_cntr == 4'h1) : 1'b1;
assign rxcen = (speed == 2'b00) ? 1'b1 : 1'b1;


//Reset Synchronization to Rx_clk
assign rrrfn = hreset_ni; 

// rrfn1 :: Reset PERFN module synchronizing stage 1

always @ ( posedge rxclk_i )
begin
                   rrfn1 <=  rrrfn;
end

// rrfn2 :: Reset PERFN module synchronizing stage 2

always @ ( posedge rxclk_i )
begin
                   rrfn2 <=  rrfn1;
end

// srrfn_i :: Synchronized Reset PERFN module, Intermediate

assign srrfn = rrrfn | rrfn2;


assign rcg_o    = drpfrm ? 10'h3A1 : rcg_i ;
assign rx_er_o  = rx_er_i | drpfrm;

generate if (GMII_SGMII == 0) begin
  assign rxd      = rxd_i;
  assign rx_dv    = rx_dv_i;
  assign rx_er    = rx_er_i;
end endgenerate 

//---------------------------------------------------------------------------//
// SGMII Clock and Reset Logic.
//---------------------------------------------------------------------------//
generate if (GMII_SGMII == 1) begin
 assign rrrex = ~hreset_ni;
  always @ ( negedge pma_rx_clk0 )
  begin
    rrex11 <=   rrrex;
  end
  always @ ( negedge pma_rx_clk0 )
  begin
    rrex12 <=   rrex11;
  end
  assign srrex1_i = rrrex | rrex12;
  assign srrex1 = srrex1_i;
  always @ ( posedge pma_rx_clk0 )
  begin
    rrex01 <=   rrrex;
  end
  always @ ( posedge pma_rx_clk0 )
  begin
    rrex02 <=   rrex01;
  end
  assign srrex0_i = rrrex | rrex02;
  assign srrex0 = srrex0_i;
end endgenerate

//---------------------------------------------------------------------------//
// Synchronization istance for the enable pulse of the Rx Drop counter.
//---------------------------------------------------------------------------//

CoreMACFilter_sib_sync_pulse sib_sync_pulse_U0 (                                                                               
   .txclk_i   (rxclk_i  ),     //Tx Domain clock 
   .txrst_ni  (srrfn   ),     //Tx Domain Reset
   .txpulse_i (rxdrp_evnt ),   //Tx Domain pulse
   .rxclk_i   (pclk_i   ),     //Rx Domain clock 
   .rxrst_ni  (prst_i  ),     //Rx Domain Reset 
   .rxpulse_o (count_en),    //Rx Domain sync pulse
   .pulse_xfrd_o ());       //pulse transferred



CoreMACFilter_perfn_top_fltr perfn_top_fltr_U(
 .rx_clk (rxclk_i),
 .rxcen  (rxcen), //1'b1 ), 
 .rx_dv  (rx_dv),
 .rxd    (rxd  ),
 .rx_er  (rx_er),
 .ptxen  (1'b0),//ptxen_i), 
 .speed  (speed),
 .rxen   (1'b1   ),        
 .fulld  (fulld ), 
 .mifg   (mifg  ),
 .srrfn  (~srrfn),      //Reset
 .hashv  (hashv ),      // Hash Value
 .hashe  (hashe ),      // Hash Enable
 .stad   (sta_addr),
 .dat_d1 (dat  ),
 .mcadp  (mcadp),
 .bcad   (bcad ),
 .mcad   (mcad ),
 .ucad   (ucad ));

CoreMACFilter_tsm_sysreg_fltr tsm_sysreg_fltr_U(
.hst_clk_i          (pclk_i), 
.hst_rst_ni         (prst_i), 
.hst_csn_i          (psel_i),        // APB Slave Select. 
.hst_wrn_i          (pwrite_i),      // APB Write/Read.
.hst_pen_i          (penable_i),      // APB Write/Read.
.hst_addr_i         (paddr_i[6:2]),        // APB Address Bus.
.hst_wdat_i         (pwdata_i),       // APB Write Data Bus.  
.tsm_status_i       (32'b0), 
.fltrctrl_o         (fltrctrl   ),
.hashtblreg0_o      (hashtblreg0),
.hashtblreg1_o      (hashtblreg1),
.hashtblreg2_o      (hashtblreg2),
.hashtblreg3_o      (hashtblreg3),
.tsm_control_o      (tsm_control), 
.sta_addr_o         (sta_addr),
.count_en_i         (count_en),
.hst_rdat_o         (prdata_o),       // APB Read Data Bus.
.hst_pready_o       (pready_o));      // APB Slave Ready.

CoreMACFilter_si_sal_fltr si_sal_U (
 .clk_i          (rxclk_i      ),
 .reset_ni       (srrfn        ),
 .hashv_i        (hashv [8:2]  ),
 .hashe_i        (hashe        ),
 .dat_i          (dat          ),
 .mcadp_i        (mcadp        ),
 .ucad_i         (ucad         ),
 .mcad_i         (mcad         ),
 .bcad_i         (bcad         ),
 .fltrctrl_i     (fltrctrl     ),
 .hashtblreg0_i  (hashtblreg0  ),
 .hashtblreg1_i  (hashtblreg1  ),
 .hashtblreg2_i  (hashtblreg2  ),
 .hashtblreg3_i  (hashtblreg3  ),
 .rxdrp_evnt_o   (rxdrp_evnt   ),
 .drpfrm_o       (drpfrm       )
);


generate if (GMII_SGMII == 1) begin 
   CoreMACFilter_perex_pma_fltr perex_pma_1
   (
     .pma_rx_clk1(pma_rx_clk1), 
     .pma_rx_clk0(pma_rx_clk0), 
     .rcg(rcg_i),
     .miim(1'b0),
     .tcg(10'b0),
     .loopb(1'b0),
     .srrex1(srrex1),
     .srrex0(srrex0),
     .rdcg(rdcg),
     .rdcerr(rdcerr)
   );
   
   // Receive Exchange PCS Logic Sub-Module Instantiation
   CoreMACFilter_perex_pcs_fltr perex_pcs_1
   (
     .pma_rx_clk0(pma_rx_clk0), 
     .rdcg(rdcg),
     .rdcerr(rdcerr),
     .sdet(1'b1),
     .ewrap(1'b0),
     .xmit(2'b10),
     .miim(1'b0),
     .drrd(1'b0),//drrd), // Need to think on this.
     .loopb(1'b0),
     .srrex0(srrex0),
     .anen(1'b0),
     .sync(),
     .rudidl(),
     .rudinv(),
     .rudcfg(),
     .rxcr(),
     .irxdv(rx_dvlcl0),
     .irxd (rxdlcl0),
     .irxer(rx_erlcl0)
   );
   
   CoreMACFilter_msgmii_cnvrxi_fltr msgmii_cnvrxi_1
   (
      .srrex0(srrex0),             // PMA Receive Clock #0 reset
      .pma_rx_clk0(pma_rx_clk0),   // PMA Receive Clock #0 
      .msgmii_speed(speed), // 10/100/1000 = "00"/"01"/"10" respectively 
      .rxdlcl0  (rxdlcl0),           // GMII Receive Data       local 0
      .rx_dvlcl0(rx_dvlcl0),       // GMII Receive Data Valid local 0
      .rx_erlcl0(rx_erlcl0),       // GMII Receive Error      local 0
      .tx_enlcl1(1'b0),       // GMII/MII transmit enable local 1
      .rxrdptr  (rxrdptr),           // Recieve buffer read pointer 
      .rxdlcl1(rxdlcl1),           // GMII Receive Data       local 1
      .rx_dvlcl1(rx_dvlcl1),       // GMII Receive Data Valid local 1
      .rx_erlcl1(rx_erlcl1),       // GMII Receive Error      local 1
      .coll(),                 // MII Collision
      .crs(),                   // MII Carrier Sense
      .rxhdptrpls(rxhdptrpls),     // Recieve frame head pointer pulse
      .rxhdptr   (rxhdptr)            // Recieve frame head pointer
   );
   
   CoreMACFilter_msgmii_cnvrxo_fltr msgmii_cnvrxo_1
   (
      .rx_clkirst  (~srrfn),       // IEEE defined rx_clk post clock tree reset
      .rx_clki     (rxclk_i),      // IEEE defined rx_clk post clock tree 
      .rxcen  (rxcen), //1'b1 ), 
      .msgmii_speed(speed),      // 10/100/1000 = "00"/"01"/"10" respectively 
      .rxdlcl1     (rxdlcl1),      // GMII Receive Data       local 1
      .rx_dvlcl1   (rx_dvlcl1),    // GMII Receive Data Valid local 1
      .rx_erlcl1   (rx_erlcl1),    // GMII Receive Error      local 1
      .rxhdptrpls  (rxhdptrpls),   // Recieve frame head pointer pulse
      .rxhdptr     (rxhdptr),      // Recieve frame head pointer
      .rxd         (rxd),                   // G/MII Receive Data
      .rx_dv       (rx_dv),               // G/MII Receive Data Valid
      .rx_er       (rx_er),               // G/MII Receive Error
      .rxrdptr     (rxrdptr)            // Recieve buffer read pointeer 
   );
end endgenerate

//---------------------------------------------------------------------------//
endmodule 
