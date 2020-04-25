//===========================================================================
//             MM     MM EEEEEE NN    N TTTTTTT  OOOO    RRRRR
//             M M   M M E      N N   N    T    O    O   R    R
//             M  M M  M EEEE   N  N  N    T    O    O   RRRRR
//             M   M   M E      N   N N    T    O    O   R   R
//             M       M EEEEEE N    NN    T     OOOO    R    R
//===========================================================================
// FILENAME    : rtl\perfn_top.v
//
// DESCRIPTION : MENTOR: Receive Function
//
// REVISION    : $Revision: 1.4 $
//
// LAST UPDATE : $Date: 2013/10/10 11:03:54 $
//===========================================================================
//                   MENTOR Proprietary and Confidential
//                       Copyright (c) 2003, MENTOR
//                          All Rights Reserved
//===========================================================================

`timescale 1ns / 1ns

// ------------------------------------------------------------------------
// --- Module Description

// The PERFN_TOP module is the Receive component of a 10/100/1000 Mb/s 
// Media Access Controller.  It includes one submodule, the 8-bit PECRC.
//
// The PERFN accepts packets conveyed by a PHY device across either the
// MII or GMII.  The preamble and SFD fields are removed and the remaining
// frame is passed to the system.  Information about the received frames
// are conveyed via a 32-bit statistics vector.


// ------------------------------------------------------------------------
// --- Module Definition

module CoreMACFilter_perfn_top_fltr
(
  rx_clk,    rxcen, 
  rx_dv,     rxd,       rx_er,
  //crs,
  ptxen,
  speed,
  rxen, fulld, //    flchk,
  //hugen,
  mifg,//      maxfr,
  //rxcf,      rxpf,      rxuo,
  srrfn,    
  stad,
  //srxen,
  //rpd,       rpdv,      rpsf,      rpef,
  //rpst,      rptd,
  //rsvp,      rsv,
  hashe,     hashv, dat_d1, mcadp,
  bcad,       mcad, ucad

  //girxd_o,   irxd_o,    gdsfd_o
);

// ------------------------------------------------------------------------
// --- Port Declarations

input         rx_clk,    rxcen;
input         rx_dv;
input   [7:0] rxd;
input         rx_er;
//input         crs;
input         ptxen;
input   [1:0] speed;
input         rxen,   fulld;//    flchk;
//input         hugen;
input   [7:0] mifg;
//input  [15:0] maxfr;
//input         rxcf,      rxpf,      rxuo;
input         srrfn;
input  [47:0] stad;
//output        srxen;
//output  [7:0] rpd;
//output        rpdv,      rpsf,      rpef;
//output        rpst,      rptd;
//output        rsvp;
//output [32:0] rsv;
output        hashe;
output  [8:0] hashv;
output        bcad,      mcad;
output        ucad;
output        dat_d1;
output        mcadp;

//output [7:0] girxd_o;
//output [7:0] irxd_o;
//output       gdsfd_o;
reg           ucad_reg;
reg           srxen;
reg     [7:0] rpd;
reg           rpdv,      rpsf,      rpef;
reg           rpst,      rptd;
reg           rsvp;
reg    [32:0] rsv;
reg           hashe;
reg     [8:0] hashv;
reg           bcad,      mcad;
wire   gucad;


reg  bcad_d1;
wire gbcad_d1;

// ------------------------------------------------------------------------
// --- Port Descriptions

// Inputs

// rx_clk      ::= Receive Clock, 2.5 MHz @ 4 bits = 10 Mb/s
//                                 25 MHz @ 4 bits = 100 Mb/s
//                                125 MHz @ 8 bits = 1000 Mb/s

// rxcen       ::= Receive Clock Enable
//                 used in RMII, SMII and ENDEC environments

// rx_dv       ::= G/MII Receive Data Valid
// rxd[7:0]    ::= G/MII Receive Data
// rx_er       ::= G/MII Receive Error

// crs         ::= Carrier Sense
// ptxen       ::= Pre-Transmit Enable ( so own transmits are ignored )

// speed[1:0]  ::= Speed Select
//             ::= 00 = Reserved
//             ::= 01 = Nibble mode
//             ::= 10 = Byte mode
//             ::= 11 = Reserved

// rxen        ::= Receive Enable
// fulld       ::= Full Duplex mode
// flchk       ::= Frame Length Checking
// hugen       ::= Huge Frame Enable

// mifg[7:0]   ::= Minimum Inter-Frame Gap
// maxfr[15:0] ::= Maximum Frame

// rxcf        ::= Receive Control Frame
// rxpf        ::= Receive PAUSE Control Frame
// rxuo        ::= Receive Unsupported Op-code

// srrfn       ::= Synchronized Reset Receive Function


// Outputs

// srxen       ::= Synchronized Receive Enable

// rpd[7:0]    ::= Receive Packet Data
// rpdv        ::= Receive Packet Data Valid
// rpsf        ::= Receive Packet Start of Frame
// rpef        ::= Receive Packet End of Frame

// rpst        ::= Receive Packet Slot Time
// rptd        ::= Receive Packet Tag Detected

// rsvp        ::= Receive Statistics Vector Pulse
// rsv[32:0]   ::= Receive Statistics Vector

// hashe       ::= Hash Enable
// hashv[8:0]  ::= Hash Value
// bcad        ::= Broadcast Address Detected
// mcad        ::= Multicast Address Detected


// ------------------------------------------------------------------------
// --- Parameter Declarations

parameter TP = 1;                                       // simulation reset


// ------------------------------------------------------------------------
// --- Module Variable Declarations

// --- Registered G/MII Interface Signals

reg           rrx_dv, srx_dv;
reg     [7:0] rrxd;
reg           rrx_er;

// rrx_dv      ::= Registered Receive Data Valid
// srx_dv	   ::= Syn. Registered Receive Data Valid
// rrxd[7:0]   ::= Registered Receive Data
// rrx_er      ::= Registered Receive Error


// --- Internal G/MII Interface Signals

reg           irx_dv;
wire    [7:0] girxd;
reg     [7:0] irxd;
reg           irx_er;

// irx_dv      ::= Internal Receive Data Valid
// girxd[7:0]  ::= Go Internal Receive Data
// irxd[7:0]   ::= Internal Receive Data
// irx_er      ::= Internal Receive Error

wire          girxbe;
reg           irxbe;

// girxbe      ::= Go Internal Receive Byte Enable
// irbxe       ::= Internal Receive Byte Enable

// --- Pre-Transmit Enable Synchronizing

reg           rptxen,    sptxen;
wire          stxen;

// rptxen      ::= Registered Pre-Transmit Enable
// sptxen      ::= Synchronized Pre-Transmit Enable
// stxen       ::= Synchronized Transmit Enable


reg           rcrs,      rcrsd;
wire          scrs;

// rcrs        ::= Registered Carrier Sense
// rcrsd       ::= Registered Carrier Sense Delayed
// scrs        ::= Synchronized Carrier Sense Delayed

// --- Receive Enable Synchronization

reg           rrxen,     rrxend;

// rrxen       ::= Registered Receive Enable
// rrxend      ::= Registered Receive Enable Delayed


// --- Receive State Machine

wire          gvnt,      gidl,      gpre,      gsfd,      gdat;

// gvnt        ::= Go Event state
// gidl        ::= Go Idle state
// gpre        ::= Go Preamble state
// gsfd        ::= Go Start Frame Delimiter state
// gdat        ::= Go Data state

reg           vnt,       idl,       pre,       sfd,       dat, dat_d1 ;

// vnt         ::= Event state
// idl         ::= Idle state
// pre         ::= Preamble state
// sfd         ::= Start Frame Delimiter state
// dat         ::= Data state

wire          gdsfd;
reg           dsfd;

// gdsfd       ::= Go Detect Start Frame Delimiter
// dsfd        ::= Detect Start Frame Delimiter


// --- Inter-Frame Gap Counter

wire          zifgc,     iifgc;
wire    [7:0] gifgc;
reg     [7:0] ifgc;

// zifgc       ::= Zero Inter-Frame Gap Counter
// iifgc       ::= Increment Inter-Frame Gap Counter
// gifgc[7:0]  ::= Go Inter-Frame Gap Counter
// ifgc[7:0]   ::= Inter-Frame Gap Counter

wire          mifgm;

// mifgm       ::= Minimum Inter-Frame Gap Met


// --- Receive Byte Counter

wire          zrbct,     irbct;
wire   [15:0] grbct;
reg    [15:0] rbct;

// zrbct       ::= Zero Receive Byte Counter
// irbct       ::= Increment Receive Byte Counter
// grbct[15:0] ::= Go Receive Byte Counter
// rbct[15:0]  ::= Receive Byte Counter

wire          bceq0,     bceq1,     bceq2,     bceq3;

// bceq0       ::= Byte Count == 0
// bceq1       ::= Byte Count == 1
// bceq2       ::= Byte Count == 2
// bceq3       ::= Byte Count == 3

wire          bceq4,     bceq5,    bcgt5,      bceq6;

// bceq4       ::= Byte Count == 4
// bceq5       ::= Byte Count == 5
// bcgt5       ::= Byte Count >  5
// bceq6       ::= Byte Count == 6

wire          bceqc,     bceqd,                bceqf; 

// bceqc       ::= Byte Count == 12
// bceqd       ::= Byte Count == 13
// bceqf       ::= Byte Count == 15

wire          bceq10,   bceq11;

// bceq10      ::= Byte Count == 16
// bceq11      ::= Byte Count == 17
    
// --- Long Event Counter

wire          zlect,     ilect;
wire   [14:0] glect;
reg    [14:0] lect;

// zlect       ::= Zero Long Event Counter
// ilect       ::= Increment Long Event Counter
// glect[14:0] ::= Go Long Event Counter
// lect[14:0]  ::= Long Event Counter

wire          glngvnt;
reg           lngvnt;

// glngvnt     ::= Go Long Event
// lngvnt      ::= Long Event


// --- Out of Range Detect

wire		  grloor;
reg			  rloor;

// grloor	   ::= Go Receive Length Out of Range
// rloor	   ::= Receive Length Out of Range

// --- Giant Frame Detect

wire          dgiant;
reg			  giant;

// dgiant      ::= Detect Giant Frame
// giant       ::= Giant Frame

wire          gtrunc, gtrrf, dtrrf;
reg           trunc, trrf;

// gtrunc      ::= Go Truncate Frame: Giant Frame
// trunc       ::= Truncate Frame: Giant Frame
// gtrrf 	   ::= Go Truncate Receive Frame
// dtrrf 	   ::= Detect Truncate Receive Frame
// trrf 	   ::= Truncate Receive Frame




// --- Pre-Receive System Interface

wire    [7:0] gprpd;
reg     [7:0] prpd;

// gprpd[7:0]  ::= Go Pre-Receive Packet Data
// prpd[7:0]   ::= Pre-Receive Packet Data

wire          gprpdv,    gprpsf,    gprpef;

// gprpdv      ::= Go Pre-Receive Packet Data Valid
// gprpsf      ::= Go Pre-Receive Packet Start of Frame
// gprpef      ::= Go Pre-Receive Packet End of Frame

reg           prpdv,     prpsf,     prpef;

// prpdv       ::= Pre-Receive Packet Data Valid
// prpsf       ::= Pre-Receive Packet Start of Frame
// prpef       ::= Pre-Receive Packet End of Frame

reg           prpdvd;

// prpdvd      ::= Pre-Receive Packet Data Valid Delayed


// --- Receive System Interface

wire    [7:0] grpd;
wire          grpdv,     grpsf,     grpef;

// grpd[7:0]   ::= Go Receive Packet Data
// grpdv       ::= Go Receive Packet Data Valid
// grpsf       ::= Go Receive Packet Start of Frame
// grpef       ::= Go Receive Packet End of Frame

wire          grpst,     grptd;

// grpst       ::= Go Receive Packet Slot Time
// grptd       ::= Go Receive Packet Tag Detect


// --- CRC Variables

wire          gcini,     gcval,     gchld;

// gcini       ::= Go CRC Initialize
// gcval       ::= Go CRC Valid
// gchld       ::= Go CRC Hold

reg           cini,      cval,      chld;

// cini        ::= CRC Initialize
// cval        ::= CRC Valid
// chld        ::= CRC Hold

wire   [31:0] creg;
wire          cerr;

// creg[31:0]  ::= CRC Register
// cerr        ::= CRC Error


// --- Hash Table Support

wire          ghashe;
wire    [8:0] ghashv;

// ghashe      ::= Go Hash Enable
// ghashv[8:0] ::= Go Hash Value



// --- Receive Status

wire          gmcad;

// gmcad       ::= Go Multicast Address Detect

wire          gbcad;

// gbcad       ::= Go Broadcast Address Detect

wire          lulnty,    lllnty;
wire   [15:0] glnty;
reg    [15:0] lnty;

// lulnty      ::= Load Upper Length / Type Field
// lllnty      ::= Load Lower Length / Type Field
// glnty[15:0] ::= Go Length/Type Field
// lnty[15:0]  ::= Length/Type Field

wire          ltgtmax,   ltgemin;

// ltgtmax     ::= Length/Type >  Maximum Data Length ( 1500 )
// ltgemin     ::= Length/Type >  Minimum Data Length ( 46 or 42 VLAN )

wire          gvltg;
reg           vltg;

// gvltg       ::= Go VLAN Tag Detected
// vltg        ::= VLAN Tag Detected

wire   [15:0] dfbc;
wire          girle; 
reg           irle;

// dfbc[15:0]  ::= Data Frame Byte Count
// girle       ::= Go In Range Length Error
// irle        ::= In Range Length Error

wire          gcderr;
reg           cderr;

// gcderr      ::= Go Code Error
// cderr       ::= Code Error


wire          gflscar;
reg           flscar;

// gflscar     ::= Go False Carrier
// flscar      ::= False Carrier


wire          grxdvnt;
reg           rxdvnt;

// grxdvnt     ::= Go RX_DV Event
// rxdvnt      ::= RX_DV Event


wire          gdrpvnt;
reg           drpvnt;

// gdrpvnt     ::= Go Drop Event
// drpvnt      ::= Drop Event


wire          gdrbnib;
reg           drbnib;

// gdrbnib     ::= Go Dribble Nibble
// drbnib      ::= Dribble Nibble


// --- Receive Statistics

wire          grsmp;
reg           rsmp;
reg           rsmp2;

// grsmp       ::= Go Receive Sample
// rsmp        ::= Receive Sample

wire          grsvp;
wire   [32:0] grsv;

// grsvp       ::= Go Receive Statistics Vector Pulse
// grsv[32:0]  ::= Go Receive Statistics Vector

wire          gsrxen;

// gsrxen      ::= Go Synchronized Receive Enable

//Misc. o/p assignments
//  assign  girxd_o = girxd;
//  assign  irxd_o  = irxd;
//  assign  gdsfd_o = gsfd;
// ------------------------------------------------------------------------
// --- Logic

// ------------------------------------------------------------------------
// --- Registered G/MII Receive Interface

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// rrx_dv :: Registered Receive Data Valid

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rrx_dv <= #TP 1'b0;
else if ( rxcen )            rrx_dv <= #TP rx_dv; // & ~trrf;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// srx_dv :: Syn. Registered Receive Data Valid

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            srx_dv <= #TP 1'b0;
else if ( rxcen )            srx_dv <= #TP rx_dv;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// rrxd[7:0] :: Registered Receive Data

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rrxd[7:0] <= #TP 8'h0;
else if ( rxcen )            rrxd[7:0] <= #TP rxd[7:0];
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// rrx_er :: Registered Receive Error

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rrx_er <= #TP 1'b0;
else if ( rxcen )            rrx_er <= #TP rx_er;
end 


// ------------------------------------------------------------------------
// --- Internal G/MII Receive Interface

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// irx_dv :: Internal Receive Data Valid

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            irx_dv <= #TP 1'b0;
else if ( rxcen )            irx_dv <= #TP rrx_dv;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// girxd[7:0] :: Go Internal Receive Data

assign girxd[7:0] = { 8 { ~speed[1] } } & { rrxd[3:0], irxd[7:4] }
                  | { 8 {  speed[1] } } & rrxd[7:0];

// irxd[7:0] :: Internal Receive Data

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            irxd[7:0] <= #TP 8'h0;
else if ( rxcen )            irxd[7:0] <= #TP girxd[7:0];
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// irx_er :: Internal Receive Error

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            irx_er <= #TP 1'b0;
else if ( rxcen )            irx_er <= #TP rrx_er;
end 


// ------------------------------------------------------------------------
// --- Internal Receive Byte Enable

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// girxbe :: Go Internal Receive Byte Enable

assign girxbe = ~speed[1] & ( ~gdsfd 
                            |  gdsfd & irx_dv & ~irxbe )
              |  speed[1]; 

// irxbe :: Internal Receive Byte Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            irxbe <= #TP 1'b0;
else if ( rxcen )            irxbe <= #TP girxbe;
end 


// ------------------------------------------------------------------------
// --- PTXEN Synchronization to Receive Clock

// The purpose of this section is to synchronize Pre-Transmit Enable,
// ptxen, from the Transmit Function to Receive Clock, rx_clk.

// rptxen :: Registered Pre-Transmit Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rptxen <= #TP 1'b0;
else if ( rxcen )            rptxen <= #TP ptxen;
end 

// sptxen :: Synchronized Pre-Transmit Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            sptxen <= #TP 1'b0;
else if ( rxcen )            sptxen <= #TP rptxen;
end 

// stxen :: Synchronized Transmit Enable

assign stxen = ~fulld & sptxen;


// ------------------------------------------------------------------------
// --- CRS Synchronization to Receive Clock

// The purpose of this section is to synchronize Carrier Sense, crs, to
// the Receive Clock, rx_clk.

// rcrs :: Registered Carrier Sense

//Rohit//  always @ ( posedge rx_clk or posedge srrfn )
//Rohit//  begin
//Rohit//       if ( srrfn )            rcrs <= #TP 1'b0;
//Rohit//  else if ( rxcen )            rcrs <= #TP crs;
//Rohit//  end 
//Rohit//  
//Rohit//  // rcrsd :: Registered Carrier Sense Delayed
//Rohit//  
//Rohit//  always @ ( posedge rx_clk or posedge srrfn )
//Rohit//  begin
//Rohit//       if ( srrfn )            rcrsd <= #TP 1'b0;
//Rohit//  else if ( rxcen )            rcrsd <= #TP rcrs;
//Rohit//  end 
//Rohit//  
//Rohit//  // scrs :: Synchronized Carrier Sense
//Rohit//  
//Rohit//  assign scrs = rcrsd & ~fulld;


// ------------------------------------------------------------------------
// --- RXEN Synchronization to Receive Clock

// The purpose of this section is to synchronize Receive Enable, rxen,
// to Receive Clock, rx_clk.

// rrxen :: Registered Receive Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rrxen <= #TP 1'b0;
else if ( rxcen )            rrxen <= #TP rxen;
end 

// rrxend :: Registered Receive Enable Delayed

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rrxend <= #TP 1'b0;
else if ( rxcen )            rrxend <= #TP rrxen;
end 

// gsrxen :: Go Synchronized Receive Enable

assign gsrxen =  ~irx_dv & rrxend
              |   irx_dv & srxen;  

// srxen :: Synchronized Receive Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            srxen <= #TP 1'b0;
else if ( rxcen )            srxen <= #TP gsrxen;
end 


// ------------------------------------------------------------------------
// --- Receive State Machine

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Event state (vnt)

// The following are the conditions for which the state machine will
// transition to/stay in the idl state:
//
//  State   Condition
// -----------------------------------------------
//   vnt    Packet data on wire ( skipping packet )
//   idl    Packet data on wire, SFD detected, Min IFG not met
//   sfd    Packet data on wire, SFD detected, Min IFG not met
//   dat    Packet data on wire, SFD detected, Min IFG not met
//

// gvnt :: Go Event state

assign gvnt = vnt & irx_dv
            | idl & irx_dv & irxd == 8'b1101_0101 & irxbe & ~mifgm
            | pre & irx_dv & irxd == 8'b1101_0101 & irxbe & ~mifgm       
            | sfd & irx_dv & irxd == 8'b1101_0101 & irxbe & ~mifgm
            | dat & irx_dv & |irxd;

// vnt :: Event state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            vnt <= #TP 1'b1;
else if ( rxcen )            vnt <= #TP gvnt;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Idle state (idl)

// The following are the conditions for which the state machine will
// transition to/stay in the idl state:
//
//  State   Condition
// -----------------------------------------------
//   vnt    No packet data on wire
//   pre    No packet data on wire
//   sfd    No packet data on wire
//   dat    No packet data on wire
//   idl    No packet data no wire or own transmit on wire

// gidl :: Go Idle state

assign gidl = vnt &   ~irx_dv
            | pre &   ~irx_dv
            | sfd &   ~irx_dv
            | dat &   ~irx_dv
            | idl & ( ~irx_dv 
                    |  stxen 
                    | ~irxbe 
                    | ~srxen );

// idl :: Idle state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            idl <= #TP 1'b0;
else if ( rxcen )            idl <= #TP gidl;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Preamble state (pre)

// The following are the conditions for which the state machine will
// transition to/stay in the pre state:
//
//  State   Condition
// -----------------------------------------------
//   idl    Packet data on wire, data != x101_0101
//   sfd    Packet data on wire, data != x101_0101
//   pre    Packet data on wire, data != x101_0101

// gpre :: Go Preamble state

assign gpre = idl &   irx_dv & irxd[6:0] != 7'b101_0101 & irxbe & srxen
            | sfd &   irx_dv & irxd[6:0] != 7'b101_0101 & irxbe
            | pre & ( irx_dv & irxd[6:0] != 7'b101_0101 & irxbe 
                    | ~irxbe );

// pre :: Preamble state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            pre <= #TP 1'b0;
else if ( rxcen )            pre <= #TP gpre;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Start Frame Delimiter state (sfd)

// The following are the conditions for which the state machine will
// transition to/stay in the sfd state:
//
//  State   Condition
// -----------------------------------------------
//   idl    Packet data on wire, data == 0101_0101
//   pre    Packet data on wire, data == 0101_0101
//   sfd    Packet data on wire, data != 1101_0101

// gsfd :: Go Start Frame Delimiter state

assign gsfd = idl &   irx_dv & irxd == 8'b0101_0101 & irxbe & srxen
            | pre &   irx_dv & irxd == 8'b0101_0101 & irxbe
            | sfd & ( irx_dv & irxd != 8'b1101_0101 & irxbe
                    | ~irxbe );

// sfd :: Start Frame Delimiter state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            sfd <= #TP 1'b0;
else if ( rxcen )            sfd <= #TP gsfd;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gdsfd :: Go Detect Start Frame Delimiter

assign gdsfd = idl &   irx_dv & irxd == 8'b1101_0101 & srxen
             | pre &   irx_dv & irxd == 8'b1101_0101 
             | sfd &   irx_dv & irxd == 8'b1101_0101 
             | dsfd & ~idl;

// dsfd :: Start Frame Delimiter state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            dsfd <= #TP 1'b0;
else if ( rxcen )            dsfd <= #TP gdsfd;
end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Data state (dat)

// The following are the conditions for which the state machine will
// transition to/stay in the sfd state:
//
//  State   Condition
// -----------------------------------------------
//   idl    Packet data on wire, data == 1101_0101, IFG > minimum & Enabled
//   pre    Packet data on wire, data == 1101_0101, IFG > minimum
//   sfd    Packet data on wire, data == 1101_0101, IFG > minimum
//   dat    Packet data on wire

// gdat :: Go Data state

assign gdat = idl & irx_dv & irxd == 8'b1101_0101 & irxbe & mifgm & srxen
            | pre & irx_dv & irxd == 8'b1101_0101 & irxbe & mifgm       
            | sfd & irx_dv & irxd == 8'b1101_0101 & irxbe & mifgm       
            | dat & irx_dv;

// dat :: Data state

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn ) begin 
       dat <= #TP 1'b0;
       dat_d1 <= 1'b0;
     end else if ( rxcen ) begin           
       dat <= #TP gdat;
       dat_d1 <= dat;
     end 
end 


// ------------------------------------------------------------------------
// --- Inter-Frame Gap Counter

// The Inter-Frame Gap is measured by ifgc[7:0].  

// zifgc :: Zero Inter-Frame Gap Counter

assign zifgc = dat & irx_dv;

// iifgc :: Increment Inter-Frame Gap Counter

assign iifgc = ~( &ifgc[7:0] )
             & ( vnt
               | idl
               | pre
               | sfd
               | dat & ~irx_dv 
               );

// gifgc[7:0] :: Go Inter-Frame Gap Counter

assign gifgc[7:0] = { 8 { ~zifgc &  iifgc } } & ifgc[7:0] + 1'b1
                  | { 8 { ~zifgc & ~iifgc } } & ifgc[7:0];

// ifgc[7:0] :: Inter-Frame Gap Counter

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            ifgc[7:0] <= #TP 8'h0;
else if ( rxcen )            ifgc[7:0] <= #TP gifgc[7:0];
end

// IFG Counter decodes

// mifgm :: Minimum Inter-Frame Gap Met

assign mifgm = ~speed[1] & ( ifgc[7:0] >= ( mifg[7:2] - 1'b1 ) )
             |  speed[1] & ( ifgc[7:0] >= ( mifg[7:3] - 1'b1 ) );


// ------------------------------------------------------------------------
// --- Receive Byte Counter

// The length of the frame is measured by rbct[15:0].  

// zrbct :: Zero Receive Byte Counter

assign zrbct = rsvp;

// irbct :: Increment Receive Byte Counter

assign irbct = ~( &rbct[15:0] ) 
             & ( dat & irxbe & irx_dv );

// grbct[15:0] :: Go Receive Byte Counter

assign grbct[15:0] = { 16 { ~zrbct &  irbct } } & rbct[15:0] + 1'b1
                   | { 16 { ~zrbct & ~irbct } } & rbct[15:0];

// rbct[15:0] :: Receive Byte Counter

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rbct[15:0] <= #TP 16'h0;
else if ( rxcen )            rbct[15:0] <= #TP grbct[15:0];
end

// Receive Byte Counter decodes

assign bceq0  = rbct[15:0] == 16'h0000;
assign bceq1  = rbct[15:0] == 16'h0001;
assign bceq2  = rbct[15:0] == 16'h0002;
assign bceq3  = rbct[15:0] == 16'h0003;
assign bceq4  = rbct[15:0] == 16'h0004;
assign bceq5  = rbct[15:0] == 16'h0005;
assign bcgt5  = rbct[15:0] >  16'h0005;
assign bceq6  = rbct[15:0] == 16'h0006;
assign bceqc  = rbct[15:0] == 16'h000c;
assign bceqd  = rbct[15:0] == 16'h000d;
assign bceqf  = rbct[15:0] == 16'h000f;
assign bceq10 = rbct[15:0] == 16'h0010;
assign bceq11 = rbct[15:0] == 16'h0011;


/*//===== Not Required =============================//
//Rohit//   // ------------------------------------------------------------------------
//Rohit//   // --- Long Event Counter
//Rohit//   
//Rohit//   // Long Events are detected via the Long Event Counter, lect[14:0].  
//Rohit//   
//Rohit//   // zlect :: Zero Long Event Counter
//Rohit//   
//Rohit//   assign zlect = ~scrs
//Rohit//                |  rsvp;
//Rohit//   
//Rohit//   // ilect :: Increment Long Event Counter
//Rohit//   
//Rohit//   assign ilect =  scrs;
//Rohit//   
//Rohit//   // glect[14:0] :: Go Long Event Counter
//Rohit//   
//Rohit//   assign glect[14:0] = { 15 { ~zlect &  ilect } } & lect[14:0] + 1'b1
//Rohit//                      | { 15 { ~zlect & ~ilect } } & lect[14:0];
//Rohit//   
//Rohit//   // lect[14:0] :: Long Event Counter
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            lect[14:0] <= #TP 15'h0;
//Rohit//   else if ( rxcen )            lect[14:0] <= #TP glect[14:0];
//Rohit//   end
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // Long Event Detection
//Rohit//   
//Rohit//   // Jabber Protection Lockup Timer 
//Rohit//   //   50,000 bit times 10 Mb/s
//Rohit//   //   80,000 bit times 100/1000 Mb/s
//Rohit//   
//Rohit//   // glngvnt :: Go Long Event 
//Rohit//   
//Rohit//   assign glngvnt = ~lngvnt & scrs & ~speed[1] & lect[14:0] == 15'h30D4 // 12,500
//Rohit//                  | ~lngvnt & scrs &  speed[1] & lect[14:0] == 15'h186A //  6,250
//Rohit//                  |  lngvnt & ~rsvp;
//Rohit//   
//Rohit//   // lngvnt :: Long Event 
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            lngvnt <= #TP 1'b0;
//Rohit//   else if ( rxcen )            lngvnt <= #TP glngvnt;
//Rohit//   end 
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Rohit//   // dgiant :: Detect Giant Frame
//Rohit//   // If Receive Frame is truncated and RX_DV is still high, the Receive Frame is indicated as a Giant Frame.
//Rohit//   
//Rohit//   assign dgiant = trrf & srx_dv;
//Rohit//   
//Rohit//   // giant :: Giant Frame
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            giant <= #TP 1'b0;
//Rohit//   else if ( rxcen )            giant <= #TP dgiant;
//Rohit//   end
//Rohit//   
//Rohit//   // gtrunc :: Go Truncate Frame: Giant Frame
//Rohit//   
//Rohit//   assign gtrunc = ~trunc & giant & srx_dv	 
//Rohit//                 |  trunc & ~rsvp & ~rpsf;
//Rohit//   
//Rohit//   // trunc :: Truncate Frame: Giant Frame
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            trunc <= #TP 1'b0;
//Rohit//   else if ( rxcen )            trunc <= #TP gtrunc;
//Rohit//   end
//Rohit//   
//Rohit//   // dtrrf :: Detect Truncate Receive Frame
//Rohit//   // The subtraction of bytes from maxfr, are needed to account for pipeline delay
//Rohit//   // in truncating the Receive Frame.
//Rohit//   
//Rohit//   assign dtrrf = speed[0] & (rbct[15:0] == maxfr[15:0] - 1 ) & ~hugen
//Rohit//   			| speed[1] & (rbct[15:0] == maxfr[15:0] - 3 ) & ~hugen;
//Rohit//   
//Rohit//   // gtrrf :: Go Truncate Receive Frame
//Rohit//   
//Rohit//   assign gtrrf = dtrrf | trrf & srx_dv;
//Rohit//   
//Rohit//   // trrf :: Truncate Receive Frame
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//   	 if ( srrfn )			  trrf <= #TP 1'b0;
//Rohit//   else if ( rxcen )             trrf <= #TP gtrrf;
//Rohit//   end
//Rohit//   *///===== Not Required =============================//
//Rohit//   
//Rohit//   // ------------------------------------------------------------------------
//Rohit//   // --- Pre-Receive System Interface
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // gprpd[7:0] :: Go Pre-Receive Packet Data

//Rohit//   assign gprpd[7:0] = { 8 { dat &  irxbe } } & irxd[7:0]
//Rohit//                     | { 8 { dat & ~irxbe } } & rpd[7:0];
//Rohit//   
//Rohit//   // prpd[7:0] :: Pre-Receive Packet Data
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            prpd[7:0] <= #TP 8'h0;
//Rohit//   else if ( rxcen )            prpd[7:0] <= #TP gprpd[7:0];
//Rohit//   end 
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // gprpdv :: Go Pre-Receive Packet Data Valid
//Rohit//   
//Rohit//   assign gprpdv = dat & irx_dv & irxbe;
//Rohit//   
//Rohit//   // prpdv :: Pre-Receive Packet Data Valid
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            prpdv <= #TP 1'b0;
//Rohit//   else if ( rxcen )            prpdv <= #TP gprpdv;
//Rohit//   end 
//Rohit//   
//Rohit//   // prpdvd :: Pre-Receive Packet Data Valid Delayed
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            prpdvd <= #TP 1'b0;
//Rohit//   else if ( rxcen )            prpdvd <= #TP prpdv;
//Rohit//   end 
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // gprpsf :: Go Pre-Receive Packet Start of Frame
//Rohit//   
//Rohit//   assign gprpsf = dat & irxbe & irx_dv & ~prpdv & ~prpdvd & ~prpsf;
//Rohit//   
//Rohit//   // prpsf :: Pre-Receive Packet Start of Frame
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            prpsf <= #TP 1'b0;
//Rohit//   else if ( rxcen )            prpsf <= #TP gprpsf;
//Rohit//   end 
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // gprpef :: Go Pre-Receive Packet End of Frame
//Rohit//   
//Rohit//   assign gprpef = dat & irxbe & ~rrx_dv & irx_dv;
//Rohit//   
//Rohit//   // prpef :: Pre-Receive Packet End of Frame
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            prpef <= #TP 1'b0;
//Rohit//   else if ( rxcen )            prpef <= #TP gprpef;
//Rohit//   end 


// ------------------------------------------------------------------------
// --- Receive System Interface

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grpd[7:0] :: Go Receive Packet Data

//Rohit//    assign grpd[7:0] = { 8 { ~speed[1] } } & prpd[7:0]
//Rohit//                     | { 8 {  speed[1] } } & gprpd[7:0];
//Rohit//    
//Rohit//    // rpd[7:0] :: Receive Packet Data
//Rohit//    
//Rohit//    always @ ( posedge rx_clk or posedge srrfn )
//Rohit//    begin
//Rohit//         if ( srrfn )            rpd[7:0] <= #TP 8'h0;
//Rohit//    else if ( rxcen )            rpd[7:0] <= #TP grpd[7:0];
//Rohit//    end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grpdv :: Go Receive Packet Data Valid

//Rohit//assign grpdv = ~speed[1] & prpdv
//Rohit//             |  speed[1] & gprpdv;
//Rohit//
//Rohit//// rpdv :: Receive Packet Data Valid
//Rohit//
//Rohit//always @ ( posedge rx_clk or posedge srrfn )
//Rohit//begin
//Rohit//     if ( srrfn )            rpdv <= #TP 1'b0;
//Rohit//else if ( rxcen )            rpdv <= #TP grpdv;
//Rohit//end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grpsf :: Go Receive Packet Start of Frame

//Rohit//assign grpsf = ~speed[1] & prpsf
//Rohit//             |  speed[1] & gprpsf;
//Rohit//
//Rohit//// rpsf :: Receive Packet Start of Frame
//Rohit//
//Rohit//always @ ( posedge rx_clk or posedge srrfn )
//Rohit//begin
//Rohit//     if ( srrfn )            rpsf <= #TP 1'b0;
//Rohit//else if ( rxcen )            rpsf <= #TP grpsf;
//Rohit//end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grpef :: Go Receive Packet End of Frame

//Rohit//assign grpef = ~speed[1] & ( prpef 
//Rohit//                           | dat & ~irxbe & ~rrx_dv & irx_dv )
//Rohit//             |  speed[1] & gprpef;
//Rohit//
//Rohit//// rpef :: Receive Packet End of Frame
//Rohit//
//Rohit//always @ ( posedge rx_clk or posedge srrfn )
//Rohit//begin
//Rohit//     if ( srrfn )            rpef <= #TP 1'b0;
//Rohit//else if ( rxcen )            rpef <= #TP grpef;
//Rohit//end 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grptd :: Go Receive Packet Tag Detect

//Rohit//assign grptd = gvltg;
//Rohit//
//Rohit//// rptd :: Receive Packet Tag Detect
//Rohit//
//Rohit//always @ ( posedge rx_clk or posedge srrfn )
//Rohit//begin
//Rohit//     if ( srrfn )            rptd <= #TP 1'b0;
//Rohit//else if ( rxcen )            rptd <= #TP grptd;
//Rohit//end 


// ------------------------------------------------------------------------
// --- Receive Slot Time Indication

//
// Implemented only if 1000 Mb/s Half Duplex is implemented.  
//

// Since the slot time in 1000 Mb/s is longer than the minimum packet 
// time, a signal is provided to the system to indicate the slot time. 
// The system then uses the signal to determine how long to hold the
// packet(s) before allowing them to be received.  During the slot time,
// a collision can occur, which would necessitate the dropping of all
// packets received since the beginning of the slot time. 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grpst :: Go Receive Packet Slot Time

//Rohit//assign grpst = 1'b0;
//Rohit//
//Rohit//// rpst :: Receive Packet Slot Time
//Rohit//
//Rohit//always @ ( posedge rx_clk or posedge srrfn )
//Rohit//begin
//Rohit//     if ( srrfn )            rpst <= #TP 1'b0;
//Rohit//else if ( rxcen )            rpst <= #TP grpst;
//Rohit//end 


// ------------------------------------------------------------------------
// --- Cyclic Redundancy Check variables

// An optimized, 8-bit parallel CRC function is used within the RFN 
// Module.  Control is provided by the following signals: CRC Initialize,
// CRC Valid and CRC Hold.  During the pre state, CRC Initialize is 
// asserted, to preload the CRC shift register to all 1's.  As valid
// octets are passed to the CRC Module (PECRC), CRC Valid is asserted.
// In 1000 Mb/s mode, the CRC is calculated every clock.  In 10/100 Mb/s
// mode, the CRC is calculated every other clock since the network 
// interface is only nibble wide.  Every other clock the CRC is held.
// Also, at the end of the frame, the CRC is held until the next frame.
// This allows the CRC to be appended to the frame or the CRC Error 
// to be checked. 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gcini :: Go CRC Initialize

assign gcini = idl & ~gcval;

// cini :: CRC Initialize

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            cini <= #TP 1'b0;
else if ( rxcen )            cini <= #TP gcini;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gcval :: Go CRC Valid

assign gcval = ~speed[1] & gdat & rrx_dv & ~irxbe
             |  speed[1] & gdat & rrx_dv;

// cval :: CRC Valid

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            cval <= #TP 1'b0;
else if ( rxcen )            cval <= #TP gcval;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gchld :: Go CRC Hold

assign gchld = ~gcini & ~gcval;

// chold :: CRC Hold

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            chld <= #TP 1'b0;
else if ( rxcen )            chld <= #TP gchld;
end


// ------------------------------------------------------------------------
// --- PECRC Module Instantiation

// The following is the submodule Instantiation of the CRC function.  The
// 32-bit CRC shift register is output along with the CRC Error indication.

CoreMACFilter_pecrc pecrc_1
(
  .cclk(rx_clk),   .crst(srrfn),
  .cdat(irxd),     .cval(cval),
  .cini(cini),     .chld(chld),
  .xcen(rxcen),
  
  .creg(creg),     .cerr(cerr)
);


// ------------------------------------------------------------------------
// --- Hash Table Support

// In order to support downstream hash tables, 9 bits of the CRC of the 
// destination address of the frame being received are output as Hash
// Value (hashv[8:0]).  This is marked valid by a single pulse called Hash
// Enable (hashe).  

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// ghashe :: Go Hash Enable

assign ghashe = ~hashe & bceq6;

// hashe :: Hash Enable

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            hashe <= #TP 1'b0;
else if ( rxcen )            hashe <= #TP ghashe;
end


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// ghashv[8:0] :: Go Hash Value

assign ghashv[8:0] = { 9 { ghashe } } & creg[31:23];

// hashv[8:0] :: Hash Value

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            hashv[8:0] <= #TP 9'h0;
else if ( rxcen )            hashv[8:0] <= #TP ghashv[8:0];
end


// ------------------------------------------------------------------------
// --- Receive Status

// ------------------------------------------------------------------------
// --- Address Detection

// For statistics purposes, the Destination Address is examined to 
// determine the type of address: Multicast or Broadcast.  These 
// signals are considered valid exactly one clock after the assertion 
// of the hashe.

// gmcad :: Go Multicast Address Detect

wire gmcadp;
reg  mcadp;

assign gmcad =    bceq0 & irxbe   & irxd[0] & dat
             | ~( bceq0 & irxbe ) & mcad & !bcad;

// mcad :: Multicast Address Detect

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            mcad <= #TP 1'b0;
else if ( rxcen )            mcad <= #TP gmcad;
end


/*// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gbcad :: Go Broadcast Address Detect

assign gbcad =   bceq0 &  irxbe & ( &irxd[7:0] ) & dat 
             |   bceq1 &  irxbe & ( &irxd[7:0] ) & bcad
             |   bceq2 &  irxbe & ( &irxd[7:0] ) & bcad
             |   bceq3 &  irxbe & ( &irxd[7:0] ) & bcad
             |   bceq4 &  irxbe & ( &irxd[7:0] ) & bcad
             |   bceq5 &  irxbe & ( &irxd[7:0] ) & bcad
             | ( bcgt5 | ~irxbe )                & bcad;

// bcad :: Broadcast Address Detect

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            bcad <= #TP 1'b0;
else if ( rxcen )            bcad <= #TP gbcad;
end*/


// Updated Logic 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gbcad :: Go Broadcast Address Detect

assign gbcad_d1 =   bceq0 &  irxbe & ( &irxd[7:0] )
             |   bceq1 &  irxbe & ( &irxd[7:0] ) & bcad_d1
             |   bceq2 &  irxbe & ( &irxd[7:0] ) & bcad_d1 
             |   bceq3 &  irxbe & ( &irxd[7:0] ) & bcad_d1
             |   bceq4 &  irxbe & ( &irxd[7:0] ) & bcad_d1
             |   bceq5 &  irxbe & ( &irxd[7:0] ) & bcad_d1
             | ( bcgt5 | ~irxbe )                & bcad_d1;

// bcad :: Broadcast Address Detect


assign gbcad = bcgt5  & bcad_d1
             | ~bcgt5 & 1'b0;


always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            bcad_d1 <= #TP 1'b0;
else if ( rxcen )            bcad_d1 <= #TP gbcad_d1;
end

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            bcad <= #TP 1'b0;
else if ( rxcen )            bcad <= #TP gbcad;
end
// 


//==========================================================================//
//Rohit : Added to detect the  Unicast Frame.
//
//==========================================================================//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// gbcad :: Go Broadcast Address Detect


assign gucad =   bceq0 &  irxbe & (irxd[7:0] == stad[47:40]  )       
             |   bceq1 &  irxbe & (irxd[7:0] == stad[39:32]  ) & ucad_reg
             |   bceq2 &  irxbe & (irxd[7:0] == stad[31:24]  ) & ucad_reg
             |   bceq3 &  irxbe & (irxd[7:0] == stad[23:16]  ) & ucad_reg
             |   bceq4 &  irxbe & (irxd[7:0] == stad[15:8]   ) & ucad_reg
             |   bceq5 &  irxbe & (irxd[7:0] == stad[7:0]    ) & ucad_reg
             | ( bcgt5 | ~irxbe )                              & ucad_reg;

// bcad :: Broadcast Address Detect

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )      ucad_reg <=  #TP 1'b0;
else if ( rxcen )      ucad_reg <=  #TP gucad & dat;
end
//assign ucad = ~(~ucad_reg & dat_d1);  
assign ucad = ucad_reg;


assign gmcadp      =   bceq0 &  irxbe & (irxd[7:0] == 8'h01 )       
                   |   bceq1 &  irxbe & (irxd[7:0] == 8'h80 ) & mcadp
                   |   bceq2 &  irxbe & (irxd[7:0] == 8'hc2 ) & mcadp
                   |   bceq3 &  irxbe & (irxd[7:0] == 8'h00 ) & mcadp
                   |   bceq4 &  irxbe & (irxd[7:0] == 8'h00 ) & mcadp
                   |   bceq5 &  irxbe & (irxd[7:0] == 8'h01 ) & mcadp
                   | ( bcgt5 | ~irxbe )                       & mcadp;

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )      mcadp <=  #TP 1'b0;
else if ( rxcen )      mcadp <=  #TP gmcadp & dat;
end


		   
/*//===== Not Required =============================//
//Rohit//   // ------------------------------------------------------------------------
//Rohit//   // --- Length/Type Field
//Rohit//   
//Rohit//   // The 16-bit Length/Type field ( octets 13-14 ) is saved for later 
//Rohit//   // comparison.  If it is determined to be the VLAN Protocol Identifier, 
//Rohit//   // then the relocated Length/Type is saved from octets 17-18.
//Rohit//   
//Rohit//   // lulnty :: Load Upper Length / Type Field
//Rohit//   
//Rohit//   assign lulnty = bceqc  & irxbe
//Rohit//                 | bceq10 & irxbe & vltg;
//Rohit//   
//Rohit//   // lllnty :: Load Lower Length / Type Field
//Rohit//   
//Rohit//   assign lllnty = bceqd  & irxbe
//Rohit//                 | bceq11 & irxbe & vltg;
//Rohit//   
//Rohit//   // glnty[15:0] :: Go Length / Type Field
//Rohit//   
//Rohit//   *///===== Not Required =============================//
//Rohit//   /*//===== Not Required =============================//
//Rohit//   
//Rohit//   assign glnty[15:0] = { 16 {  lulnty           } } & { irxd[7:0],  lnty[7:0] }
//Rohit//                      | { 16 {            lllnty } } & { lnty[15:8], irxd[7:0] }
//Rohit//                      | { 16 { ~lulnty & ~lllnty } } & { lnty[15:8], lnty[7:0] };
//Rohit//   
//Rohit//   // lnty[15:0] :: Length / Type Field
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            lnty[15:0] <= #TP 16'h0;
//Rohit//   else if ( rxcen )            lnty[15:0] <= #TP glnty[15:0];
//Rohit//   end
//Rohit//   
//Rohit//   // ltgtmax :: Length/Type > Maximum Frame Length ( 1500 )
//Rohit//   
//Rohit//   assign ltgtmax =   lnty[15:0] >  16'h05dc;
//Rohit//   
//Rohit//   // ltgemin :: Length/Type >= Minimum Data Length ( 46 )
//Rohit//   
//Rohit//   assign ltgemin = ( lnty[15:0] >= 16'h002e ); 
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // Octets 13-14 are compared against the VLAN Protocol Identifier ( 0x8100 )
//Rohit//   // to determine is the frame is tagged.
//Rohit//   
//Rohit//   // gvltg :: Go VLAN Tag Detect
//Rohit//   
//Rohit//   assign gvltg =    bceqf &  irxbe   & lnty[15:0] == 16'h8100
//Rohit//                | ( ~bceqf | ~irxbe ) & vltg;
//Rohit//   
//Rohit//   // vltg :: VLAN Tag Detect
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            vltg <= #TP 1'b0;
//Rohit//   else if ( rxcen )            vltg <= #TP gvltg;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // The Length field is compared to the Type field of 1518 bytes to
//Rohit//   // determine Out of Range Length.
//Rohit//   
//Rohit//   // grloor :: Go: Out of Range Length Error
//Rohit//   
//Rohit//   assign grloor =  ( rbct[15:0] > 16'h5ee )
//Rohit//                & ( rbct[15:0] < maxfr[15:0] );
//Rohit//   
//Rohit//   // rloor :: Out of Range Length Error
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            rloor <= #TP 1'b0;
//Rohit//   else if ( rxcen )            rloor <= #TP grloor;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // The Length field is compared against the actual length of the data 
//Rohit//   // portion of the frame to determine length mismatches.
//Rohit//   
//Rohit//   // dfbc[15:0] :: Data Frame Byte Length
//Rohit//   
//Rohit//   assign dfbc = { 16 { ~vltg & rbct > 5'h12 } } & ( rbct[15:0] - 5'h12 )  
//Rohit//               | { 16 {  vltg & rbct > 5'h16 } } & ( rbct[15:0] - 5'h16 );
//Rohit//   
//Rohit//   // girle :: In Range Length Errors
//Rohit//   
//Rohit//   assign girle =  ltgemin & ~ltgtmax & lnty[15:0] != dfbc[15:0] & flchk
//Rohit//                | ~ltgemin &  flchk   & dfbc[15:0] > 16'h002e;
//Rohit//   
//Rohit//   // irle :: In Range Length Errors
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            irle <= #TP 1'b0;
//Rohit//   else if ( rxcen )            irle <= #TP girle;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//Rohit//   // The Receive Error input, RX_ER. is captured to detect a Code Error 
//Rohit//   // sometime during the packet.
//Rohit//   
//Rohit//   // gcderr :: Go Code Error
//Rohit//   
//Rohit//   assign gcderr = ~cderr & rrx_dv & rrx_er
//Rohit//                 |  cderr & ~rsvp; 
//Rohit//   
//Rohit//   // cderr :: Code Error
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin
//Rohit//        if ( srrfn )            cderr <= #TP 1'b0;
//Rohit//   else if ( rxcen )            cderr <= #TP gcderr;
//Rohit//   end
//Rohit//   *///===== Not Required =============================//
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Rohit//   // The input stream is examined to detect a false carrier.
//Rohit//   
//Rohit//   // gflscar :: Go False Carrier
//Rohit//   
//Rohit//   
//Rohit//   /*//===== Not Required =============================//
//Rohit//   
//Rohit//   assign gflscar = ~flscar & ~rrx_dv & ~irx_er & rrx_er & rrxd[7:0] == 8'h0e
//Rohit//                  |  flscar & ~rsvp;
//Rohit//   
//Rohit//   // flscar :: False Carrier
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin       
//Rohit//        if ( srrfn )            flscar <= #TP 1'b0;
//Rohit//   else if ( rxcen )            flscar <= #TP gflscar;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Rohit//   // The input stream is examined to detect an RX_DV event.
//Rohit//   
//Rohit//   // grxdvnt :: Go RX_DV Event
//Rohit//   
//Rohit//   assign grxdvnt = ~rxdvnt & ~irx_dv & bceq0 & dsfd & dat
//Rohit//                  | ~rxdvnt & ~irx_dv & bceq0 & pre & ~sfd
//Rohit//                  | ~rxdvnt & ~irx_dv & bceq0 & sfd & ~dat
//Rohit//                  |  rxdvnt & ~rsvp;
//Rohit//   
//Rohit//   // rxdvnt :: RX_DV Event
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin       
//Rohit//        if ( srrfn )            rxdvnt <= #TP 1'b0;
//Rohit//   else if ( rxcen )            rxdvnt <= #TP grxdvnt;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Rohit//   // The input stream is examined to detect an drop event.
//Rohit//   
//Rohit//   // gdrpvnt :: Go Drop Event
//Rohit//   
//Rohit//   assign gdrpvnt = ~drpvnt & ( idl | pre | sfd )
//Rohit//                            & irx_dv & irxd == 8'b1101_0101 & irxbe & ~mifgm
//Rohit//                  |  drpvnt & ~rsvp;
//Rohit//   
//Rohit//   // drpvnt :: Drop Event
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin       
//Rohit//        if ( srrfn )            drpvnt <= #TP 1'b0;
//Rohit//   else if ( rxcen )            drpvnt <= #TP gdrpvnt;
//Rohit//   end
//Rohit//   
//Rohit//   
//Rohit//   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Rohit//   // The input stream is examined to detect a dribble nibble.
//Rohit//   
//Rohit//   // gdrbnib :: Go Dribble Nibble
//Rohit//   
//Rohit//   assign gdrbnib = ~drbnib & ~rrx_dv & irx_dv & ~irxbe & ~trunc
//Rohit//                  |  drbnib & ~idl;
//Rohit//   
//Rohit//   // drbnib :: Dribble Nibble
//Rohit//   
//Rohit//   always @ ( posedge rx_clk or posedge srrfn )
//Rohit//   begin       
//Rohit//        if ( srrfn )            drbnib <= #TP 1'b0;
//Rohit//   else if ( rxcen )            drbnib <= #TP gdrbnib;
//Rohit//   end
//Rohit//   *///===== Not Required =============================//


// ------------------------------------------------------------------------
// --- Receive Statistics

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Receive sample is a qualifier which loads new values onto the Receive
// Statistics Vector.

// grsmp :: Go Receive Sample

assign grsmp = ~rsmp & ~rrx_dv & irx_dv & dat;

// rsmp :: Receive Sample

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rsmp <= #TP 1'b0;
else if ( rxcen )            rsmp <= #TP grsmp;
end

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rsmp2 <= #TP 1'b0;
else if ( rxcen )            rsmp2 <= #TP rsmp;
end

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// A one-clock wide pulse is asserted via Receive Statistics Vector Pulse
// denoting new receive statistics.

// grsvp :: Go Receive Statistics Vector Pulse

assign grsvp = rsmp2;

// rsmp :: Receive Statistics Vector Pulse

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rsvp <= #TP 1'b0;
else if ( rxcen )            rsvp <= #TP grsvp;
end


/*//===== Not Required =============================//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// grsv[32] :: { Truncated Frame }

assign grsv[32] =  rsmp2 & trunc  
                | ~rsmp2 & rsv[32];

// grsv[31:28] :: { VLAN Tag, Unsupported Op-code, PAUSE frame, Control frame }

assign grsv[31:28] = { 4 {  rsmp2 } } & { lngvnt, 
                                          vltg, 
                                          rxuo, 
                                          rxpf }
                   | { 4 { ~rsmp2 } } & rsv[31:28];

// grsv[27:24] :: { Long Event, Dribble Nibble, Broadcast, Multicast }

assign grsv[27:24] = { 4 {  rsmp2 } } & { rxcf,  
                                          drbnib, 
                                          bcgt5 & bcad, 
                                          bcgt5 & mcad }
                   | { 4 { ~rsmp2 } } & rsv[27:24];

// grsv[23:20] :: { OK, Out of Range, Length Mismatch, CRC Error }

assign grsv[23:20] = { 4 {  rsmp2 } } & { ~cderr & ~cerr, 
                                          rloor, 
                                          irle,
                                          cerr }
                   | { 4 { ~rsmp2 } } & rsv[23:20];

// grsv[19:16] :: { Code Error, False Carrier, RX_DV Event, Drop Event }

assign grsv[19:16] = { 4 {  rsmp2 } } & { cderr,
                                         flscar,
                                         rxdvnt,
                                         drpvnt }
                   | { 4 { ~rsmp2 } } & rsv[19:16];

// grsv[15:0] :: Receive Byte Count

assign grsv[15:0] = { 16 {  rsmp2 } } & rbct[15:0]
                  | { 16 { ~rsmp2 } } & rsv[15:0];

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// rsv[32:0] :: Receive Statistics Vector

always @ ( posedge rx_clk or posedge srrfn )
begin
     if ( srrfn )            rsv[32:0] <= #TP 33'h0;
else if ( rxcen )            rsv[32:0] <= #TP grsv[32:0];
end
*///===== Not Required =============================//

endmodule

//=============================================================================
// Revision History:  
// $Log: perfn_top.v,v $
// Revision 1.4  2013/10/10 11:03:54  dipak
// formating..
//
// Revision 1.3  2013/10/01 09:03:26  rohitp
// *** empty log message ***
//
// Revision 1.2  2013/09/16 10:27:19  dipak
// Added PTP related signals and logic
//
// Revision 1.1  2013/09/02 09:21:02  dipak
// Moved from mentor data-base. Consider this version as baseline for the TSMAC project.
//  
//=============================================================================