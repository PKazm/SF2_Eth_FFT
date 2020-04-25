//====================================================================== 
//                            Sibridge Technologies 
//                        Proprietary and Confidential 
//                             All Rights Reserved 
//====================================================================== 
// FILE        : $Source: /opt/cvs/dip/tsmac/si_sal/rtl/si_sal.v,v $ 
// REVISION    : $Revision: 1.3 $ 
// LAST UPDATE : $Date: 2013/11/14 11:39:25 $ 
//====================================================================== 
// AUTHOR      : Sibridge Technologies 
// MODULE NAME : si_sal
// DESCRIPTION : station address logic for tsmac
//====================================================================== 
 
module CoreMACFilter_si_sal_fltr 
(
   input          clk_i,
   input          reset_ni,
   input [6:0]    hashv_i,
   input          hashe_i,
   input          ucad_i,
   input          mcad_i,
   input          bcad_i,
   input          dat_i,
   input          mcadp_i,
   input [ 5:0]   fltrctrl_i,
   input [31:0]   hashtblreg0_i,
   input [31:0]   hashtblreg1_i,
   input [31:0]   hashtblreg2_i,
   input [31:0]   hashtblreg3_i,
   output         rxdrp_evnt_o,
   output         drpfrm_o
);

// local wire/reg declarations
// --------------------------------------------------------------------------
wire       [7:0] hshbytdcd;  // Hash table byte decode 
wire             hshbitdcd;  // Hash table bit decode 
reg              hshbitdcd_val;
reg hashe_d1;
reg drpfrm_d1;
reg drpfrm;
wire allowfrm;

assign rxdrp_evnt_o = ~drpfrm_d1 & drpfrm;

// -- Hash table decode
// --------------------------------------------------------------------------
assign hshbytdcd =
     { 8 { ~hashv_i[6] & ~hashv_i[5] & ~hashv_i[4] & ~hashv_i[3] }} & hashtblreg0_i[7:0]
   | { 8 { ~hashv_i[6] & ~hashv_i[5] & ~hashv_i[4] &  hashv_i[3] }} & hashtblreg0_i[15:8]
   | { 8 { ~hashv_i[6] & ~hashv_i[5] &  hashv_i[4] & ~hashv_i[3] }} & hashtblreg0_i[23:16]
   | { 8 { ~hashv_i[6] & ~hashv_i[5] &  hashv_i[4] &  hashv_i[3] }} & hashtblreg0_i[31:24]
   | { 8 { ~hashv_i[6] &  hashv_i[5] & ~hashv_i[4] & ~hashv_i[3] }} & hashtblreg1_i[7:0]
   | { 8 { ~hashv_i[6] &  hashv_i[5] & ~hashv_i[4] &  hashv_i[3] }} & hashtblreg1_i[15:8]
   | { 8 { ~hashv_i[6] &  hashv_i[5] &  hashv_i[4] & ~hashv_i[3] }} & hashtblreg1_i[23:16]
   | { 8 { ~hashv_i[6] &  hashv_i[5] &  hashv_i[4] &  hashv_i[3] }} & hashtblreg1_i[31:24]
   | { 8 {  hashv_i[6] & ~hashv_i[5] & ~hashv_i[4] & ~hashv_i[3] }} & hashtblreg2_i[7:0]
   | { 8 {  hashv_i[6] & ~hashv_i[5] & ~hashv_i[4] &  hashv_i[3] }} & hashtblreg2_i[15:8]
   | { 8 {  hashv_i[6] & ~hashv_i[5] &  hashv_i[4] & ~hashv_i[3] }} & hashtblreg2_i[23:16]
   | { 8 {  hashv_i[6] & ~hashv_i[5] &  hashv_i[4] &  hashv_i[3] }} & hashtblreg2_i[31:24]
   | { 8 {  hashv_i[6] &  hashv_i[5] & ~hashv_i[4] & ~hashv_i[3] }} & hashtblreg3_i[7:0]
   | { 8 {  hashv_i[6] &  hashv_i[5] & ~hashv_i[4] &  hashv_i[3] }} & hashtblreg3_i[15:8]
   | { 8 {  hashv_i[6] &  hashv_i[5] &  hashv_i[4] & ~hashv_i[3] }} & hashtblreg3_i[23:16]
   | { 8 {  hashv_i[6] &  hashv_i[5] &  hashv_i[4] &  hashv_i[3] }} & hashtblreg3_i[31:24];

assign hshbitdcd =
     ( ( ~hashv_i[2] & ~hashv_i[1] & ~hashv_i[0] ) & hshbytdcd[0] )
   | ( ( ~hashv_i[2] & ~hashv_i[1] &  hashv_i[0] ) & hshbytdcd[1] )
   | ( ( ~hashv_i[2] &  hashv_i[1] & ~hashv_i[0] ) & hshbytdcd[2] )
   | ( ( ~hashv_i[2] &  hashv_i[1] &  hashv_i[0] ) & hshbytdcd[3] )
   | ( (  hashv_i[2] & ~hashv_i[1] & ~hashv_i[0] ) & hshbytdcd[4] )
   | ( (  hashv_i[2] & ~hashv_i[1] &  hashv_i[0] ) & hshbytdcd[5] )
   | ( (  hashv_i[2] &  hashv_i[1] & ~hashv_i[0] ) & hshbytdcd[6] )
   | ( (  hashv_i[2] &  hashv_i[1] &  hashv_i[0] ) & hshbytdcd[7] );

always @ ( posedge clk_i or negedge reset_ni) begin
  if(!reset_ni)    hshbitdcd_val <= 1'b0;	   
  else if(hashe_i) hshbitdcd_val <= hshbitdcd;
  else             hshbitdcd_val <= hshbitdcd_val; 
end  

always @ ( posedge clk_i or negedge reset_ni) begin
  if(!reset_ni) begin
                   hashe_d1  <= 1'b0;	   
                   drpfrm_d1 <= 1'b0;	   
  end else begin
                   hashe_d1  <= hashe_i; 
                   drpfrm_d1 <= drpfrm ;	   
  end
end  

always @ ( posedge clk_i or negedge reset_ni) begin
 if(!reset_ni)     drpfrm        <= 1'b0;           
 else if(hashe_d1) drpfrm        <= ~allowfrm;
 else              drpfrm        <= dat_i & drpfrm; 
end

// Frame filter control
// --------------------------------------------------------------------------
assign  allowfrm = mcadp_i                                                // allow reserved multicast for pause
                   | (fltrctrl_i[0] & bcad_i )                            // allow all broadcast frames
                   | (fltrctrl_i[1] & mcad_i & !bcad_i)                   // allow all multicast frames
	           | (fltrctrl_i[2] & ucad_i )                            // allow perfect match
	           | (fltrctrl_i[3]          )                            // promiscous mode - Allow all frames
		   | (fltrctrl_i[4] & hshbitdcd_val & !mcad_i & !bcad_i)  // allow hashed unicast
		   | (fltrctrl_i[5] & hshbitdcd_val &  mcad_i & !bcad_i); // allow hashed multicast

assign drpfrm_o = drpfrm;

endmodule

//=============================================================================
// Revision History:  
// $Log: si_sal.v,v $
// Revision 1.3  2013/11/14 11:39:25  rohitp
// updated default value for hshbitdcd_val
//
// Revision 1.2  2013/10/17 10:58:17  dipak
// updated comments for dropframe info
//
// Revision 1.1  2013/10/17 07:03:14  dipak
// initial checkin...
//
//=============================================================================
