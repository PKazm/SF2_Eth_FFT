//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// DESCRIPTION : 1000BASE-X Receive 10b/8b Decoder Module
// FILE        : $Source: /opt/cvs/dip/tsmac/msgmii/rtl/r10b8b.v,v $
// REVISION    : $Revision: 1.1 $
// LAST UPDATE : $Date: 2013/09/02 09:21:00 $
//===========================================================================
// Mentor Graphics Corporation Proprietary and Confidential
// Copyright 2007 Mentor Graphics Corporation and Licensors
// All Rights Reserved
//===========================================================================

`timescale 1ps / 1ps

// ------------------------------------------------------------------------
// --- Module Description

// This module decodes receive 10B symbols, rps[9:0], into receive 8B data
// bytes, rpd[7:0] and receive symbol indicates, rsi[2:0], which is used to
// indicate the type of receive symbol decoded.  Receive running disparity
// input, rdi, is used to monitor the running disparity of the decoded
// symbol.  The running disparity of the decoded symbol is output as rdo.
//
// Below is a chart of the rsi encode.
//
//     rsi   Symbol Type       Comment
//     -------------------------------
//      0    Start_of_Packet    - /S/
//      1    Invalid Code       - /INVALID/
//      2    End_of_Packet      - /T/
//      3    Carrier_Extend     - /R/
//      4    Comma character    - /K/
//      5    Data byte          - /D/
//      6    unused
//      7    Error_Propagation  - /V/


// ------------------------------------------------------------------------
// --- Module Definition

module CoreMACFilter_r10b8b 
(
  rps, rdi, sync,

  rpd, rsi, rdo, onebd
);

// ------------------------------------------------------------------------
// --- Port Declarations

input   [9:0] rps;
input         rdi;
input         sync;

output  [7:0] rpd;
output  [2:0] rsi;
output        rdo;
output        onebd;

// ------------------------------------------------------------------------
// --- Port Descriptions

// Inputs

// rps[9:0]    ::= Receive Parallel Symbol
// rdi         ::= Receive running Disparity Input indicator
// sync        ::= Synchronization

// Outputs

// rpd[7:0]    ::= Receive Parallel Data
// rsi[2:0]    ::= Receive Symbol Indicate
// rdo         ::= Receive running Disparity Output indicator
// onebd       ::= One Bit Distance ( from K28.5 )

// ------------------------------------------------------------------------
// --- Parameter Declarations

parameter     TP = 1;

// ------------------------------------------------------------------------
// --- Module Variables

wire    [9:0] rpc;
wire    [5:0] rpc5to0;
wire    [3:0] rpc9to6;

// rpc[9:0]    ::= Receive Parallel symbol Code
// rpc5to0     ::= Receive Parallel Code bits 5 to 0
// rpc9to6     ::= Receive Parallel Code bits 9 to 6

reg     [4:0] dec5;
reg           vi6;
reg     [1:0] fl6; 
reg           rev4s;
reg     [1:0] ss6f; 

//                 "Registers" for case statements
//
// dec5[4:0]   ::= Decoded 5-bit portion of receive data byte
// vi6         ::= Valid six bit symbol portion
// fl6[1]      ::= Flipped six bit symbol portion allowed to be flipped
// fl6[0]      ::= Flipped six bit symbol portion
// rev4s        ::= Expected flip of four bit symbol portion
// ss6f[1:0]   ::= Special group seven flag for the six bit portion

reg     [2:0] dec3;
reg           vi4, disr;
reg     [1:0] fl4;
reg     [2:0] ss4f;

//                 "Registers" for case statements
//
// dec3[2:0]   ::= Decoded 3-bit portion of receive data byte
// vi4         ::= Valid four bit symbol portion
// fl4[1]      ::= Flipped four bit symbol portion allowed to be flipped
// fl4[0]      ::= Flipped four bit symbol portion
// ss4f[2:0 ]  ::= Special group seven flag for the four bit portion
// disr        ::= Running disparity variable

wire    [7:0] decd;
wire          vid;

// decd[7:0]   ::= Decoded 8 bit byte
// vid         ::= Valid ten bit data symbol

reg     [2:0] dect;
reg           vik, flk;
wire          vix;

//                 "Registers" for case statements
//
// dect[2:0]   ::= Decoded receive symbol select
// vik         ::= Valid ten bit K symbol
// flk         ::= Ten bit K symbol flipped
// vix         ::= Validated ten bit K symbol

reg           decr;
reg     [2:0] decs;
reg     [7:0] decb;

//                 "Registers" for case statements
//
// decs[2:0]   ::= Decoded symbol indicator 
// decb[7:0]   ::= Decoded byte
// decr        ::= Running disparity variable

// ------------------------------------------------------------------------
// --- Module RTL Statements

// Decode the input symbol, rps[9:0], into the output receive symbol 
// indicate, rsi[2:0], and the output data byte, rpd[7:0].  Refer to the
// 8b/10b code charts.  Check the symbol based on receive disparity input,
// rdi, and generate receive disparity output, rdo.

// Rearrange the bits according to the 8b10b coding charts.

assign rpc = { rps[6], rps[7], rps[8], rps[9], rps[0],
               rps[1], rps[2], rps[3], rps[4], rps[5] };

// ------------------------------------------------------------------------
// --- Six bit symbol portion casex statement

// Use the low order six bits of the rearranged receive symbol, rpc[5:0],
// to decode the lower five bit portion, dec5[4:0] of the receive data
// byte.  Determine vi6, valid,  and fl6[1:0] and rev4s reversal bits as well.
// Also determine the ss6f, special group seven flag.

// rpc[9:0]    ::= Receive Parallel symbol Code
// dec5[4:0]   ::= Decoded 5-bit portion of receive data byte
// vi6         ::= Indicates six bit symbol portion is valid
// fl6[1]      ::= Indicates six bit symbol portion is allowed to be flipped
// fl6[0]      ::= Indicates six bit symbol portion is flipped
// rev4s       ::= Indicates that the flip of associated four bit symbol
//                 code portion is enabled
// ss6f[1:0]   ::= Special group seven flag for the six bit portion

assign rpc5to0 = rpc[5:0];

always @ ( rpc[5:0] )
 case ( { rpc[5], rpc[4], rpc[3], rpc[2], rpc[1], rpc[0] } )
  6'b100111 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00000_1_10_0_00; // D0.y
  6'b011000 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00000_1_11_0_00; // D0.y
  6'b011101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00001_1_10_0_00; // D1.y
  6'b100010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00001_1_11_0_00; // D1.y
  6'b101101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00010_1_10_0_00; // D2.y
  6'b010010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00010_1_11_0_00; // D2.y
  6'b110001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00011_1_00_1_00; // D3.y
  6'b110101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00100_1_10_0_00; // D4.y
  6'b001010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00100_1_11_0_00; // D4.y
  6'b101001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00101_1_00_1_00; // D5.y
  6'b011001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00110_1_00_1_00; // D6.y
  6'b111000 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00111_1_10_1_00; // D7.y
  6'b000111 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00111_1_11_1_00; // D7.y

  6'b111001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01000_1_10_0_00; // D8.y
  6'b000110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01000_1_11_0_00; // D8.y
  6'b100101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01001_1_00_1_00; // D9.y
  6'b010101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01010_1_00_1_00; // D10.y
  6'b110100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01011_1_00_1_01; // D11.y
  6'b001101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01100_1_00_1_00; // D12.y
  6'b101100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01101_1_00_1_01; // D13.y
  6'b011100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01110_1_00_1_01; // D14.y
  6'b010111 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01111_1_10_0_00; // D15.y
  6'b101000 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b01111_1_11_0_00; // D15.y

  6'b011011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10000_1_10_0_00; // D16.y
  6'b100100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10000_1_11_0_00; // D16.y
  6'b100011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10001_1_00_1_10; // D17.y
  6'b010011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10010_1_00_1_10; // D18.y
  6'b110010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10011_1_00_1_00; // D19.y
  6'b001011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10100_1_00_1_10; // D20.y
  6'b101010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10101_1_00_1_00; // D21.y
  6'b011010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10110_1_00_1_00; // D22.y
  6'b111010 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10111_1_10_0_00; // D23.y
  6'b000101 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b10111_1_11_0_00; // D23.y

  6'b110011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11000_1_10_0_00; // D24.y
  6'b001100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11000_1_11_0_00; // D24.y
  6'b100110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11001_1_00_1_00; // D25.y
  6'b010110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11010_1_00_1_00; // D26.y
  6'b110110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11011_1_10_0_00; // D27.y
  6'b001001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11011_1_11_0_00; // D27.y
  6'b001110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11100_1_00_1_00; // D28.y
  6'b101110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11101_1_10_0_00; // D29.y
  6'b010001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11101_1_11_0_00; // D29.y
  6'b011110 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11110_1_10_0_00; // D30.y
  6'b100001 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11110_1_11_0_00; // D30.y
  6'b101011 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11111_1_10_0_00; // D31.y
  6'b010100 : { dec5, vi6, fl6, rev4s, ss6f } = 11'b11111_1_11_0_00; // D31.y

  default   : { dec5, vi6, fl6, rev4s, ss6f } = 11'b00000_0_00_0_00;
 endcase

// ------------------------------------------------------------------------
// --- Four symbol portion casex statement

// Use the high order four bits of the rearranged receive symbol, rpc[9:6],
// to decode the upper three bit portion, dec3[2:0] of the receive data
// byte.  Determine vi4, valid, and fl4[1:0] reversal bits as well.

// rpc[9:0]    ::= Receive Parallel symbol Code
// dec3[2:0]   ::= Decoded 3-bit portion of receive data byte
// vi4         ::= Indicates four bit code portion is valid
// fl4[1]      ::= Indicates four bit symbol code portion may be flipped 
// fl4[0]      ::= Indicates four bit symbol code portion is flipped 
// ss4f[2:0]   ::= Special group seven flag for the four bit portion
// disr        ::= Running disparity variable

assign rpc9to6 = rpc[9:6];

always @ ( rpc[9:6] )
  case ( { rpc[9], rpc[8], rpc[7], rpc[6] } )
    4'b1011 : { dec3, vi4, fl4, ss4f, disr } = 10'b000_1_11__000_0;  // Dx.0
    4'b0100 : { dec3, vi4, fl4, ss4f, disr } = 10'b000_1_10__000_0;  // Dx.0
    4'b1001 : { dec3, vi4, fl4, ss4f, disr } = 10'b001_1_00__000_1;  // Dx.1
    4'b0101 : { dec3, vi4, fl4, ss4f, disr } = 10'b010_1_00__000_1;  // Dx.2
    4'b0011 : { dec3, vi4, fl4, ss4f, disr } = 10'b011_1_10__000_1;  // Dx.3
    4'b1100 : { dec3, vi4, fl4, ss4f, disr } = 10'b011_1_11__000_1;  // Dx.3
    4'b0010 : { dec3, vi4, fl4, ss4f, disr } = 10'b100_1_10__000_0;  // Dx.4
    4'b1101 : { dec3, vi4, fl4, ss4f, disr } = 10'b100_1_11__000_0;  // Dx.4
    4'b1010 : { dec3, vi4, fl4, ss4f, disr } = 10'b101_1_00__000_1;  // Dx.5
    4'b0110 : { dec3, vi4, fl4, ss4f, disr } = 10'b110_1_00__000_1;  // Dx.6
    4'b0001 : { dec3, vi4, fl4, ss4f, disr } = 10'b111_1_10__100_0;  // Dx.7
    4'b1110 : { dec3, vi4, fl4, ss4f, disr } = 10'b111_1_11__100_0;  // Dx.7
    4'b0111 : { dec3, vi4, fl4, ss4f, disr } = 10'b111_1_00__110_0;  // Dx.7
    4'b1000 : { dec3, vi4, fl4, ss4f, disr } = 10'b111_1_00__101_0;  // Dx.7

    default : { dec3, vi4, fl4, ss4f, disr } = 10'b000_0_00__000_0;  // default
  endcase

// ------------------------------------------------------------------------
// Form the eight bit decoded receive byte, decd[7:0] from dec5 and dec3.

// decd[7:0]   ::= Decoded 8 bit byte

assign decd = { dec3, dec5 };

// See charts below:  The four bit portion of the rearranged symbol are
// shown across the top of the charts.  The six bit portion of the
// rearranged symbol along the left side of the chart.  Both the normal
// and reversed versions of the symbol portions are shown.

// Four bit symbol portions allowed to be flipped are indicated by a 1
// in fl4[1] along the bottom of the chart.  The reversed versions of the
// four bit symbol portion are indicated by a 1 in fl4[0] along the bottom
// of the chart.  Other four bit symbol portion codes are not valid.

// Locations in the code chart allowed to have the four bit portion are
// at the intersection of fl4[1] and rev4s along the right hand side of the
// chart.  These locations are noted a 1 in the body of the chart.

// NOTE - the above ignores receive running disparity.

// Six bit symbol portions allowed to be flipped are indicated by a 1 in
// fll6[1] along the right side of the chart.  The reversed versions of
// the six bit symbol portion are indicated  by a 1 in fl6l0] along the
// right side of the chart.  Other six bit symbol portion codes not shown
// are not valid.

// Special code group symbols column are marked by a 1 in ss4f[1]
// and ss4f[0] along the bottom.   Six bit portion positions allowed
// have special group codes are marked by a 1 in ss6f[1] and ss6f[0]
// along the right side of the chart. Special group codes are only
// allowed at the intersections of ss4f[1] and ss6f[1] and the
// intersections of ss4f[0] and ss6f[0] as noted by * in the body of
// the chart..

//                                                ss
//                                         ff     ss
//                                         ll  r  66
//          10  1  0  01  01  1  0  0101   66  e  ff
//          01  0  1  10  01  0  1  0110   [[  v  [[
//          10  0  0  10  10  1  1  0110   10  4  10
//          10  1  1  10  01  0  0  1010   ]]  s  ]]

// 100111   00  0  0  00  00  0  0  0000   10  0  00
// 011000   00  0  0  00  00  0  0  0000   11  0  00
// 011101   00  0  0  00  00  0  0  0000   10  0  00
// 100010   00  0  0  00  00  0  0  0000   11  0  00
// 101101   00  0  0  00  00  0  0  0000   10  0  00
// 010010   00  0  0  00  00  0  0  0000   11  0  00
// 110001   11  0  0  11  11  0  0  1100   00  1  00
// 110101   00  0  0  00  00  0  0  0000   10  0  00
// 001010   00  0  0  00  00  0  0  0000   11  0  00
// 101001   11  0  0  11  11  0  0  1100   00  1  00
// 011001   11  0  0  11  11  0  0  1100   00  1  00
// 111000   11  0  0  11  11  0  0  1100   10  1  00
// 001111   11  0  0  11  11  0  0  1100   11  1  00

// 111001   00  0  0  00  00  0  0  0000   10  0  00
// 000110   00  0  0  00  00  0  0  0000   11  0  00
// 100101   11  0  0  11  11  0  0  1100   00  1  00
// 010101   11  0  0  11  11  0  0  1100   00  1  00
// 110100   11  0  0  11  11  0  0  110*   00  1  01
// 001101   11  0  0  11  11  0  0  1100   00  1  00
// 101100   11  0  0  11  11  0  0  110*   00  1  01
// 011100   11  0  0  11  11  0  0  110*   00  1  01
// 010111   00  0  0  00  00  0  0  0000   10  0  00
// 101000   00  0  0  00  00  0  0  0000   11  0  00

// 011011   00  0  0  00  00  0  0  0000   10  0  00
// 100100   00  0  0  00  00  0  0  0000   11  0  00
// 100011   11  0  0  11  11  0  0  11*0   00  1  10
// 010011   11  0  0  11  11  0  0  11*0   00  1  10
// 110010   11  0  0  11  11  0  0  1100   00  1  00
// 001011   11  0  0  11  11  0  0  11*0   00  1  10
// 101010   11  0  0  11  11  0  0  1100   00  1  00
// 011010   11  0  0  11  11  0  0  1100   00  1  00
// 111010   00  0  0  00  00  0  0  0000   10  0  00
// 000101   00  0  0  00  00  0  0  0000   11  0  00

// 110011   00  0  0  00  00  0  0  0000   10  0  00
// 001100   00  0  0  00  00  0  0  0000   11  0  00
// 100110   11  0  0  11  11  0  0  1100   00  1  00
// 010110   11  0  0  11  11  0  0  1100   00  1  00
// 110110   00  0  0  00  00  0  0  0000   10  0  00
// 001001   00  0  0  00  00  0  0  0000   11  0  00
// 101110   11  0  0  11  11  0  0  1100   00  1  00
// 010001   00  0  0  00  00  0  0  0000   00  0  00
// 101110   00  0  0  00  00  0  0  0000   00  0  00
// 011110   00  0  0  00  00  0  0  0000   10  0  00
// 100001   00  0  0  00  00  0  0  0000   11  0  00
// 101011   00  0  0  00  00  0  0  0000   10  0  00
// 010100   00  0  0  00  00  0  0  0000   11  0  00

// fl4[1]   11  0  0  11  11  0  0  1100            
// fl4[0]   01  0  0  01  01  0  0  0100            
// ss4f[2]  00  0  0  00  00  0  0  1111
// ss4f[1]  00  0  0  00  00  0  0  0010
// ss4f[0]  00  0  0  00  00  0  0  0001
// disr     00  1  1  11  00  1  1  0000

// Form data byte valid from vi6 and vi4.  Qualify the valid indicator with
// the special group seven code validation and four bit symbol portion
// reversal validation.

// vid         ::= Valid ten bit data symbol

assign vid = vi6 & vi4

           & ( ( rdi & fl6[1] ) == fl6[0] )

           & ( ss4f[1] | ss4f[0] 
             | ( ( fl4[1] & (  rdi ^ rev4s ) ) == fl4[0] ) )

           & ( ~ss4f[1] & ( ~ss6f[1] |  rdi | ~ss4f[2] )
             |  ss4f[1] &    ss6f[1] & ~rdi &  ss4f[2] ) 

           & ( ~ss4f[0] & ( ~ss6f[0] | ~rdi | ~ss4f[2] )
             |  ss4f[0] &    ss6f[0] &  rdi &  ss4f[2] );
             
// onebd      ::= One bit distance from K28.5 symbol

// reference code-group            01_0111_1100    -K28.5+
assign onebd = ~rdi & ( rps == 10'b11_0111_1100 )
             | ~rdi & ( rps == 10'b00_0111_1100 )
             | ~rdi & ( rps == 10'b01_1111_1100 )
             | ~rdi & ( rps == 10'b01_0011_1100 )
             | ~rdi & ( rps == 10'b01_0101_1100 )
             | ~rdi & ( rps == 10'b01_0110_1100 )
             | ~rdi & ( rps == 10'b01_0111_0100 )
             | ~rdi & ( rps == 10'b01_0111_1000 )
             | ~rdi & ( rps == 10'b01_0111_1110 )
             | ~rdi & ( rps == 10'b01_0111_1101 )

// reference code-group            10_1000_0011    +K28.5-
             |  rdi & ( rps == 10'b00_1000_0011 )             
             |  rdi & ( rps == 10'b11_1000_0011 )             
             |  rdi & ( rps == 10'b10_0000_0011 )             
             |  rdi & ( rps == 10'b10_1100_0011 )             
             |  rdi & ( rps == 10'b10_1010_0011 )             
             |  rdi & ( rps == 10'b10_1001_0011 )             
             |  rdi & ( rps == 10'b10_1000_1011 )             
             |  rdi & ( rps == 10'b10_1000_0111 )
             |  rdi & ( rps == 10'b10_1000_0001 )             
             |  rdi & ( rps == 10'b10_1000_0010 );             
              
// ------------------------------------------------------------------------
// Use the rearranged receive symbol, rps[9:0], to decode for K characters.
// Determine vik and flk valid and flip bits as well.  

// rpc[9:0]    ::= Receive Parallel symbol Code
// dect[2:0]   ::= Decoded receive symbol select
// vik         ::= Valid ten bit K symbol
// flk         ::= Ten bit K symbol flipped

always @ ( rpc )
  casex ( { rpc[9], rpc[8], rpc[7], rpc[6], rpc[5], 
            rpc[4], rpc[3], rpc[2], rpc[1], rpc[0] } )
    10'b10_0011_0110 : { dect, vik, flk } = 5'b000_1_0;  // S  - K27.7
    10'b01_1100_1001 : { dect, vik, flk } = 5'b000_1_1;  // S  - K27.7 rev 
    10'b10_0010_1110 : { dect, vik, flk } = 5'b010_1_0;  // T  - K29.7
    10'b01_1101_0001 : { dect, vik, flk } = 5'b010_1_1;  // T  - K29.7 rev
    10'b10_0011_1010 : { dect, vik, flk } = 5'b011_1_0;  // R  - K23.7
    10'b01_1100_0101 : { dect, vik, flk } = 5'b011_1_1;  // R  - K23.7 rev
    10'b10_1000_1111 : { dect, vik, flk } = 5'b100_1_0;  // K  - K28.5
    10'b01_0111_0000 : { dect, vik, flk } = 5'b100_1_1;  // K  - K28.5 rev
    10'b10_0100_1111 : { dect, vik, flk } = 5'b100_1_0;  // K  - K28.1
    10'b01_1011_0000 : { dect, vik, flk } = 5'b100_1_1;  // K  - K28.1 rev
    10'b10_0001_1110 : { dect, vik, flk } = 5'b111_1_0;  // V  - K30.7
    10'b01_1110_0001 : { dect, vik, flk } = 5'b111_1_1;  // V  - K30.7 rev
    
    default          : { dect, vik, flk } = 5'b001_0_0;  // Invalid K code 
  endcase

// vix         ::= Validated ten bit K symbol

assign vix = ~sync & vik
           |  sync & vik & ( flk == rdi );
           
// note: when acquiring synchronization, the disparity of received code-
// groups is not checked.  after acquiring sync, disparity is checked.           


// ------------------------------------------------------------------------
// --- Form Output Data Byte, Receive Indicator and Running Disparity

// Form the output data byte, rpd[7:0], output receive symbol indicate
// rsi[2:0] and running disparity output.

// decs[2:0]   ::= Decoded symbol indicator 
// decb[8:0]   ::= Decoded byte
// decr        ::= Running disparity input variable
// disr        ::= Running disparity output variable
// rev4s       ::= Indicates where running disparity is reversed
// vix         ::= Validated ten bit K symbol
// vid         ::= Valid ten bit data symbol

always @ ( vix or vid or decd or dect or rev4s or disr )
begin
  casex ( { vix, vid, dect } )

  5'b0_0_xxx : { decs, decb, decr } = 12'b001_00000000_0;             // Invalid
  5'b0_1_xxx : { decs, decb, decr } = { 3'b101, decd, rev4s ^ disr }; // Data
  5'b1_0_000 : { decs, decb, decr } = { dect, 8'hfb, 1'b0 };          // K27.7 /S/
  5'b1_0_010 : { decs, decb, decr } = { dect, 8'hfd, 1'b0 };          // K29.7 /T/
  5'b1_0_011 : { decs, decb, decr } = { dect, 8'hf7, 1'b0 };          // K23.7 /R/
  5'b1_0_100 : { decs, decb, decr } = { dect, 8'hbc, 1'b1 };          // K28.5 /K/
  5'b1_0_111 : { decs, decb, decr } = { dect, 8'hfe, 1'b0 };          // K30.7 /V/
  5'b1_1_xxx : { decs, decb, decr } = 12'b001_00000000_0;             // Invalid

  default : { decs, decb, decr } = 12'b001_00000000_0;                // Invalid
  endcase
end

// rpd[7:0]    ::= Receive Parallel Data

assign rpd = decb;

// rsi[2:0]    ::= Receive Symbol Indicate

assign rsi = decs;

// rdo         ::= Receive running Disparity Output indicator

//assign rdo = decr;

// ------------------------------------------------------------------------
// new disparity stuff

reg rd6p, rd6n;

always @ ( rpc[5:0] )
 case ( { rpc[5], rpc[4], rpc[3], rpc[2], rpc[1], rpc[0] } )
  6'b000000 : { rd6p, rd6n } = 2'b01;
  6'b000001 : { rd6p, rd6n } = 2'b01;
  6'b000010 : { rd6p, rd6n } = 2'b01;
  6'b000011 : { rd6p, rd6n } = 2'b01;
  6'b000100 : { rd6p, rd6n } = 2'b01;
  6'b000101 : { rd6p, rd6n } = 2'b01;
  6'b000110 : { rd6p, rd6n } = 2'b01;
  6'b000111 : { rd6p, rd6n } = 2'b10;  // special case
  6'b001000 : { rd6p, rd6n } = 2'b01;
  6'b001001 : { rd6p, rd6n } = 2'b01;
  6'b001010 : { rd6p, rd6n } = 2'b01;
  6'b001011 : { rd6p, rd6n } = 2'b00;
  6'b001100 : { rd6p, rd6n } = 2'b01;
  6'b001101 : { rd6p, rd6n } = 2'b00;
  6'b001110 : { rd6p, rd6n } = 2'b00;
  6'b001111 : { rd6p, rd6n } = 2'b10;
  6'b010000 : { rd6p, rd6n } = 2'b01;
  6'b010001 : { rd6p, rd6n } = 2'b01;
  6'b010010 : { rd6p, rd6n } = 2'b01;
  6'b010011 : { rd6p, rd6n } = 2'b00;
  6'b010100 : { rd6p, rd6n } = 2'b01;
  6'b010101 : { rd6p, rd6n } = 2'b00;
  6'b010110 : { rd6p, rd6n } = 2'b00;
  6'b010111 : { rd6p, rd6n } = 2'b10;
  6'b011000 : { rd6p, rd6n } = 2'b01;
  6'b011001 : { rd6p, rd6n } = 2'b00;
  6'b011010 : { rd6p, rd6n } = 2'b00;
  6'b011011 : { rd6p, rd6n } = 2'b10;
  6'b011100 : { rd6p, rd6n } = 2'b00;
  6'b011101 : { rd6p, rd6n } = 2'b10;
  6'b011110 : { rd6p, rd6n } = 2'b10;
  6'b011111 : { rd6p, rd6n } = 2'b10;
  6'b100000 : { rd6p, rd6n } = 2'b01;
  6'b100001 : { rd6p, rd6n } = 2'b01;
  6'b100010 : { rd6p, rd6n } = 2'b01;
  6'b100011 : { rd6p, rd6n } = 2'b00;
  6'b100100 : { rd6p, rd6n } = 2'b01;
  6'b100101 : { rd6p, rd6n } = 2'b00;
  6'b100110 : { rd6p, rd6n } = 2'b00;
  6'b100111 : { rd6p, rd6n } = 2'b10;
  6'b101000 : { rd6p, rd6n } = 2'b01;
  6'b101001 : { rd6p, rd6n } = 2'b00;
  6'b101010 : { rd6p, rd6n } = 2'b00;
  6'b101011 : { rd6p, rd6n } = 2'b10;
  6'b101100 : { rd6p, rd6n } = 2'b00;
  6'b101101 : { rd6p, rd6n } = 2'b10;
  6'b101110 : { rd6p, rd6n } = 2'b10;
  6'b101111 : { rd6p, rd6n } = 2'b10;
  6'b110000 : { rd6p, rd6n } = 2'b01;
  6'b110001 : { rd6p, rd6n } = 2'b00;
  6'b110010 : { rd6p, rd6n } = 2'b00;
  6'b110011 : { rd6p, rd6n } = 2'b10;
  6'b110100 : { rd6p, rd6n } = 2'b00;
  6'b110101 : { rd6p, rd6n } = 2'b10;
  6'b110110 : { rd6p, rd6n } = 2'b10;
  6'b110111 : { rd6p, rd6n } = 2'b10;
  6'b111000 : { rd6p, rd6n } = 2'b01;  // special case
  6'b111001 : { rd6p, rd6n } = 2'b10;
  6'b111010 : { rd6p, rd6n } = 2'b10;
  6'b111011 : { rd6p, rd6n } = 2'b10;
  6'b111100 : { rd6p, rd6n } = 2'b10;
  6'b111101 : { rd6p, rd6n } = 2'b10;
  6'b111110 : { rd6p, rd6n } = 2'b10;
  6'b111111 : { rd6p, rd6n } = 2'b10;

endcase

reg rd4p, rd4n;

always @ ( rpc[9:6] )
  case ( { rpc[9], rpc[8], rpc[7], rpc[6] } )
  4'b0000 : { rd4p, rd4n } = 2'b01;
  4'b0001 : { rd4p, rd4n } = 2'b01;
  4'b0010 : { rd4p, rd4n } = 2'b01;
  4'b0011 : { rd4p, rd4n } = 2'b10;  // special case
  4'b0100 : { rd4p, rd4n } = 2'b01;
  4'b0101 : { rd4p, rd4n } = 2'b00;
  4'b0110 : { rd4p, rd4n } = 2'b00;
  4'b0111 : { rd4p, rd4n } = 2'b10;
  4'b1000 : { rd4p, rd4n } = 2'b01;
  4'b1001 : { rd4p, rd4n } = 2'b00;
  4'b1010 : { rd4p, rd4n } = 2'b00;
  4'b1011 : { rd4p, rd4n } = 2'b10;
  4'b1100 : { rd4p, rd4n } = 2'b01;  // special case
  4'b1101 : { rd4p, rd4n } = 2'b10;
  4'b1110 : { rd4p, rd4n } = 2'b10;
  4'b1111 : { rd4p, rd4n } = 2'b10;

endcase

reg drdo, srdo;

always @ ( rdi or rd6p or rd6n or rd4p or rd4n  )
 casex ( { rdi, rd6p, rd6n, rd4p, rd4n } )

  5'b0_0000 : { drdo, srdo } = 2'b00; // D25.1  D19.1  
  5'b1_0000 : { drdo, srdo } = 2'b01; // D25.1  D19.1  
  5'bx_1000 : { drdo, srdo } = 2'b10; // D29.2  D7.1
  5'bx_0100 : { drdo, srdo } = 2'b00; // D7.1   D2.5
  
  5'bx_xx10 : { drdo, srdo } = 2'b10; // D25.0  D10.3
 
  5'bx_xx01 : { drdo, srdo } = 2'b00; // D7.3   D29.3

  default :   { drdo, srdo } = 2'b00; 
endcase

assign rdo = drdo | srdo;


endmodule

//=============================================================================
// Revision History:  
// $Log: r10b8b.v,v $
// Revision 1.1  2013/09/02 09:21:00  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================

