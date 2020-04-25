//====================================================================== 
//                            Sibridge Technologies 
//                        Proprietary and Confidential 
//                             All Rights Reserved 
//====================================================================== 
// FILE        : $Source: /opt/cvs/dip/tsmac/mahbe/rtl/tsm_sysreg.v,v $ 
// REVISION    : $Revision: 1.3 $ 
// LAST UPDATE : $Date: 2013/10/22 08:06:39 $ 
//====================================================================== 
// AUTHOR      : Sibridge Technologies 
// MODULE NAME : tsm_sysreg
// DESCRIPTION : System registers: ahb-slave
//====================================================================== 
 
module CoreMACFilter_tsm_sysreg_fltr (
  input            hst_clk_i   , 
  input            hst_rst_ni  , 
  input            hst_csn_i   , //System reg chip-select Active Low
  input            hst_wrn_i   , //System reg RegisterWriteEnable
  input            hst_pen_i   , //System reg RegisterWriteEnable
  input [4:0]      hst_addr_i  , //System reg RegisterAddress
  input [31:0]     hst_wdat_i  , //System reg RegisterWriteData
  input [31:0]     tsm_status_i, 
  input            count_en_i,   // When asseted The status counter is incremented By 1. Status counter relects the number of Droped frames.
  output [5:0]     fltrctrl_o    ,
  output [31:0]    hashtblreg0_o ,
  output [31:0]    hashtblreg1_o ,
  output [31:0]    hashtblreg2_o ,
  output [31:0]    hashtblreg3_o ,
  output [10:0]    tsm_control_o, 
  output [47:0]    sta_addr_o,
  output [31:0]    hst_rdat_o  , //System reg RegisterReadData
  output wire      hst_pready_o //System reg RegisterReadDataEnable // Ready 
);

wire [5:0]  fltrctrl_c;
wire [31:0] hashtblreg0_c;
wire [31:0] hashtblreg1_c;
wire [31:0] hashtblreg2_c;
wire [31:0] hashtblreg3_c;
wire [12:0] tsm_control_c; // Two more bit added for Drp counter Clear Control.

reg  [5:0]  fltrctrl;
reg  [31:0] hashtblreg0;
reg  [31:0] hashtblreg1;
reg  [31:0] hashtblreg2;
reg  [31:0] hashtblreg3;
reg  [12:0] tsm_control;
reg  [31:0] hst_rdat;


// Station Address Regs.
reg  [47:0] stad;
wire [47:0] stad_c;
wire [31:0] hst_rdat_c; 
wire apb_wr_en, apb_rd_en, apb_wr_en_c, pready_c;
reg hst_rdaten_d1, hst_rdaten_d2, hst_rdaten_d3, apb_wr_en_d1, apb_wr_en_d2, apb_rd_en_d1;
wire [31:0] status_reg_c;
reg  [31:0] status_reg;
wire        status_reg_clr_c;
reg         status_reg_clr;


`define HSTADDR_FLTCTRL   5'b1_0000
`define HSTADDR_HSHTBL0   5'b1_0001
`define HSTADDR_HSHTBL1   5'b1_0010
`define HSTADDR_HSHTBL2   5'b1_0011
`define HSTADDR_HSHTBL3   5'b1_0100
`define HSTADDR_CTRL      5'b1_0101
`define HSTADDR_STS       5'b1_0110
`define HSTADDR_STA_ADDR_LOW       5'b1_0111
`define HSTADDR_STA_ADDR_HIGH      5'b1_1000

assign fltrctrl_o    = fltrctrl; 
assign hashtblreg0_o = hashtblreg0; 
assign hashtblreg1_o = hashtblreg1; 
assign hashtblreg2_o = hashtblreg2; 
assign hashtblreg3_o = hashtblreg3; 
assign tsm_control_o = tsm_control[10:0];
assign sta_addr_o    = stad;

// -- Internal Signal Declarations
// --------------------------------------------------------------------------
assign apb_wr_en_c = hst_csn_i & hst_wrn_i & hst_pen_i;
assign apb_wr_en = apb_wr_en_d1;
assign fltrctrl_wr      = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_FLTCTRL       );
assign hashtblreg0_wr   = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_HSHTBL0       );
assign hashtblreg1_wr   = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_HSHTBL1       );
assign hashtblreg2_wr   = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_HSHTBL2       );
assign hashtblreg3_wr   = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_HSHTBL3       );
assign tsm_control_wr   = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_CTRL          );
assign sta_addr_high_wr = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_STA_ADDR_HIGH );
assign sta_addr_low_wr  = (apb_wr_en & hst_addr_i[4:0] == `HSTADDR_STA_ADDR_LOW  );


assign fltrctrl_c    = fltrctrl_wr ? hst_wdat_i[5:0] : fltrctrl;
assign hashtblreg0_c = hashtblreg0_wr ? hst_wdat_i : hashtblreg0; 
assign hashtblreg1_c = hashtblreg1_wr ? hst_wdat_i : hashtblreg1; 
assign hashtblreg2_c = hashtblreg2_wr ? hst_wdat_i : hashtblreg2; 
assign hashtblreg3_c = hashtblreg3_wr ? hst_wdat_i : hashtblreg3; 
assign tsm_control_c[11:0] = tsm_control_wr ? hst_wdat_i[11:0] : tsm_control[11:0];
assign tsm_control_c[12]   = ~status_reg_clr & (tsm_control_wr ? hst_wdat_i[12] : tsm_control[12]);
assign {stad_c[7:0],stad_c[15:8],stad_c[23:16],stad_c[31:24]} = sta_addr_low_wr  ? hst_wdat_i        : {stad[7:0],stad[15:8],stad[23:16],stad[31:24]};
assign {stad_c[39:32], stad_c[47:40]}                         = sta_addr_high_wr ? hst_wdat_i[31:16] : {stad[39:32], stad[47:40]};

assign status_reg_clr_c =  (apb_rd_en & (hst_addr_i[4:0] == `HSTADDR_STS) & tsm_control[11]) | tsm_control[12];

assign status_reg_c = {32{~status_reg_clr}} & (  {32{ count_en_i}} & (status_reg + 1'b1)  
                                               | {32{~count_en_i}} &  status_reg         );

assign apb_rd_en = hst_csn_i & !hst_wrn_i & hst_pen_i & !apb_rd_en_d1;

assign hst_rdat_c =     apb_rd_en ? (({32{(hst_addr_i[4:0] == `HSTADDR_FLTCTRL      )}} & {26'b0, fltrctrl}                              ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_HSHTBL0      )}} & hashtblreg0                                    ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_HSHTBL1      )}} & hashtblreg1                                    ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_HSHTBL2      )}} & hashtblreg2                                    ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_HSHTBL3      )}} & hashtblreg3                                    ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_CTRL         )}} & {19'b0,tsm_control}                            ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_STS          )}} &  status_reg                                    ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_STA_ADDR_HIGH)}} & {stad[39:32], stad[47:40], 16'h0 }             ) |
                                     ({32{(hst_addr_i[4:0] == `HSTADDR_STA_ADDR_LOW )}} & {stad[7:0],stad[15:8],stad[23:16],stad[31:24]} ) )
				  : hst_rdat;  

assign hst_pready_o = apb_rd_en_d1 | apb_wr_en_d1;
assign hst_rdat_o = hst_rdat;
always @ (posedge hst_clk_i or negedge hst_rst_ni) begin
  if(!hst_rst_ni) begin
    fltrctrl    <= 6'b11_1111;
    hashtblreg0 <= 32'b0;
    hashtblreg1 <= 32'b0;
    hashtblreg2 <= 32'b0;
    hashtblreg3 <= 32'b0;
    tsm_control <= 13'b00_0101_0000_1_10; //Bit 12:11= Drp Counter clear control, 10:3 MIFG, bit 2= fdpx Bit 1:0 SPEED. 
    stad <= 48'hC0B1_3C888888;
    hst_rdat   <= 32'b0;
    //hst_pready_o <= 1'b1;
    apb_wr_en_d1 <= 1'b0;
    apb_wr_en_d2 <= 1'b0;
    apb_rd_en_d1 <= 1'b0;
    status_reg   <= 32'b0;
    status_reg_clr <= 1'b0;
  end
  else begin
    fltrctrl    <= fltrctrl_c   ; 
    hashtblreg0 <= hashtblreg0_c; 
    hashtblreg1 <= hashtblreg1_c; 
    hashtblreg2 <= hashtblreg2_c; 
    hashtblreg3 <= hashtblreg3_c; 
    tsm_control <= tsm_control_c; 
    stad <= stad_c;
    hst_rdat   <= hst_rdat_c;
    //hst_pready_o <= !pready_c;
    apb_wr_en_d1 <= apb_wr_en_c;
    apb_wr_en_d2 <= apb_wr_en_d1;
    apb_rd_en_d1 <= apb_rd_en;
    status_reg   <= status_reg_c;
    status_reg_clr <= status_reg_clr_c;
  end
end


endmodule

//=============================================================================
// Revision History:  
// $Log: tsm_sysreg.v,v $
// Revision 1.3  2013/10/22 08:06:39  dipak
// added misc control and status regs, portlist changes accordingly
//
// Revision 1.2  2013/10/17 12:52:03  dipak
// corrected o/p assignments with control/hshtbl signals
//
// Revision 1.1  2013/10/17 07:04:43  dipak
// initial checkin
//
//=============================================================================
