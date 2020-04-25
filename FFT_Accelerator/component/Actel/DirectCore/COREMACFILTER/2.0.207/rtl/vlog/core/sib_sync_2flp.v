//==============================================================================
//                            Sibridge Technologies                             
//                        Proprietary and Confidential                          
//                  Copyright (c) 2013 All Rights Reserved                     
//==============================================================================
// FILE        : $Source: /opt/cvs/sib_dip_lib/common/sib_sync_2flp.v,v $                                                    
// REVISION    : $Revision: 1.5 $                                                  
// LAST UPDATE : $Date: 2013/11/21 08:47:39 $                                                      
//==============================================================================
// AUTHOR      : Sibridge Technologies                                          
// MODULE NAME : sib_sync_2flp                                                       
// DESCRIPTION :                                                                
//==============================================================================

//`define SIM_2FLPMETA

module CoreMACFilter_sib_sync_2flp  #(parameter DWIDTH = 1,
                        parameter USE_RST = 0)
(                                                                               
  input                sclk_i,       //Source clock       
  input                dclk_i,       //Destination clock                                
  input                srst_ni,      //source reset
  input                drst_ni,      //destination reset
  input  [DWIDTH-1:0]  din_i,       //
  output [DWIDTH-1:0]  dout_o       //
);                                                                              


//Local wire/reg declaration                                                    
//------------------------------------------------------------------------------
reg [DWIDTH-1:0] din_d1, din_d2, din_sd1;

integer i;	
`ifdef SIM_2FLPMETA
wire [DWIDTH-1:0] din_changed, randome_and;
assign din_changed = (din_d1 ^ din_sd1);
assign random_and = $random;
`endif

generate
  if (USE_RST == 1)
    begin:DIN_RST
      `ifdef ASYNC_RESET
      always @ (posedge sclk_i or negedge srst_ni)
      `else    
      always @ (posedge sclk_i) 
      `endif
      begin
        if(~srst_ni)
          din_sd1 <= 0;
        else
          din_sd1 <= din_i;
      end

      `ifdef ASYNC_RESET
      always @ (posedge dclk_i or negedge drst_ni)
      `else    
      always @ (posedge dclk_i) 
      `endif
      begin
        if(~drst_ni)
        begin
          `ifdef SIM_2FLPMETA
            din_d1 <= 0;	     
          `else	
            din_d1 <= 0;
          `endif
          din_d2 <= 0;
        end
        else
        begin
          `ifdef SIM_2FLPMETA
            din_d1 <= din_sd1 ^ (din_changed & random_and);	     
          `else	
            din_d1 <= din_sd1;
          `endif
          din_d2 <= din_d1;    
        end
      end  
    end //DIN_RST
  else
    begin:DIN_WO_RST
      always @ (posedge sclk_i) 
         din_sd1 <= din_i;

      always @ (posedge dclk_i) begin
       `ifdef SIM_2FLPMETA
         din_d1 <= din_sd1 ^ (din_changed & random_and);	     
       `else	
         din_d1 <= din_sd1;
       `endif
       din_d2 <= din_d1;
      end      
    end //DIN_WO_RST
endgenerate

assign dout_o = din_d2;
                                                                                
endmodule                                                                       
//============================================================================= 
// Revision History:                                                            
// $Log: sib_sync_2flp.v,v $
// Revision 1.5  2013/11/21 08:47:39  bhaveshd
// Added support for using Reset optionally
//
// Revision 1.4  2013/10/16 05:18:41  pankaj
// updated to add source clock flop, hence port list also changed, removed reset i/p
//
// Revision 1.3  2013/10/09 06:22:40  dipak
// added metastability randomization for simulation
//
// Revision 1.2  2013/09/19 09:36:08  dipak
// corrected port direction for dout
//
// Revision 1.1  2013/09/11 06:45:17  dipak
// initial checkin
//                                                                     
//============================================================================= 
