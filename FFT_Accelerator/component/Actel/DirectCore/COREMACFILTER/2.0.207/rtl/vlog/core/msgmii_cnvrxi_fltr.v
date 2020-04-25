//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// DESCRIPTION : M-SGMII GMII/MII receive conversion RTL module (PE-TBI side)
//               This module stores the GMII transmit data from the PE-TBI 
//               for read out by the input to the GMII/MII rx_clki clock 
//               domain. For MII 10 and 100, this module will only store 
//               data every 10 or 100 clocks respectively.
// FILE        : $Source: /opt/cvs/dip/tsmac/msgmii/rtl/msgmii_cnvrxi.v,v $
// REVISION    : $Revision: 1.1 $
// LAST UPDATE : $Date: 2013/09/02 09:20:58 $
//===========================================================================
// Mentor Graphics Corporation Proprietary and Confidential
// Copyright 2007 Mentor Graphics Corporation and Licensors
// All Rights Reserved
//===========================================================================
 
`timescale 1ps / 1ps

// --------------------------------------------------------------------------
// -- Module Definition

module CoreMACFilter_msgmii_cnvrxi_fltr
(
   srrex0,       // PMA Receive Clock #0 reset
   pma_rx_clk0,  // PMA Receive Clock #0 
   msgmii_speed, // 10/100/1000 = "00"/"01"/"10" respectively 
   rxdlcl0,      // GMII Receive Data       local 0
   rx_dvlcl0,    // GMII Receive Data Valid local 0
   rx_erlcl0,    // GMII Receive Error      local 0
   tx_enlcl1,    // GMII/MII transmit enable local 1
   rxrdptr,      // receive buffer read pointer 

   rxdlcl1,      // GMII Receive Data       local 1
   rx_dvlcl1,    // GMII Receive Data Valid local 1
   rx_erlcl1,    // GMII Receive Error      local 1
   coll,         // MII Collision
   crs,          // MII Carrier Sense
   rxhdptrpls,   // receive frame head pointer pulse
   rxhdptr       // receive frame head pointer
);
   
// --------------------------------------------------------------------------
// -- Port Declarations

input         srrex0;        // PMA Receive Clock #0 reset
input         pma_rx_clk0;   // PMA Receive Clock #0 
input   [1:0] msgmii_speed;  // 10/100/1000 = "00"/"01"/"10" respectively 
input  [15:0] rxdlcl0;       // GMII Receive Data       local 0
input   [1:0] rx_dvlcl0;     // GMII Receive Data Valid local 0
input   [1:0] rx_erlcl0;     // GMII Receive Error      local 0
input         tx_enlcl1;     // GMII/MII transmit enable local 1
input   [3:0] rxrdptr;       // receive buffer read pointer 
              
output  [7:0] rxdlcl1;       // GMII    Receive Data       local 1
output        rx_dvlcl1;     // GMII    Receive Data Valid local 1
output        rx_erlcl1;     // GMII    Receive Error      local 1
output        coll;          // MII Collision
output        crs;           // MII Carrier Sense
output        rxhdptrpls;    // receive frame head pointer pulse
output  [3:0] rxhdptr;       // receive frame head pointer

// --------------------------------------------------------------------------
// -- Internal signal declarations

`define TP #1

reg   [15:0] rxdp0;         // MII receive data pipe 0  
reg    [1:0] rx_dvp0;       // MII receive data valid pipe 0
reg    [1:0] rx_dvp1;       // MII receive data valid pipe 1
reg    [1:0] rx_erp0;       // MII receive error pipe 0
reg    [5:0] scntr;         // sample period counter
wire         wrten;         // write enable 
reg    [3:0] rxwptr;        // Recive write pointer
reg    [9:0] store00;       // Store register location  0
reg    [9:0] store01;       // Store register location  1
reg    [9:0] store02;       // Store register location  2 
reg    [9:0] store03;       // Store register location  3 
reg    [9:0] store04;       // Store register location  4 
reg    [9:0] store05;       // Store register location  5 
reg    [9:0] store06;       // Store register location  6 
reg    [9:0] store07;       // Store register location  7 
reg    [9:0] store08;       // Store register location  8 
reg    [9:0] store09;       // Store register location  9 
reg    [9:0] store10;       // Store register location 10 
reg    [9:0] store11;       // Store register location 11 
reg    [9:0] store12;       // Store register location 12 
reg    [9:0] store13;       // Store register location 13 
reg    [9:0] store14;       // Store register location 14 
reg    [9:0] store15;       // Store register location 15
wire   [9:0] storedcd;      // Store decode
wire         rxhdptrplsclr; // receive frame head pointer pulse clear
wire         rxhdptrplsset; // receive frame head pointer pulse set
reg          rxhdptrpls;    // receive frame head pointer pulse
reg          rxhdptrplsp;   // receive frame head pointer pulse pipeline
reg    [3:0] rxhdptr;       // receive frame head pointer
wire         gmiimd;        // asserted when interface is GMII

// --------------------------------------------------------------------------
// -- Input Pipeline 0

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                    rxdp0    <= `TP 16'h00;
   else                             rxdp0    <= `TP rxdlcl0;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                    rx_dvp0  <= `TP 2'b00;
   else                             rx_dvp0  <= `TP rx_dvlcl0;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                    rx_erp0  <= `TP 2'b00;
   else                             rx_erp0  <= `TP rx_erlcl0;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                    rx_dvp1  <= `TP 2'b00;
   else                             rx_dvp1  <= `TP rx_dvp0;
end

// --------------------------------------------------------------------------
// -- Sample Counter

assign gmiimd = msgmii_speed == 2'b10;

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                                 scntr <= `TP 6'h00;
   else if (   gmiimd 
             | (   ( msgmii_speed == 2'b01 )
                 & ( scntr        == 6'd4  ) )
             | (   ( msgmii_speed == 2'b00 )
                 & ( scntr        == 6'd49 ) ) ) scntr <= `TP 6'h00;
   else                                          scntr <= `TP scntr + 6'h01;
end

// --------------------------------------------------------------------------
// -- Recieve buffer Write pointer

assign wrten = gmiimd | ( scntr == 6'h02 );

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                                 rxwptr <= `TP 4'h0;
   else if ( wrten )                             rxwptr <= `TP rxwptr + 4'h1;
end

// --------------------------------------------------------------------------
// -- Pointer handshake

assign rxhdptrplsset =    ( (|rx_dvp0)  & wrten                )
                       |  ( rxhdptrpls  & (|rx_dvp0)           ) 
                       |  ( ~rxhdptrpls & ~rxhdptrplsp & wrten );

assign rxhdptrplsclr =    ( ~(|rx_dvp0) & wrten                )
                       |  (  rxhdptrpls & rxhdptrplsp  & wrten );

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                        rxhdptrpls  <= `TP 1'b0;
   else if ( rxhdptrplsset )            rxhdptrpls  <= `TP 1'b1;
   else if ( rxhdptrplsclr )            rxhdptrpls  <= `TP 1'b0;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                             rxhdptr  <= `TP 4'h0;
   else if (   ~rxhdptrpls & rxhdptrplsset 
             & ( msgmii_speed == 2'b10 )   ) rxhdptr  <= `TP rxwptr - 4'h1;
   else if (   ~rxhdptrpls & rxhdptrplsset ) rxhdptr  <= `TP rxwptr - 4'h6;
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                        rxhdptrplsp <= `TP 1'b0;
   else if ( wrten )                    rxhdptrplsp <= `TP rxhdptrpls;
end

// --------------------------------------------------------------------------
// -- MII half duplex

assign crs  = |rx_dvlcl0;
assign coll = |rx_dvlcl0 & tx_enlcl1;

// --------------------------------------------------------------------------
// -- receive buffer read

assign storedcd =                                            
     { 10 { (rxrdptr == 4'h0) } } & store00 
   | { 10 { (rxrdptr == 4'h1) } } & store01
   | { 10 { (rxrdptr == 4'h2) } } & store02
   | { 10 { (rxrdptr == 4'h3) } } & store03
   | { 10 { (rxrdptr == 4'h4) } } & store04
   | { 10 { (rxrdptr == 4'h5) } } & store05
   | { 10 { (rxrdptr == 4'h6) } } & store06
   | { 10 { (rxrdptr == 4'h7) } } & store07
   | { 10 { (rxrdptr == 4'h8) } } & store08 
   | { 10 { (rxrdptr == 4'h9) } } & store09
   | { 10 { (rxrdptr == 4'ha) } } & store10
   | { 10 { (rxrdptr == 4'hb) } } & store11
   | { 10 { (rxrdptr == 4'hc) } } & store12
   | { 10 { (rxrdptr == 4'hd) } } & store13
   | { 10 { (rxrdptr == 4'he) } } & store14
   | { 10 { (rxrdptr == 4'hf) } } & store15;

assign  rxdlcl1   = storedcd[7:0];  
assign  rx_dvlcl1 = storedcd[8];    
assign  rx_erlcl1 = storedcd[9];    

// --------------------------------------------------------------------------
// -- receive buffer write

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store00 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd0) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd0) ) )
      store00 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store01 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd0) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd1) ) )
      store01 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store02 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd1) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd2) ) )
      store02 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store03 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd1) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd3) ) )
      store03 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store04 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd2) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd4) ) )
      store04 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store05 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd2) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd5) ) )
      store05 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store06 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd3) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd6) ) )
      store06 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store07 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd3) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd7) ) )
      store07 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end


always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store08 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd4) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd8) ) )
      store08 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store09 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd4) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd9) ) )
      store09 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store10 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd5) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd10) ) )
      store10 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store11 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd5) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd11) ) )
      store11 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store12 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd6) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd12) ) )
      store12 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store13 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd6) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd13) ) )
      store13 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store14 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd7) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd14) ) )
      store14 <= `TP { rx_erp0[0], rx_dvp0[0], rxdp0[7:0] };
end

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )  store15 <= `TP 10'h000;
   else if (   (  gmiimd & (rxwptr[2:0] == 3'd7) ) 
             | ( ~gmiimd & (rxwptr[3:0] == 4'd15) ) )
      store15 <= `TP { rx_erp0[1], rx_dvp0[1], rxdp0[15:8] };
end

endmodule

//=============================================================================
// Revision History:  
// $Log: msgmii_cnvrxi.v,v $
// Revision 1.1  2013/09/02 09:20:58  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================

