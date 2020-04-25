//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// FILENAME    : rtl/pecrc.v
//
// DESCRIPTION : MENTOR MCX Cyclic Redundancy Check Logic
//
// VERSION     : $Revision: 1.1 $
//
// LAST UPDATE : $Date: 2013/09/02 09:21:01 $
//===========================================================================
//                   MENTOR Proprietary and Confidential
//                       Copyright (c) 2003, MENTOR
//                          All Rights Reserved
//===========================================================================

`timescale 1ns / 1ns

// --------------------------------------------------------------------------
// --- Module Description

// This module generates a standard 802.3/Ethernet Cyclic Redundancy Check
// value for inclusion in or comparison with a frame Frame Check Sequence 
// field.  

// --------------------------------------------------------------------------
// --- Module Definition

module CoreMACFilter_pecrc
(
  cclk,   crst,
  cdat,   cval,
  cini,   chld,
  xcen,

  creg,   cerr
);


// --------------------------------------------------------------------------
// --- Port Declarations

input         cclk,   crst;
input   [7:0] cdat;
input         cval;
input         cini,   chld;
input         xcen;

output [31:0] creg;
output        cerr;

reg    [31:0] creg;
wire          cerr;


// --------------------------------------------------------------------------
// --- Port Descriptions

// cclk        ::= CRC Clock
// crst        ::= CRC Reset
// cdat[7:0]   ::= CRC Input Data
// cval        ::= CRC Input Valid
// cini        ::= CRC Initialization
// chld        ::= CRC Hold

// creg[31:0]  ::= CRC Register
// cerr        ::= CRC Error 


// --------------------------------------------------------------------------
// --- Parameter Declarations

 parameter TP = 1;


// --------------------------------------------------------------------------
// --- Module Variable Declarations

wire    [7:0] t;

// t[7:0]      ::= CRC input terms

wire   [31:0] x1b;

// x1b[31:0]   ::= 8-bit CRC Calculation

reg    [31:0] gcreg;

// gcreg[31:0] :: Go CRC Register


// --------------------------------------------------------------------------
// --- Create Basic CRC terms

// t[7:0] :: CRC input terms

assign t[0]  = creg[31] ^ ( cval & cdat[0] );

assign t[1]  = creg[30] ^ ( cval & cdat[1] );

assign t[2]  = creg[29] ^ ( cval & cdat[2] );

assign t[3]  = creg[28] ^ ( cval & cdat[3] );

assign t[4]  = creg[27] ^ ( cval & cdat[4] );

assign t[5]  = creg[26] ^ ( cval & cdat[5] );

assign t[6]  = creg[25] ^ ( cval & cdat[6] );

assign t[7]  = creg[24] ^ ( cval & cdat[7] );


// --------------------------------------------------------------------------
// --- Create One Byte Exclusive-Or Terms

// x1b[31:0] :: 8-bit CRC calculation

assign x1b[31] = creg[23] ^ t[2];

assign x1b[30] = creg[22] ^ t[0] ^ t[3];

assign x1b[29] = creg[21] ^ t[0] ^ t[1] ^ t[4];

assign x1b[28] = creg[20] ^ t[1] ^ t[2] ^ t[5];

assign x1b[27] = creg[19] ^ t[0] ^ t[2] ^ t[3] ^ t[6];

assign x1b[26] = creg[18] ^ t[1] ^ t[3] ^ t[4] ^ t[7];

assign x1b[25] = creg[17] ^ t[4] ^ t[5];

assign x1b[24] = creg[16] ^ t[0] ^ t[5] ^ t[6];

assign x1b[23] = creg[15] ^ t[1] ^ t[6] ^ t[7];

assign x1b[22] = creg[14] ^ t[7];

assign x1b[21] = creg[13] ^ t[2];

assign x1b[20] = creg[12] ^ t[3];

assign x1b[19] = creg[11] ^ t[0] ^ t[4];

assign x1b[18] = creg[10] ^ t[0] ^ t[1] ^ t[5];

assign x1b[17] = creg[9]  ^ t[1] ^ t[2] ^ t[6];

assign x1b[16] = creg[8]  ^ t[2] ^ t[3] ^ t[7];

assign x1b[15] = creg[7]  ^ t[0] ^ t[2] ^ t[3] ^ t[4];

assign x1b[14] = creg[6]  ^ t[0] ^ t[1] ^ t[3] ^ t[4] ^ t[5];

assign x1b[13] = creg[5]  ^ t[0] ^ t[1] ^ t[2] ^ t[4] ^ t[5] ^ t[6];

assign x1b[12] = creg[4]  ^ t[1] ^ t[2] ^ t[3] ^ t[5] ^ t[6] ^ t[7];

assign x1b[11] = creg[3]  ^ t[3] ^ t[4] ^ t[6] ^ t[7];

assign x1b[10] = creg[2]  ^ t[2] ^ t[4] ^ t[5] ^ t[7];

assign x1b[9]  = creg[1]  ^ t[2] ^ t[3] ^ t[5] ^ t[6];

assign x1b[8]  = creg[0]  ^ t[3] ^ t[4] ^ t[6] ^ t[7];

assign x1b[7]  =             t[0] ^ t[2] ^ t[4] ^ t[5] ^ t[7];

assign x1b[6]  =             t[0] ^ t[1] ^ t[2] ^ t[3] ^ t[5] ^ t[6];

assign x1b[5]  =             t[0] ^ t[1] ^ t[2] ^ t[3] ^ t[4] ^ t[6] ^ t[7];

assign x1b[4]  =             t[1] ^ t[3] ^ t[4] ^ t[5] ^ t[7];

assign x1b[3]  =             t[0] ^ t[4] ^ t[5] ^ t[6];

assign x1b[2]  =             t[0] ^ t[1] ^ t[5] ^ t[6] ^ t[7];

assign x1b[1]  =             t[0] ^ t[1] ^ t[6] ^ t[7];

assign x1b[0]  =             t[1] ^ t[7];


// --------------------------------------------------------------------------
// --- CRC Register

// gcreg[31:0] :: Go CRC Register

always @ ( cini or cval or chld or x1b or creg )
begin
  case ( 1'b1 ) //synopsys parallel_case
    cini    : gcreg = 32'hffff_ffff;
    cval    : gcreg = x1b[31:0];
    chld    : gcreg = creg[31:0];
    default : gcreg = 32'h0000_0000;
  endcase
end

// creg[31:0] :: CRC Register

always @ ( posedge cclk or posedge crst )
begin
     if ( crst )           creg[31:0] <= #TP 32'h0;
else if ( xcen )           creg[31:0] <= #TP gcreg[31:0];     
end


// --------------------------------------------------------------------------
// --- Examine CRC Residual Value

// Examine CRC register, creg[31:0], for the CRC polynomial.

assign cerr = creg[31:0] != 32'b11000111000001001101110101111011;

// assign cerr = creg != 32'hc704dd7b;

endmodule

//=============================================================================
// Revision History:  
// $Log: pecrc.v,v $
// Revision 1.1  2013/09/02 09:21:01  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================
