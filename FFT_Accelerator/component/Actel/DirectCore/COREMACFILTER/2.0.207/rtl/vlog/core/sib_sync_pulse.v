//==============================================================================
//                            Sibridge Technologies                             
//                        Proprietary and Confidential                          
//                  Copyright (c) 2013 All Rights Reserved                     
//==============================================================================
// FILE        : $Source: /opt/cvs/sib_dip_lib/common/sib_sync_pulse.v,v $                                                    
// REVISION    : $Revision: 1.6 $                                                  
// LAST UPDATE : $Date: 2013/11/21 09:06:30 $                                                      
//==============================================================================
// AUTHOR      : Sibridge Technologies                                          
// MODULE NAME : sib_sync_pulse
// DESCRIPTION : reusable logic to send pulse across clock domain
//==============================================================================
                                                                                
module CoreMACFilter_sib_sync_pulse #(parameter USE_FL_RST = 0)
(                                                                               
  input                txclk_i,       //Tx Domain clock 
  input                txrst_ni,      //Tx Domain Reset
  input                txpulse_i,     //Tx Domain pulse

  input                rxclk_i,       //Rx Domain clock 
  input                rxrst_ni,      //Rx Domain Reset 
  output               rxpulse_o,     //Rx Domain pulse 
  output               pulse_xfrd_o   //pulse transferred
);

//Local wire/reg declaration                                                    
//------------------------------------------------------------------------------
wire txpls_c, busy;
reg  txpls, txreq_d2, rxack_d3;
wire rxack_d2, txreq_d1;

//Transfer the pulse only when the new pulse arrived && previous pulse xfer done
//------------------------------------------------------------------------------
assign txpls_c = txpls ^ (!busy & txpulse_i);
assign busy = rxack_d2 ^ txpls;
assign pulse_xfrd_o = rxack_d2 ^ rxack_d3;

CoreMACFilter_sib_sync_2flp #(.DWIDTH(1), .USE_RST(USE_FL_RST)) sib_sync_2flp_u0
  (.sclk_i(rxclk_i), .dclk_i(txclk_i), .srst_ni(rxrst_ni), .drst_ni(txrst_ni), .din_i(txreq_d2), .dout_o(rxack_d2));
                                    
CoreMACFilter_sib_sync_2flp #(.DWIDTH(1), .USE_RST(USE_FL_RST)) sib_sync_2flp_u1
  (.sclk_i(txclk_i), .dclk_i(rxclk_i), .srst_ni(txrst_ni), .drst_ni(rxrst_ni), .din_i(txpls), .dout_o(txreq_d1));

`ifdef ASYNC_RESET
always @ (posedge txclk_i or negedge txrst_ni)
`else    
always @ (posedge txclk_i) 
`endif
begin
  if(!txrst_ni) begin
    txpls    <= 'b0;
    rxack_d3 <= 'b0;
  end
  else begin
    txpls    <= txpls_c;
    rxack_d3 <= rxack_d2;
  end
end

assign rxpulse_o = txreq_d1 ^ txreq_d2;

`ifdef ASYNC_RESET
always @ (posedge rxclk_i or negedge rxrst_ni)
`else    
always @ (posedge rxclk_i) 
`endif
begin
  if(!rxrst_ni)  txreq_d2 <= 'b0;
  else           txreq_d2 <= txreq_d1;
end
  
endmodule                                                                       
//============================================================================= 
// Revision History:                                                            
// $Log: sib_sync_pulse.v,v $
// Revision 1.6  2013/11/21 09:06:30  bhaveshd
// Added support for using Reset optionally
//
// Revision 1.5  2013/11/20 13:32:47  dhavalp
// added ack for pulse transferred
//
// Revision 1.4  2013/10/29 12:47:52  dipak
// corrected txpls_c logic, used !busy instead of busy
//
// Revision 1.3  2013/10/16 05:18:16  pankaj
// updated as per port list changes in 2flp sync
//
// Revision 1.2  2013/10/09 06:23:06  dipak
// used sib_sync_2flp instead of local sync flops
//
// Revision 1.1  2013/09/27 08:53:57  dipak
// initial checkin...
//
//                                                                     
//============================================================================= 
