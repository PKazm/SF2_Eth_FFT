//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// DESCRIPTION : 10 Gigabit MAC layer Receive Function RTL module
// FILE        : $Source: /opt/cvs/dip/tsmac/msgmii/rtl/perex_pma.v,v $
// REVISION    : $Revision: 1.2 $
// LAST UPDATE : $Date: 2013/10/18 08:25:18 $
//===========================================================================
// Mentor Graphics Corporation Proprietary and Confidential
// Copyright 2007 Mentor Graphics Corporation and Licensors
// All Rights Reserved
//===========================================================================
`define MSGMII_PARALLEL_COMMA_ALIGNMENT

`timescale 1ps / 1ps

module CoreMACFilter_perex_pma_fltr 
(
   pma_rx_clk1, // PMA Receive Clock 1, 62.5 MHz, split phase
   pma_rx_clk0, // PMA Receive Clock 0, 62.5 MHz, split phase
   rcg,         // Receive Code Group
   miim,        // G/MII Mode
   tcg,         // Transmit Code Group
   loopb,       // Loopback
   srrex1,      // Synchronized Reset pma_rx_clk1 domain
   srrex0,      // Synchronized Reset pma_rx_clk0 domain

   rdcg,        // Receive Dual Code Group
   rdcerr       // Receive Dual Code Error
);

// --------------------------------------------------------------------------
// -- Input/Output Declarations

// PEREX_PMA module inputs
input         pma_rx_clk1;
input         pma_rx_clk0;
input   [9:0] rcg;
input         miim;
input   [9:0] tcg;
input         loopb;
input         srrex1;
input         srrex0;

// PEREX_PMA module outputs
output [19:0] rdcg;
output        rdcerr;

// --------------------------------------------------------------------------
// -- Internal Signal declarations

parameter TP = 1;

reg    [9:0]  rcg1_p1;
reg    [19:0] rcg_p1;
reg    [19:0] rcg_p3;
wire          rcgklow_p2;
wire          rcgkhi_p2;
reg           rcgklow_p3;
reg           rcgkhi_p3;
reg           rcgkhi_p4;
reg           jstfylow_p3;
wire          rdcerr_p3;
wire          rdcerr;

// --------------------------------------------------------------------------
// -- Clock conversion

//always @ ( posedge pma_rx_clk1 or posedge srrex1 )
always @ ( negedge pma_rx_clk0 or posedge srrex1 )
begin
   if      ( srrex1 )               rcg1_p1      <= #TP 10'h0;
   else if ( loopb )                rcg1_p1      <= #TP tcg;
   else                             rcg1_p1      <= #TP rcg;
end

// --------------------------------------------------------------------------
// -- Symbol Pipes

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )               rcg_p1      <= #TP 20'h0;
   else if ( loopb )                rcg_p1      <= #TP { tcg, rcg1_p1 };
   else                             rcg_p1      <= #TP { rcg, rcg1_p1 };
end

// --------------------------------------------------------------------------
// -- Ifdef conditional parallel comma realignment logic. May be used if the 
// -- receive serdes does not have comma alignment. Required for use when
// -- MSGMII is integrated with Mentor MSGMII Serdes hardcore

`ifdef MSGMII_PARALLEL_COMMA_ALIGNMENT

   reg  [19:0] rcg_p1p1;
   wire  [9:0] commashift;
   reg   [9:0] commashift_p3;
   wire [19:0] rcgaligned_p1;
   reg  [19:0] rcg_p2;
   
   always @ ( posedge pma_rx_clk0 or posedge srrex0 )
   begin
      if      ( srrex0 )               rcg_p1p1    <= #TP 20'h0;
      else                             rcg_p1p1    <= #TP rcg_p1;
   end
   
   assign commashift[0] = (   (rcg_p1p1[6:0]                 == 7'b1111100) 
                            | (rcg_p1p1[6:0]                 == 7'b0000011)
                            | (rcg_p1p1[16:10]               == 7'b1111100)  
                            | (rcg_p1p1[16:10]               == 7'b0000011) );
   assign commashift[1] = (   (rcg_p1p1[7:1]                 == 7'b1111100) 
                            | (rcg_p1p1[7:1]                 == 7'b0000011)
                            | (rcg_p1p1[17:11]               == 7'b1111100)  
                            | (rcg_p1p1[17:11]               == 7'b0000011) );
   assign commashift[2] = (   (rcg_p1p1[8:2]                 == 7'b1111100) 
                            | (rcg_p1p1[8:2]                 == 7'b0000011)
                            | (rcg_p1p1[18:12]               == 7'b1111100)  
                            | (rcg_p1p1[18:12]               == 7'b0000011) );
   assign commashift[3] = (   (rcg_p1p1[9:3]                 == 7'b1111100) 
                            | (rcg_p1p1[9:3]                 == 7'b0000011)
                            | (rcg_p1p1[19:13]               == 7'b1111100)  
                            | (rcg_p1p1[19:13]               == 7'b0000011) );
   assign commashift[4] = (   (rcg_p1p1[10:4]                == 7'b1111100) 
                            | (rcg_p1p1[10:4]                == 7'b0000011)
                            | ({rcg_p1[0],rcg_p1p1[19:14]}   == 7'b1111100)  
                            | ({rcg_p1[0],rcg_p1p1[19:14]}   == 7'b0000011) );
   assign commashift[5] = (   (rcg_p1p1[11:5]                == 7'b1111100) 
                            | (rcg_p1p1[11:5]                == 7'b0000011)
                            | ({rcg_p1[1:0],rcg_p1p1[19:15]} == 7'b1111100)  
                            | ({rcg_p1[1:0],rcg_p1p1[19:15]} == 7'b0000011) );
   assign commashift[6] = (   (rcg_p1p1[12:6]                == 7'b1111100) 
                            | (rcg_p1p1[12:6]                == 7'b0000011)
                            | ({rcg_p1[2:0],rcg_p1p1[19:16]} == 7'b1111100)  
                            | ({rcg_p1[2:0],rcg_p1p1[19:16]} == 7'b0000011) );
   assign commashift[7] = (   (rcg_p1p1[13:7]                == 7'b1111100) 
                            | (rcg_p1p1[13:7]                == 7'b0000011)
                            | ({rcg_p1[3:0],rcg_p1p1[19:17]} == 7'b1111100)  
                            | ({rcg_p1[3:0],rcg_p1p1[19:17]} == 7'b0000011) );
   assign commashift[8] = (   (rcg_p1p1[14:8]                == 7'b1111100) 
                            | (rcg_p1p1[14:8]                == 7'b0000011)
                            | ({rcg_p1[4:0],rcg_p1p1[19:18]} == 7'b1111100)  
                            | ({rcg_p1[4:0],rcg_p1p1[19:18]} == 7'b0000011) );
   assign commashift[9] = (   (rcg_p1p1[15:9]                == 7'b1111100) 
                            | (rcg_p1p1[15:9]                == 7'b0000011)
                            | ({rcg_p1[5:0],rcg_p1p1[19]}    == 7'b1111100)  
                            | ({rcg_p1[5:0],rcg_p1p1[19]}    == 7'b0000011) );
   
   always @ ( posedge pma_rx_clk0 or posedge srrex0 )
   begin
      if      ( srrex0 )               commashift_p3 <= #TP 10'h001;
      else if ( |commashift )          commashift_p3 <= #TP commashift;
   end
   
   assign rcgaligned_p1 =   {20{commashift_p3      == 10'h001}} & rcg_p1p1
                          | {20{commashift_p3[9:1] ==  9'h001}} & {rcg_p1[0],   rcg_p1p1[19:1]}
                          | {20{commashift_p3[9:2] ==  8'h01 }} & {rcg_p1[1:0], rcg_p1p1[19:2]}
                          | {20{commashift_p3[9:3] ==  7'h01 }} & {rcg_p1[2:0], rcg_p1p1[19:3]}
                          | {20{commashift_p3[9:4] ==  6'h01 }} & {rcg_p1[3:0], rcg_p1p1[19:4]}
                          | {20{commashift_p3[9:5] ==  5'h01 }} & {rcg_p1[4:0], rcg_p1p1[19:5]}
                          | {20{commashift_p3[9:6] ==  4'h1  }} & {rcg_p1[5:0], rcg_p1p1[19:6]}
                          | {20{commashift_p3[9:7] ==  3'h1  }} & {rcg_p1[6:0], rcg_p1p1[19:7]}
                          | {20{commashift_p3[9:8] ==  2'h1  }} & {rcg_p1[7:0], rcg_p1p1[19:8]}
                          | {20{commashift_p3[9]   ==  1'b1  }} & {rcg_p1[8:0], rcg_p1p1[19:9]};
   
   always @ ( posedge pma_rx_clk0 or posedge srrex0 )
   begin
      if      ( srrex0 )               rcg_p2       <= #TP 20'h0;
      else                             rcg_p2       <= #TP rcgaligned_p1;
   end

`else

   wire    [19:0] rcg_p2 = rcg_p1;

`endif

// -- End Ifdef conditional parallel comma realignment logic.  
// --------------------------------------------------------------------------

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )               rcg_p3       <= #TP 20'h0;
   else                             rcg_p3       <= #TP rcg_p2;
end

// --------------------------------------------------------------------------
// -- K code detection and Pipes

assign rcgklow_p2 = rcg_p2[9:0]   == 10'b01_0111_1100  // -K28.5+
                  | rcg_p2[9:0]   == 10'b10_1000_0011  // +K28.5-
                  | rcg_p2[9:0]   == 10'b10_0111_1100  // -K28.1+
                  | rcg_p2[9:0]   == 10'b01_1000_0011; // +K28.1-
                          
assign rcgkhi_p2  = rcg_p2[19:10] == 10'b01_0111_1100  // -K28.5+
                  | rcg_p2[19:10] == 10'b10_1000_0011  // +K28.5-
                  | rcg_p2[19:10] == 10'b10_0111_1100  // -K28.1+
                  | rcg_p2[19:10] == 10'b01_1000_0011; // +K28.1-

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )   rcgklow_p3              <= #TP 1'b0;
   else                 rcgklow_p3              <= #TP rcgklow_p2;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )   rcgkhi_p3               <= #TP 1'b0;
   else                 rcgkhi_p3               <= #TP rcgkhi_p2;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )   rcgkhi_p4               <= #TP 1'b0;
   else                 rcgkhi_p4               <= #TP rcgkhi_p3;
end

// --------------------------------------------------------------------------
// -- K code Alignment

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if      ( srrex0 )                           jstfylow_p3 <= #TP 1'b0;
   else if ( miim )                             jstfylow_p3 <= #TP 1'b1;
   else if ( rcgkhi_p2  & ~rcgklow_p2 )         jstfylow_p3 <= #TP 1'b0;
   else if ( rcgklow_p2 & ~rcgkhi_p2)           jstfylow_p3 <= #TP 1'b1;
end

assign rdcg =   {20{  jstfylow_p3 }} & rcg_p3
              | {20{ ~jstfylow_p3 }} & {rcg_p2[9:0], rcg_p3[19:10]};

// --------------------------------------------------------------------------
// -- Receive Dual K28.5 Code Error

assign rdcerr_p3 =  (  jstfylow_p3 & (   (rcgkhi_p3  & rcgklow_p3)
                                       | (rcgkhi_p4  & rcgklow_p3) ) )
                  | ( ~jstfylow_p3 & (   (rcgklow_p2 & rcgkhi_p3 ) 
                                       | (rcgkhi_p3  & rcgklow_p3) ) );
assign rdcerr = 1'b0;
//-always @ ( posedge pma_rx_clk0 or posedge srrex0 )
//-begin
//-   if      ( srrex0 )   rdcerr               <= #TP 1'b0;
//-   else                 rdcerr               <= #TP 1'b0;
//-end

endmodule

//=============================================================================
// Revision History:  
// $Log: perex_pma.v,v $
// Revision 1.2  2013/10/18 08:25:18  dipak
// cleanup: removed unused signals
//
// Revision 1.1  2013/09/02 09:21:00  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================
