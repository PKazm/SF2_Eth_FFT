//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// DESCRIPTION : M-SGMII GMII/MII receive conversion RTL module (MAC side)
//               This module reads the GMII transmit data from the 
//               msgmii_cnvrxi for read out to the GMII/MII  
//               rx_clki clock domain. For MII 10 and 100, this module will 
//               artificially create preamble and SFD and convert to nibbles.
// FILE        : $Source: /opt/cvs/dip/tsmac/msgmii/rtl/msgmii_cnvrxo.v,v $
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

module CoreMACFilter_msgmii_cnvrxo_fltr
(
   rx_clkirst,       // IEEE defined rx_clk post clock tree reset
   rx_clki,          // IEEE defined rx_clk post clock tree 
   rxcen,            // 
   msgmii_speed,     // 10/100/1000 = "00"/"01"/"10" respectively 
   rxdlcl1,          // GMII Receive Data       local 1
   rx_dvlcl1,        // GMII Receive Data Valid local 1
   rx_erlcl1,        // GMII Receive Error      local 1
   rxhdptrpls,       // receive frame head pointer pulse
   rxhdptr,          // receive frame head pointer

   rxd,              // G/MII Receive Data
   rx_dv,            // G/MII Receive Data Valid
   rx_er,            // G/MII Receive Error
   rxrdptr           // Receive buffer read pointer 
);
   
// --------------------------------------------------------------------------
// -- Port Declarations

input        rx_clkirst;       // IEEE defined rx_clk post clock tree reset
input        rx_clki;          // IEEE defined rx_clk post clock tree 
input        rxcen; 
input  [1:0] msgmii_speed;     // 10/100/1000 = "00"/"01"/"10" respectively 
input  [7:0] rxdlcl1;          // GMII Receive Data       local 1
input        rx_dvlcl1;        // GMII Receive Data Valid local 1
input        rx_erlcl1;        // GMII Receive Error      local 1
input        rxhdptrpls;       // receive frame head pointer pulse
input  [3:0] rxhdptr;          // receive frame head pointer
                  
output [7:0] rxd;              // G/MII Receive Data
output       rx_dv;            // G/MII Receive Data Valid
output       rx_er;            // G/MII Receive Error
output [3:0] rxrdptr;          // Receive buffer read pointer 

// --------------------------------------------------------------------------
// -- Internal signal declarations

`define TP #1

reg    [7:0] rxd;              // G/MII Receive Data
reg          rx_dv;            // G/MII Receive Data Valid
reg          rx_er;            // G/MII Receive Error
reg    [3:0] rxrdptr;          // Transmit buffer read pointer
reg          frstnbl;          // first nibble
reg    [2:0] rxhdptrplsp;      // receive frame head pointer pulse pipe
wire         rxhdptredge;      // receive frame head pointer edge  pipe
wire   [7:0] rxdlcl1int;       // GMII Receive Data local 1 internal

// --------------------------------------------------------------------------
// -- Pipeline 1

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )    rxhdptrplsp <= `TP 3'h0;
   else if(rxcen)       rxhdptrplsp <= `TP { rxhdptrplsp[1:0], rxhdptrpls };
end

assign rxhdptredge = rxhdptrplsp[1] & ~rxhdptrplsp[2];

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )                       frstnbl <= `TP 1'b0;
   else if(rxcen) begin
     if ( rxhdptredge & ~rx_dvlcl1 )    frstnbl <= `TP 1'b1;
     else                               frstnbl <= `TP ~frstnbl;
   end
end

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )                         rxrdptr <= `TP 4'h4;
   else if(rxcen) begin
     if (   ( msgmii_speed == 2'b10 ) 
               & rxhdptredge & ~rx_dvlcl1 )    rxrdptr <= `TP { rxhdptr[2:0], 1'b0 }; 
     else if (   ( msgmii_speed != 2'b10 ) 
               & rxhdptredge & ~rx_dvlcl1 )    rxrdptr <= `TP rxhdptr; 
     else if (   ( ~frstnbl )
               | ( msgmii_speed == 2'b10   ) ) rxrdptr <= `TP rxrdptr + 4'h1;
   end    
end

// --------------------------------------------------------------------------
// -- Output logic

assign 	rxdlcl1int = 
     {8{(msgmii_speed == 2'h2)            }} & rxdlcl1
   | {8{(msgmii_speed != 2'h2) &  frstnbl }} & {4'h0, rxdlcl1[3:0]} 
   | {8{(msgmii_speed != 2'h2) & ~frstnbl }} & {4'h0, rxdlcl1[7:4]}; 

// --------------------------------------------------------------------------
// -- Output pipeline

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )                       rxd     <= `TP 8'h0;
   else if(rxcen)                          rxd     <= `TP rxdlcl1int;
end

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )                       rx_dv   <= `TP 1'b0;
   else if(rxcen)                          rx_dv   <= `TP rx_dvlcl1;
end

always @ ( posedge rx_clki or posedge rx_clkirst )
begin
   if ( rx_clkirst )                       rx_er   <= `TP 1'b0;
   else if(rxcen)                          rx_er   <= `TP rx_erlcl1;
end

endmodule

//=============================================================================
// Revision History:  
// $Log: msgmii_cnvrxo.v,v $
// Revision 1.1  2013/09/02 09:20:58  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================

