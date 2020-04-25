//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// DESCRIPTION : TBI Receive Exchange PCS module
// FILE        : $Source: /opt/cvs/dip/tsmac/msgmii/rtl/perex_pcs.v,v $
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

// The PEREX_PCS module contains the Synchronization and Receive state 
// machines as outlined in Clause 36 of IEEE 802.3z.  The PEREX_PMA module
// passes aligned two-code-group wide data clocked at 62.5 MHz into the
// PEREX_PCS.  In TBI mode, synchronization is first acquired by examining
// the code groups being received.  The two code-groups are passed through
// parallel 10B8B decode sub-modules.  Once several valid code groups with
// some of them containing the 'comma' are detected, synchronization is
// acquired.  Now, the decoded code-groups are inspected by the Receive
// logic.  When in Auto-Negotiation mode as indicated by the Transmit
// variable (XMIT[1:0]), the PEREX_PCS module looks for Configuration 
// ordered_sets and passes the Receive Configuration Register contents to
// the PEANX module.  After Auto-Negotiation completes, packets can be
// sent across the link.  The Received logic removes the encapsulation
// codes and passed the received packet on via the G/MII.  The GMII, it
// should be noted, is twice as wide and half as fast as it leaves the
// PEREX_PCS module.  It is sent to the PEREX_EF module to go through
// an elasticity FIFO as emerge on the Transmit 125 MHz domain one byte
// wide.  This alleviates the need for a 2x PLL running at a breezy 
// 125 MHz. In G/MII mode, the GMII signal set is passed through untouched. 


// ------------------------------------------------------------------------
// --- Module Definition

module CoreMACFilter_perex_pcs_fltr
(
  pma_rx_clk0, 
  rdcg,
  rdcerr,
  sdet,
  ewrap,
  xmit,
  miim,
  drrd,
  loopb,
  srrex0,
  anen,

  sync,
  rudidl,
  rudinv,
  rudcfg,
  rxcr,
  irxdv,
  irxd,
  irxer
);


// ------------------------------------------------------------------------
// --- Port Declarations

input         pma_rx_clk0;
input  [19:0] rdcg;
input         rdcerr;
input         sdet;
input         ewrap;
input   [1:0] xmit;
input         miim;
input         drrd;
input         loopb;
input         srrex0;
input         anen;

output        sync;
output        rudidl;
output        rudinv;
output        rudcfg;
output [15:0] rxcr;
output  [1:0] irxdv;
output [15:0] irxd;
output  [1:0] irxer;

reg           sync;
wire          rudidl;
wire          rudinv;
reg           rudcfg;
reg    [15:0] rxcr;
reg     [1:0] irxdv;
reg    [15:0] irxd;
reg     [1:0] irxer;


// ------------------------------------------------------------------------
// --- Port Descriptions

// Inputs

// pma_rx_clk0 ::= PMA Receive Clock 0, 62.5 MHz, split phase

// rdcg[19:0]  ::= Receive Dual Code Group
// rdcerr      ::= Receive Dual Code Error
// sdet        ::= Signal Detect

// ewrap       ::= Enable Wrap Mode ( PMA Loopback, i.e. SERDES Loopback )

// xmit[1:0]   ::= Transmit variable
//                   00 = CONFIGURATION
//                   01 = IDLE
//                   10 = DATA
//                   11 = unused

// miim        ::= MII mode
//                   0 = TBI mode
//                   1 = G/MII mode

// drrd        ::= Disable Receive Running Disparity

// loopb       ::= Loopback

// srrex0      ::= Synchronized Reset pma_rx_clk0 domain

// anen        ::= AutoNegotiation Enable


// Outputs

// sync        ::= Synchronization

// rudidl      ::= Receive Unit Data.Indicate: IDLE
// rudinv      ::= Receive Unit Data.Indicate: INVALID
// rudcfg      ::= Receive Unit Data.Indicate: CONFIGURATION
// rxcr[15:0]  ::= Receive Configuration Register

// irxdv[1:0]  ::= Intermediate G/MII Receive Data Valid
// irxd[15:0]  ::= Intermediate G/MII Receive Data
// irxer[1:0]  ::= Intermediate G/MII Receive Error


// ------------------------------------------------------------------------
// --- Parameter Declarations

parameter TP = 1;


// ------------------------------------------------------------------------
// --- Module Variables

// --- Signal Detect Synchronization

reg           rsdet,     ssdet,     ssdetd,    sdet_ch;

// rsdet       ::= Registered Signal Detect
// ssdet       ::= Synchronized Signal Detect
// ssdetd      ::= Synchronized Signal Detect Delayed
// sdet_ch     ::= Signal Detect Change

reg     [1:0] rxmit,     sxmit;

// rxmit[1:0]  ::= Registered Transmit Variable
// sxmit[1:0]  ::= Synchronized Transmit Variable


// --- Receive Disparity Calculation 

wire     [1:0] rdi;
wire           grdv;
reg            rdv;

// rdi[1:0]     ::= Go Receive Disparity Input
// grdv         ::= Go Receive Disparity Value
// rdv          ::= Receive Disparity Value


// --- R10B8B sub-module connections 

wire    [15:0] grsd;
wire     [5:0] grsi;
wire     [1:0] rdo;
wire     [1:0] gonebd;

// grsd[15:0]   ::= Go Intermediate Receive Symbol Data
// grsi[5:0]    ::= Go Receive Symbol Indicator
// rdo[1:0]     ::= Receive Disparity Output
// gonebd[1:0]  ::= Go One Bit Difference ( from K28.5 )


// --- Receive Symbol Data Pipeline

reg    [31:0] rsd;

// rsd[15:0]   ::= Receive Symbol Data

reg    [11:0] rsi;

// rsi[2:0]    ::= Receive Symbol Indicator

reg     [3:0] onebd;

// onebd        ::= One Bit Difference ( from K28.5 )


// The following 2 lines are used to fix incorrect output of
// K28.5 RSD from the 10B8B decoder when a K28.1 is being input
// Please note that the RSI output is correct.
wire       rdcg28p1;
wire [7:0] grsdf;

wire          rsi0eS,    rsi0nS;
wire          rsi0eU,    rsi0nU;
wire          rsi0eT;
wire          rsi0eR;
wire          rsi0eC,    rsi0nC;
wire          rsi0eK,    rsi0nK;
wire          rsi0eD,    rsi0nD;
wire          rsi0eV;

// rsi0eS      ::= RSI 1st Code Group == /S/
// rsi0nS      ::= RSI 1st Code Group != /S/
// rsi0eU      ::= RSI 1st Code Group == /UNKNOWN/
// rsi0nU      ::= RSI 1st Code Group != /UNKNOWN/
// rsi0eT      ::= RSI 1st Code Group == /T/
// rsi0eR      ::= RSI 1st Code Group == /R/
// rsi0eC      ::= RSI 1st Code Group == /COMMA/
// rsi0nC      ::= RSI 1st Code Group == /COMMA/
// rsi0eK      ::= RSI 1st Code Group == /K28.5/
// rsi0nK      ::= RSI 1st Code Group == /K28.5/
// rsi0eD      ::= RSI 1st Code Group == /Dx.y/
// rsi0nD      ::= RSI 1st Code Group == /Dx.y/
// rsi0eV      ::= RSI 1st Code Group == /V/

wire          rsi1eU,    rsi1nU;
wire          rsi1eT;
wire          rsi1eR,    rsi1nR;
wire          rsi1eC,    rsi1nC;
wire          rsi1eK,    rsi1nK;
wire          rsi1eD,    rsi1nD;
wire          rsi1eV;

// rsi1eU      ::= RSI 2nd Code Group == /UNKNOWN/
// rsi1nU      ::= RSI 2nd Code Group != /UNKNOWN/
// rsi1eT      ::= RSI 2nd Code Group == /T/
// rsi1eR      ::= RSI 2nd Code Group == /R/
// rsi1nR      ::= RSI 2nd Code Group != /R/
// rsi1eC      ::= RSI 2nd Code Group == /COMMA/
// rsi1nC      ::= RSI 2nd Code Group == /COMMA/
// rsi1eK      ::= RSI 2nd Code Group == /K28.5/
// rsi1nK      ::= RSI 2nd Code Group == /K28.5/
// rsi1eD      ::= RSI 2nd Code Group == /Dx.y/
// rsi1nD      ::= RSI 2nd Code Group == /Dx.y/
// rsi1eV      ::= RSI 2nd Code Group == /V/

wire          rsi2eU;
wire          rsi2eR,    rsi2nR;
wire          rsi2eK;
wire          rsi2eD;

// rsi2eU      ::= RSI 3rd Code Group == /UNKNOWN/
// rsi2eR      ::= RSI 3rd Code Group == /R/
// rsi2nR      ::= RSI 3rd Code Group != /R/
// rsi2eK      ::= RSI 3rd Code Group == /K28.5/
// rsi2eD      ::= RSI 3rd Code Group == /Dx.y/

wire          rsi3eU;
wire          rsi3eR;
wire          rsi3eK;

// rsi3eU      ::= RSI 4th Code Group == /UNKNOWN/
// rsi3eR      ::= RSI 4th Code Group == /R/
// rsi3eK      ::= RSI 4th Code Group == /K28.5/


wire          cgbad,     cggood;

// cgbad       ::= Code Group Bad
// cggood      ::= Code Group Good

wire    [1:0] ggood_cgs;
reg     [1:0] good_cgs;

// ggood_cgs[1:0]::= Go Good Code Groups 
// good_cgs[1:0] ::= Good Code Groups 

wire          gce1,      gce2,      gce3;

// gce1        ::= Good Codes == 1 
// gce2        ::= Good Codes == 2 
// gce3        ::= Good Codes == 3 


// --- Synchronization State Machine

wire          lback;

// lback       ::= Internal Loopback variable

wire          gloss_sync;
reg           loss_sync;

// gloss_sync  ::= Go Loss of Sync state
// loss_sync   ::= Loss of Sync state

wire          gacq_sync_1,          gacq_sync_2;

// gacq_sync_1 ::= Go Acquire Sync 1 state
// gacq_sync_2 ::= Go Acquire Sync 2 state

reg           acq_sync_1,           acq_sync_2;

// acq_sync_1  ::= Acquire Sync 1 state
// acq_sync_2  ::= Acquire Sync 2 state

wire          gsync_acq_1;
reg           sync_acq_1;

// gsync_acq_1 ::= Go Sync Acquired 1 state
// sync_acq_1  ::= Sync Acquired 1 state

wire          gsync_acq_2,          gsync_acq_2a;
wire          gsync_acq_3,          gsync_acq_3a;
wire          gsync_acq_4,          gsync_acq_4a;

// gsync_acq_2 ::= Go Sync Acquired 2 state
// gsync_acq_2a::= Go Sync Acquired 2a state
// gsync_acq_3 ::= Go Sync Acquired 3 state
// gsync_acq_3a::= Go Sync Acquired 3a state
// gsync_acq_4 ::= Go Sync Acquired 4 state
// gsync_acq_4a::= Go Sync Acquired 4a state

reg           sync_acq_2,           sync_acq_2a;
reg           sync_acq_3,           sync_acq_3a;
reg           sync_acq_4,           sync_acq_4a;

// sync_acq_2  ::= Sync Acquired 2 state
// sync_acq_2a ::= Sync Acquired 2a state
// sync_acq_3  ::= Sync Acquired 3 state
// sync_acq_3a ::= Sync Acquired 3a state
// sync_acq_4  ::= Sync Acquired 4 state
// sync_acq_4a ::= Sync Acquired 4a state

wire          gsync;

// gsync       ::= Go Synchronization


// --- xmit Decodes

wire          xmitC,     xmitI,     xmitD,     xmitnD;

// xmitC       ::= xmit Configuration
// xmitI       ::= xmit Idle
// xmitD       ::= xmit Data
// xmitnD      ::= xmit not Data

// --- Receive PCS State Machine, part a

wire          glk_fail;
reg           lk_fail;

// glk_fail    ::= Go Link Fail state
// lk_fail     ::= Link Fail state

wire          gwait_k;
reg           wait_k;

// gwait_k     ::= Go Wait_for_K state
// wait_k      ::= Wait_for_K state

wire          gidle_d;
reg           idle_d;

// gidle_d     ::= Go Idle_D state
// idle_d      ::= Idle_D state

wire          gfls_car;
reg           fls_car;

// gfls_car    ::= Go False_Carrier state
// fls_car     ::= False_Carrier state

wire          grx_cb;
reg           rx_cb;

// grx_cb      ::= Go Rx_CB state
// rx_cb       ::= Rx_CB state

wire          grx_cd;
reg           rx_cd;

// grx_cd      ::= Go Rx_CD state
// rx_cd       ::= Rx_CD state

wire          grx_inv;
reg           rx_inv;

// grx_inv     ::= Go Rx_Invalid state
// rx_inv      ::= Rx_Invalid state

wire          grudcfg;
wire   [15:0] grxcr;

// grudcfg     ::= Go Receive Configuration
// grxcr[15:0] ::= Go Receive Configuration Register


// --- Receive PCS State Machine, part b

wire          gsop;
reg           sop;

// gsop        ::= Go Start_of_Packet state
// sop         ::= Start_of_Packet state

wire          grx;
reg           rx;

// grx         ::= Go Receive
// rx          ::= Receive

wire          grx_dat;
reg           rx_dat;

// grx_dat     ::= Go Rx_Data state
// rx_dat      ::= Rx_Data state

wire          grx_err;
reg           rx_err;

// grx_err     ::= Go Rx_Data_Error state
// rx_err      ::= Rx_Data_Error state

wire          gear_end;
reg           ear_end;

// gear_end    ::= Go Early_End state
// ear_end     ::= Early_End state

wire          gtri_rri;
reg           tri_rri;

// gtri_rri    ::= Go TRI+RRI state
// tri_rri     ::= TRI+RRI state

wire          gtrr_ext;
reg           trr_ext;

// gtrr_ext    ::= Go TRR+Extend state
// trr_ext     ::= TRR+Extend state

wire          gear_end_ext;
reg           ear_end_ext;

// gear_end_ext::= Go Early_End_Ext state
// ear_end_ext ::= Early_End_Ext state


// --- Internal GMII Signals

wire    [1:0] girxdv;

// girxdv[1:0] ::= Go Intermediate Receive Data Valid

wire    [1:0] ienc_err,  girxer;

// ienc_err[1:0]::= Intermediate Encode Error
// girxer[1:0]  ::= Go Intermediate G/MII Receive Error

wire   [15:0] girxd;

// girxd[15:0] ::= Go Intermediate G/MII Receive Data

reg           anen_p1;
reg           anen_p2;

// anen_p1     ::= Autonegotiation pipeline 1
// anen_p2     ::= Autonegotiation pipeline 2


// ------------------------------------------------------------------------
// --- Logic

// ------------------------------------------------------------------------
// --- Signal Detect Synchronization

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsdet :: Registered Signal Detect

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rsdet <= #TP 1'b0;
else                              rsdet <= #TP sdet;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ssdet :: Synchronized Signal Detect

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                ssdet <= #TP 1'b0;
else                              ssdet <= #TP rsdet;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ssdetd :: Synchronized Signal Detect Delayed

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                ssdetd <= #TP 1'b0;
else                              ssdetd <= #TP ssdet;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// sdet_ch :: Signal Detect Change

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sdet_ch <= #TP 1'b0;
else                              sdet_ch <= #TP ssdet ^ ssdetd
                                               | rdcerr;
end


// ------------------------------------------------------------------------
// --- Transmit Variable Synchronization

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rxmit[1:0] :: Registered Transmit Variable

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rxmit[1:0] <= #TP 2'b00;
else                              rxmit[1:0] <= #TP xmit[1:0];
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// sxmit[1:0] :: Synchronized Transmit Variable

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sxmit[1:0] <= #TP 2'b00;
else                              sxmit[1:0] <= #TP rxmit[1:0];
end




// ------------------------------------------------------------------------
// --- Receive Running Disparity Calculator

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rdi[1:0] :: Receive Disparity Input

assign rdi[0] = ~drrd & rdv;

assign rdi[1] = ~drrd & rdo[0];

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grdv :: Go Receive Disparity Value

assign grdv = ~drrd & rdo[1];

// rdv :: Receive Disparity Value

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rdv <= #TP 1'b0;
else                              rdv <= #TP grdv;
end


// ------------------------------------------------------------------------
// --- Receive 10B8B Decoding

// R10B8B sub-module instantiations

CoreMACFilter_r10b8b r10b8b_0
( 
  .rps(rdcg[9:0]),    .rdi(rdi[0]),     .sync(sync),
  .rpd(grsdf[7:0]),   .rsi(grsi[2:0]),  .rdo(rdo[0]),   .onebd(gonebd[0])
);

CoreMACFilter_r10b8b r10b8b_1
( 
  .rps(rdcg[19:10]),  .rdi(rdi[1]),     .sync(sync),
  .rpd(grsd[15:8]),   .rsi(grsi[5:3]),  .rdo(rdo[1]),   .onebd(gonebd[1])
);

assign rdcg28p1  = (rdcg[9:0] == 10'h27c) | (rdcg[9:0] == 10'h183);
  
assign grsd[7:0] =   ( {8{  rdcg28p1 }} & 8'h3c )
                   | ( {8{ ~rdcg28p1 }} & grsdf[7:0] );

// ------------------------------------------------------------------------
// --- Receive Symbol Data Pipeline

// A four-byte pipeline of decoded data is created for the examination of
// several code-groups at once.  

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsd[31:0] :: Receive Symbol Data

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rsd[31:0] <= #TP 32'h0;
else                              rsd[31:0] <= #TP {grsd[15:0],rsd[31:16]};
end


// ------------------------------------------------------------------------
// --- Receive Symbol Indicator Pipeline

// A four-symbol pipeline of decoded symbols is created for the examination
// of several code-groups at once.  

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsi[5:0] :: Receive Symbol Indicator

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rsi[11:0] <= #TP 12'h0;
else                              rsi[11:0] <= #TP {grsi[5:0],rsi[11:6]};
end


// ------------------------------------------------------------------------
// --- One Bit Difference Pipeline

// A four-bit pipeline of 'one bit difference' indicators is created for 
// the examination of several code-groups at once.  

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// onebd[3:0] :: One Bit Difference

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                onebd[3:0] <= #TP 4'h0;
else                              onebd[3:0] <= #TP { gonebd[1:0],
                                                       onebd[3:2] };
end


// ------------------------------------------------------------------------
// rsi :: Receive Symbol Indicator Decodes
//
//   0    Start_of_Packet    - /S/
//   1    Invalid Code       - /UNKNOWN/
//   2    End_of_Packet      - /T/
//   3    Carrier_Extend     - /R/
//   4    Comma character    - /K/
//   5    Data byte          - /D/
//   6    unused
//   7    Error_Propagation  - /V/


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsi[2:0] :: Receive Symbol Indicator - 1st Rx Code Group

assign rsi0eS = rsi[2:0] == 3'b000; // /S/ Start_of_Packet
assign rsi0nS = rsi[2:0] != 3'b000;

assign rsi0eU = rsi[2:0] == 3'b001; // /UNKNOWN/
assign rsi0nU = rsi[2:0] != 3'b001;

assign rsi0eT = rsi[2:0] == 3'b010; // /T/ End_of_Packet

assign rsi0eR = rsi[2:0] == 3'b011; // /R/ Carrier_Extend

assign rsi0eC = rsi[2:0] == 3'b100; // /K28.5 or K28.1/ 
assign rsi0nC = rsi[2:0] != 3'b100;

assign rsi0eK = rsi[2:0] == 3'b100  // /K28.5/ 
              & rsd[7:0] == 8'hBC;  
assign rsi0nK = rsi[2:0] != 3'b100
              | rsd[7:0] != 8'hBC;

assign rsi0eD = rsi[2:0] == 3'b101; // /Dx.y/ Data
assign rsi0nD = rsi[2:0] != 3'b101;

assign rsi0eV = rsi[2:0] == 3'b111; // /V/ Error_Propagation

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsi[5:3] :: Receive Symbol Indicator - 2nd Rx Code Group

assign rsi1eU = rsi[5:3]   == 3'b001; // /UNKNOWN/
assign rsi1nU = rsi[5:3]   != 3'b001;

assign rsi1eT = rsi[5:3]   == 3'b010; // /T/ End_of_Packet

assign rsi1eR = rsi[5:3]   == 3'b011; // /R/ Carrier_Extend
assign rsi1nR = rsi[5:3]   != 3'b011;

assign rsi1eC = rsi[5:3]   == 3'b100; // /K28.5 or K28.1/ 
assign rsi1nC = rsi[5:3]   != 3'b100;

assign rsi1eK = rsi[5:3]   == 3'b100  // /K28.5/ 
              & rsd[15:8]  == 8'hBC;  
assign rsi1nK = rsi[5:3]   != 3'b100
              | rsd[15:8]  != 8'hBC;

assign rsi1eD = rsi[5:3]   == 3'b101; // /Dx.y/ Data
assign rsi1nD = rsi[5:3]   != 3'b101;

assign rsi1eV = rsi[5:3]   == 3'b111; // /V/ 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsi[8:6] :: Receive Symbol Indicator - 3rd Rx Code Group

assign rsi2eU = rsi[8:6]   == 3'b001; // /UNKNOWN/

assign rsi2eR = rsi[8:6]   == 3'b011; // /R/ Carrier_Extend
assign rsi2nR = rsi[8:6]   != 3'b011;

assign rsi2eK = rsi[8:6]   == 3'b100  // /K28.5/ 
              & rsd[23:16] == 8'hBC;  

assign rsi2eD = rsi[8:6]   == 3'b101; // /Dx.y/ Data

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rsi[11:9] :: Receive Symbol Indicator - 4th Rx Code Group

assign rsi3eU = rsi[11:9]  == 3'b001; // /UNKNOWN/

assign rsi3eR = rsi[11:9]  == 3'b011; // /R/ Carrier_Extend

assign rsi3eK = rsi[11:9]  == 3'b100  // /K28.5/ 
              & rsd[31:24] == 8'hBC;  


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// cgbad :: Code Group Bad

assign cgbad  = rsi0eU;

// cggood :: Code Group Good

assign cggood = ~cgbad;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ggood_cgs :: Go Good Code Groups

assign ggood_cgs = 
  { 2 { sync_acq_1  & rsi0eU & rsi1nU & rsi1nC } } & 2'b01 // gsa2a : sa1
| { 2 { sync_acq_2  & rsi0nU & rsi1nU & rsi1nC } } & 2'b10 // gsa2a : sa2
| { 2 { sync_acq_2  & rsi0eU & rsi1nU & rsi1nC } } & 2'b01 // gsa3a : sa2
| { 2 { sync_acq_3  & rsi0nU & rsi1nU & rsi1nC } } & 2'b10 // gsa3a : sa3
| { 2 { sync_acq_3  & rsi0eU & rsi1nU & rsi1nC } } & 2'b01 // gsa4a : sa3
| { 2 { sync_acq_4  & rsi0nU & rsi1nU & rsi1nC } } & 2'b10 // gsa4a : sa4

| { 2 { sync_acq_2a & rsi0nU & rsi1nU & rsi1nC & gce1 } } & 2'b11 // gsa2a : sa2a
| { 2 { sync_acq_2a & rsi0eU & rsi1nU & rsi1nC        } } & 2'b01 // gsa3a : sa2a
| { 2 { sync_acq_3a & rsi0nU & rsi1nU & rsi1nC & gce1 } } & 2'b11 // gsa3a : sa3a
| { 2 { sync_acq_3a & rsi0nU & rsi1nU & rsi1nC & gce3 } } & 2'b01 // gsa2a : sa3a
| { 2 { sync_acq_3a & rsi0eU & rsi1nU & rsi1nC        } } & 2'b01 // gsa4a : sa3a
| { 2 { sync_acq_4a & rsi0nU & rsi1nU & rsi1nC & gce1 } } & 2'b11 // gsa4a : sa4a
| { 2 { sync_acq_4a & rsi0nU & rsi1nU & rsi1nC & gce3 } } & 2'b01;// gsa3a : sa4a
                 

// good_cgs[1:0] :: Good Code Groups

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                good_cgs <= #TP 2'b00;
else                              good_cgs <= #TP ggood_cgs;
end

// good_cgs[1:0] Decodes

assign gce1 = good_cgs == 2'b01;
assign gce2 = good_cgs == 2'b10;
assign gce3 = good_cgs == 2'b11;


// ------------------------------------------------------------------------
// --- Synchronization State Machine

// Signal Detect is ignore when in one of two loopback modes, either SERDES
// loopback or PCS loopback.

// lback :: Internal Loopback variable

assign lback = ewrap 
             | loopb;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gloss_sync :: Go Loss of Sync state

assign gloss_sync = sdet_ch & ~lback
                  | loss_sync   & ( ~ssdet & ~lback 
                                  | rsi0nC
                                  | rsi1nD )
                  | acq_sync_1  & ( rsi0eU 
                                  | rsi1eU
                                  | rsi1eC
                                  | rsi0eC & rsi1nD )
                  | acq_sync_2  & ( rsi0eU 
                                  | rsi1eU
                                  | rsi1eC
                                  | rsi0eC & rsi1nD )
                  | sync_acq_3  &   rsi0eU & ( rsi1eU | rsi1eC )
                  | sync_acq_3a &   rsi0eU & ( rsi1eU | rsi1eC )
                  | sync_acq_4  & ( rsi0eU 
                                  | rsi1eU 
                                  | rsi1eC )
                  | sync_acq_4a & ( rsi0eU 
                                  | rsi0nU & ( rsi1eU | rsi1eC ) & ( gce1 | gce2 ) );

// loss_sync :: Loss of Sync state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                loss_sync <= #TP 1'b1;
else                              loss_sync <= #TP gloss_sync;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gacq_sync_1 :: Go Acquire Sync 1 state

assign gacq_sync_1 = ( ssdet & ~sdet_ch 
                     | lback )
                   & ( loss_sync  & rsi0eC & rsi1eD
                     | acq_sync_1 & rsi0nC & rsi1nU & rsi1nC );

// acq_sync_1 :: Acquire Sync 1 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                acq_sync_1 <= #TP 1'b0;
else                              acq_sync_1 <= #TP gacq_sync_1;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gacq_sync_2 :: Go Acquire Sync 2 state

assign gacq_sync_2 = ( ssdet & ~sdet_ch 
                     | lback ) 
                   & ( acq_sync_1 & rsi0eC & rsi1eD
                     | acq_sync_2 & rsi0nC & rsi1nU & rsi1nC );

// acq_sync_2 :: Acquire Sync 2 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                acq_sync_2 <= #TP 1'b0;
else                              acq_sync_2 <= #TP gacq_sync_2;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_1 :: Go Sync Acquired 1 state

assign gsync_acq_1 = ( ssdet & ~sdet_ch 
                     | lback ) 
                   & ( acq_sync_2  & rsi0eC & rsi1eD
                     | sync_acq_1  & rsi0nU & rsi1nU & rsi1nC
                     | sync_acq_2a & rsi0nU & rsi1nU & rsi1nC & (gce2 | gce3));

// sync_acq_1 :: Sync Acquired 1 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_1 <= #TP 1'b0;
else                              sync_acq_1 <= #TP gsync_acq_1;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_2 :: Go Sync Acquired 2 state

assign gsync_acq_2 = ( ssdet & ~sdet_ch 
                     | lback ) 
                   & ( sync_acq_1  & rsi0nU & ( rsi1eU | rsi1eC )
                     | sync_acq_2a & rsi0nU & ( rsi1eU | rsi1eC ) & gce3
                     | sync_acq_3a & rsi0nU & rsi1nU & rsi1nC     & gce2 );

// sync_acq_2 :: Sync Acquired 2 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_2 <= #TP 1'b0;
else                              sync_acq_2 <= #TP gsync_acq_2;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_2a :: Go Sync Acquired 2a state

assign gsync_acq_2a = ( ssdet & ~sdet_ch 
                      | lback ) 
                    & ( sync_acq_1  & rsi0eU & rsi1nU & rsi1nC
                      | sync_acq_2  & rsi0nU & rsi1nU & rsi1nC
                      | sync_acq_2a & rsi0nU & rsi1nU & rsi1nC & gce1
                      | sync_acq_3a & rsi0nU & rsi1nU & rsi1nC & gce3 );

// sync_acq_2a :: Sync Acquired 2a state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_2a <= #TP 1'b0;
else                              sync_acq_2a <= #TP gsync_acq_2a;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_3 :: Go Sync Acquired 3 state

assign gsync_acq_3 = ( ssdet & ~sdet_ch 
                     | lback ) 
                   & ( sync_acq_1  & rsi0eU & ( rsi1eU | rsi1eC )
                     | sync_acq_2  & rsi0nU & ( rsi1eU | rsi1eC )
                     | sync_acq_2a & rsi0nU & ( rsi1eU | rsi1eC ) & ( gce1 | gce2 )
                     | sync_acq_3a & rsi0nU & ( rsi1eU | rsi1eC ) & gce3
                     | sync_acq_4a & rsi0nU & rsi1nU   & rsi1nC   & gce2 );

// sync_acq_3 :: Sync Acquired 3 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_3 <= #TP 1'b0;
else                              sync_acq_3 <= #TP gsync_acq_3;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_3a :: Go Sync Acquired 3a state

assign gsync_acq_3a = ( ssdet & ~sdet_ch 
                      | lback ) 
                    & ( sync_acq_2  & rsi0eU & rsi1nU & rsi1nC
                      | sync_acq_2a & rsi0eU & rsi1nU & rsi1nC
                      | sync_acq_3  & rsi0nU & rsi1nU & rsi1nC
                      | sync_acq_3a & rsi0nU & rsi1nU & rsi1nC & gce1
                      | sync_acq_4a & rsi0nU & rsi1nU & rsi1nC & gce3 );

// sync_acq_3a :: Sync Acquired 3a state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_3a <= #TP 1'b0;
else                              sync_acq_3a <= #TP gsync_acq_3a;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_4 :: Go Sync Acquired 4 state

assign gsync_acq_4 = ( ssdet & ~sdet_ch 
                     | lback ) 
                   & ( sync_acq_2  & rsi0eU & ( rsi1eU | rsi1eC )
                     | sync_acq_2a & rsi0eU & ( rsi1eU | rsi1eC ) 
                     | sync_acq_3  & rsi0nU & ( rsi1eU | rsi1eC )
                     | sync_acq_3a & rsi0nU & ( rsi1eU | rsi1eC ) & ( gce1 | gce2 )
                     | sync_acq_4a & rsi0nU & ( rsi1eU | rsi1eC ) & gce3 );

// sync_acq_4 :: Sync Acquired 4 state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_4 <= #TP 1'b0;
else                              sync_acq_4 <= #TP gsync_acq_4;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync_acq_4a :: Go Sync Acquired 4a state

assign gsync_acq_4a = ( ssdet & ~sdet_ch 
                      | lback ) 
                    & ( sync_acq_3  & rsi0eU & rsi1nU & rsi1nC
                      | sync_acq_3a & rsi0eU & rsi1nU & rsi1nC
                      | sync_acq_4  & rsi0nU & rsi1nU & rsi1nC
                      | sync_acq_4a & rsi0nU & rsi1nU & rsi1nC & gce1 );

// sync_acq_4a :: Sync Acquired 4a state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync_acq_4a <= #TP 1'b0;
else                              sync_acq_4a <= #TP gsync_acq_4a;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsync :: Go Synchronization

assign gsync = ~sync &  gsync_acq_1
             |  sync & ~gloss_sync;

// sync :: Sychronization

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sync <= #TP 1'b0;
else                              sync <= #TP gsync;
end


// ------------------------------------------------------------------------
// --- xmit Decodes

// xmitC :: Synchronized Transmit Variable Configuration

assign xmitC  = sxmit[1:0] == 2'b00;

// xmitI :: Synchronized Transmit Variable Idle

assign xmitI  = sxmit[1:0] == 2'b01;

// xmitD :: Synchronized Transmit Variable Data

assign xmitD  = (sxmit[1:0] == 2'b10) | ~anen_p2;

// xmitD :: Synchronized Transmit Variable not Data

assign xmitnD = ~xmitD;


// ------------------------------------------------------------------------
// --- Receive PCS State Machine, part a

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// glk_fail :: Go Link Fail state

assign glk_fail = ~lk_fail & ~gsync
                |  lk_fail & ~gsync;

// lk_fail :: Link Fail state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                lk_fail <= #TP 1'b0;
else                              lk_fail <= #TP glk_fail;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gwait_k :: Go Wait_for_K state

assign gwait_k = sync 
               & ( lk_fail & rsi0nK
                 | rx_inv & rsi0nK
                 | wait_k & rsi0nK );

// wait_k :: Wait_for_K state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                wait_k <= #TP 1'b1;
else                              wait_k <= #TP gwait_k;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gidle_d :: Go Idle_D state

assign gidle_d = sync
& (           xmitnD & rsi0eK & rsi1eD & rsd[15:8] != 8'hB5 & rsd[15:8] != 8'h42
  |           xmitD  & rsi0eK          & rsd[15:8] != 8'hB5 & rsd[15:8] != 8'h42 
  | idle_d  & xmitnD & ( rsi0eK 
                       | onebd[0] ) & rsi1eD & rsd[15:8] != 8'hB5 & rsd[15:8] != 8'h42 
  | idle_d  & xmitD  & ( rsi0eK 
                       | onebd[0] )          & rsd[15:8] != 8'hB5 & rsd[15:8] != 8'h42 
  | fls_car          & rsi0eK
  | ear_end & rsi0eK );

// idle_d :: Idle_D state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                idle_d <= #TP 1'b0;
else                              idle_d <= #TP gidle_d;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rudidl :: Receive Unit Data.Indicate: Idle

assign rudidl = idle_d;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx_cb :: Go Rx_CB state

assign grx_cb = sync
              & ( wait_k  & ( rsi0eK 
                            | onebd[0] ) & rsi1eD & ( rsd[15:8] == 8'hB5 
                                                    | rsd[15:8] == 8'h42 ) 
                | idle_d  & ( rsi0eK 
                            | onebd[0] ) & rsi1eD & ( rsd[15:8] == 8'hB5 
                                                    | rsd[15:8] == 8'h42 ) 
                | rx_cd   & ( rsi0eK 
                            | onebd[0] ) & rsi1eD & ( rsd[15:8] == 8'hB5 
                                                    | rsd[15:8] == 8'h42 ) 
                | rx_inv  & ( rsi0eK 
                            | onebd[0] ) & rsi1eD & ( rsd[15:8] == 8'hB5 
                                                    | rsd[15:8] == 8'h42 ) 
                | tri_rri & ( rsi0eK 
                            | onebd[0] ) & rsi1eD & ( rsd[15:8] == 8'hB5 
                                                    | rsd[15:8] == 8'h42 ) );

// rx_cb :: Rx_CB state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx_cb <= #TP 1'b0;
else                              rx_cb <= #TP grx_cb;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx_cd :: Go Rx_CD state

assign grx_cd = sync
              & ( rx_cb & rsi0eD & rsi1eD
                | ear_end & rsi0eD );

// rx_cd :: Rx_CD state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx_cd <= #TP 1'b0;
else                              rx_cd <= #TP grx_cd;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grudcfg :: Go Receive Config_Reg

assign grudcfg = grx_cd;

// rudcfg :: Receive Config_Reg

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rudcfg <= #TP 1'b0;
else                              rudcfg <= #TP grudcfg;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grxcr[15:0] :: Go Receive Config_Reg

assign grxcr[15:0] = { 16 {  grx_cd } } & { rsd[15:0] }
                   | { 16 { ~grx_cd } } & { rxcr[15:0] };

// rxcr[15:0] :: Receive Config_Reg

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rxcr[15:0] <= #TP 16'h0;
else                              rxcr[15:0] <= #TP grxcr[15:0];
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx_inv :: Go Rx_Invalid state

assign grx_inv = lk_fail
               | sync & ( idle_d & xmitnD & ( rsi0nK | rsi1nD | rdcerr )
                        | rx_cb  &          ( rsi0nD | rsi1nD | rdcerr )
                        | rx_cd  & ( rsi0nK | rsi0eU | rsi1eU ) );

// rx_inv :: Rx_Invalid state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx_inv <= #TP 1'b0;
else                              rx_inv <= #TP grx_inv;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// rudinv :: Receive Unit Data.Indicate: Invalid

assign rudinv = rx_inv;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gfls_car :: Go False_Carrier state

assign gfls_car = idle_d  & xmitD & rsi0nK & ~onebd[0] & rsi0nS
                | fls_car         & rsi0nK;


// fls_car :: False_Carrier state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                fls_car <= #TP 1'b0;
else                              fls_car <= #TP gfls_car;
end


// ------------------------------------------------------------------------
// --- Receive PCS State Machine, part b

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gsop :: Go Start_of_Packet state

assign gsop = idle_d & xmitD & rsi0nK & ~onebd[0] & rsi0eS;

// sop :: Start_of_Packet state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                sop <= #TP 1'b0;
else                              sop <= #TP gsop;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx :: Go Receive

assign grx = sync &
           ( gsop
           | rx & ( grx_dat | grx_err ) & ~gear_end_ext );

// rx :: Receive

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx <= #TP 1'b0;
else                              rx <= #TP grx;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx_dat :: Go Rx_Data state

assign grx_dat = sync & rx & rsi0eD & rsi1eD;

// rx_dat :: Rx_Data state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx_dat <= #TP 1'b0;
else                              rx_dat <= #TP grx_dat;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// grx_err :: Go Rx_Data_Error state

assign grx_err = sync & rx 
               & ( ~grx_dat & ~gear_end & ~gtri_rri & ~gtrr_ext
                 | rsi0eV 
                 | rsi1eV );

// rx_err :: Rx_Data_Error state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                rx_err <= #TP 1'b0;
else                              rx_err <= #TP grx_err;
end


// UNH 36.3.3 End of Packet combinations
//
//       EVEN  ODD  EVEN  ODD
//EPD1         /T/   /R/  /R/
//EPD2    /T/  /R/   /K/  /D/
//
//EPD3         /T/   /R/  /K/
//
//EPD4         /T/  /!R/  /R/
//EPD5    /T/  /!R/  /K/  /D/
//EPD6         /T/   /R/  /!R/
//EPD7    /T/  /R/  /!K/  /D/
//
//EPD8    /R/  /R/   /R/  /D/
//EPD9         /R/   /R/  /R/
//
//EPD10   /K/  /D/   /K/  /D/
//EPD11   /K/  /D/  /D0/  /D/    (/C/)
//EPD12   /K/  /D/  /D0/  /D/    (/C/)


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gear_end :: Go Early_End state

assign gear_end = sync & rx 
                & ( rsi0eK & rsi1eD & rsi2eK
                  | rsi0eK & rsi1eD & ( rsd[15:8]  == 8'hB5 
                                      | rsd[15:8]  == 8'h42 )
                           & rsi2eD &   rsd[23:16] == 8'h00 );

// ear_end :: Early_End state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                ear_end <= #TP 1'b0;
else                              ear_end <= #TP gear_end;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gtri_rri :: Go TRI+RRI state

assign gtri_rri = sync 
                & (  rx & rsi0eT & rsi1eR & rsi2eK 
                  | ~rx & rsi0eR & rsi1eR
                  |  trr_ext & rsi0eR & rsi1eR & rsi2eK
                  |  tri_rri & rsi0nK );

// tri_rri :: TRI+RRI state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                tri_rri <= #TP 1'b0;
else                              tri_rri <= #TP gtri_rri;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gtrr_ext :: Go TRR+Extend state

assign gtrr_ext = sync
                & (( rx & rsi1eT & rsi2eR & rsi3eR ) | 
                   ( rx & rsi0eT & rsi1eR & rsi2eR ) );

// trr_ext :: TRR+Extend state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                trr_ext <= #TP 1'b0;
else                              trr_ext <= #TP gtrr_ext;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// gear_end_ext :: Go Early_End_Ext state

//- assign gear_end_ext = sync
//-                 & ( rx & rsi0eR & rsi1eR & rsi2eR 
//-                   | rx          & rsi1eR & rsi2eR & rsi3eR );

assign gear_end_ext = sync
                & ( rx & rsi0eR & rsi1eR & rsi2eR) |
                  ( rx & rsi1eR & rsi2eR & rsi3eR & ~rsi0eT);


// ear_end_ext :: Early_End_Ext state

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                ear_end_ext <= #TP 1'b0;
else                              ear_end_ext <= #TP gear_end_ext;
end

// ------------------------------------------------------------------------
// --- Internal GMII Signals

// ienc_err[1:0] :: Internal Encode Error

assign ienc_err[1] = gfls_car                           // 2-bit diff
                   | grx_err & rsi1eV                   // /V/
                   | grx_err & rsi3eU                   //
                   | grx_err & rsi1eT & rsi2eR & rsi3eK // /T/R/K (odd)
                   | grx_err & rsi1eT & rsi2nR & rsi3eR // /T/!R/R
                   | grx_err & rsi0eT & rsi1nR & rsi2eK // /T/!R/K
                                                        // /K/D/D/
                   | gtrr_ext;                          // /T/R/R/ (extend)

assign ienc_err[0] = gfls_car                           // 2-bit diff
                   | grx_err & rsi0eV                   // /V/
                   | grx_err & rsi2eU                   //
                   | grx_err & rsi1eT & rsi2eR & rsi3eK // TRK (odd)
                   | gear_end & ~ear_end                // /K/D/K/
                                                        // /K/D/D/
                   | gtrr_ext & rsi0eT                  // /T/R/R/ (extend)
                   | gear_end_ext;                      // /R/R/R/


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// girxer[1:0] :: Go Internal Receive Error

assign girxer[1] = ~miim & ienc_err[1]
                 |  miim & rdcg[19];

assign girxer[0] = ~miim & ienc_err[0]
                 |  miim & rdcg[9];

// irxer[1:0] :: Internal Receive Error

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                irxer[1:0] <= #TP 2'b0;
else                              irxer[1:0] <= #TP girxer[1:0];
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// girxdv[1:0] :: Go Internal Receive Data Valid

assign girxdv[1] = ~miim 
                 & ( gsop
                   | irxdv[0] & ~( gwait_k
                                 | gidle_d
                                 | grx_cb
                                 | grx_cd
                                 | gtri_rri 
                                 | gtrr_ext
                                 | ear_end_ext ) )
                 |  miim & rdcg[18];

assign girxdv[0] = ~miim 
                 & ( gsop
                   | irxdv[0] & ~( gwait_k
                                 | gidle_d & ~( gear_end & ~ear_end )
                                 | grx_cb
                                 | grx_cd
                                 |(gtrr_ext & rsi0eT)
                                 | gtri_rri
                                 | ear_end_ext
                                 ) )
                 |  miim & rdcg[8];

// irxdv[1:0] :: Internal Receive Data Valid

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                irxdv[1:0] <= #TP 2'b0;
else                              irxdv[1:0] <= #TP girxdv[1:0];
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// girxd[15:0] :: Go Internal Receive Data

assign girxd[15:0] = 
  {  16 { ~miim & gfls_car                    } } & 16'h0E0E
| {  16 { ~miim & gsop                        } } & 16'h5555
| {  16 { ~miim & grx_dat                     } } & rsd[15:0]
| { { 8 { ~miim & rx & grx_err & ~ienc_err[1] } } & rsd[15:8],
    { 8 { ~miim & rx & grx_err & ~ienc_err[0] } } & rsd[7:0] }
| {  16 { ~miim & gtrr_ext & rsi1eT           } } & { 8'h0F, rsd[7:0] }
| {  16 { ~miim & gtrr_ext & rsi0eT           } } & { 8'h0F, 8'h0F    }
| {  16 {  miim                               } } & { rdcg[17:10], 
                                                      rdcg[7:0] };

// irxd[15:0] :: Internal Receive Data

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
     if ( srrex0 )                irxd[15:0] <= #TP 16'h0;
else                              irxd[15:0] <= #TP girxd[15:0];
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// AutoNegotiation Enable Snchronization

// anen_p1 :: AutoNegotiation Enable Pipeline 1

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                anen_p1 <= #TP 1'b0;
   else                         anen_p1 <= #TP anen;
end

// anen_p2 :: AutoNegotiation Enable Pipeline 2

always @ ( posedge pma_rx_clk0 or posedge srrex0 )
begin
   if ( srrex0 )                anen_p2 <= #TP 1'b0;
   else                         anen_p2 <= #TP anen_p1;
end

endmodule

//=============================================================================
// Revision History:  
// $Log: perex_pcs.v,v $
// Revision 1.1  2013/09/02 09:21:00  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================

