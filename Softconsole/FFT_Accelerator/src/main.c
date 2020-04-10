/*
 * main.cpp
 *
 *  Created on: Apr 9, 2020
 *      Author: Phoenix136
 */


#include <stdio.h>

#include "../firmware/drivers/mss_uart/mss_uart.h"

#include "../firmware/drivers/mss_ethernet_mac/mss_ethernet_mac_types.h"
#include "../firmware/drivers/mss_ethernet_mac/mss_ethernet_mac.h"
#include "../firmware/drivers/mss_ethernet_mac/phy.h"

#include "FFT_apb.h"


#include "../firmware/CMSIS/system_m2sxxx.h"


#include "../firmware/FFT_Accel_system_hw_platform.h"

/*-------------------------------------------------------------------------*//**
 * main definitions
 */
void init_periph(void);

void report_eth_stat_over_uart(void);


void uart0_rx_int_handler(mss_uart_instance_t *);

void eth_tx_callback(void * caller_info);
void eth_rx_callback(uint8_t * p_rx_packet, uint32_t pckt_length, void * p_user_data);
char eth_check_address(uint8_t *);

void load_fft_samples(void);
void read_fft_samples(void);
void report_fft_status(void);

/*-------------------------------------------------------------------------*//**
 * main defines
 */

#define RX_BUFF_SIZE    64

#define ETH_PACKET_SIZE                  1514u
#define ETH_PACKET_DATA_START			14

/*-------------------------------------------------------------------------*//**
 * main globals
 */

char port_check = 0;
int8_t input_smpls[1024];
int8_t input_smpls2[1024];

fft_instance_t fft_fab;

/*------------------------------------------------------------------------------
 * MSS MAC, Ethernet
 */
mss_mac_cfg_t mac_config;
const static uint8_t mac_address[6] = {0x22, 0x22, 0x22, 0x22, 0x22, 0x22};
volatile uint32_t g_pckt_rcvd_len = 0;

static uint8_t g_mac_tx_buffer[ETH_PACKET_SIZE] = \
      {0x00,0xe0,0x4c,0x68,0x01,0x2f, 0xff,0xff,0xff,0xff,0xff,0xff, 0x88,0xb5};
static uint8_t g_mac_rx_buffer_0[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_1[ETH_PACKET_SIZE];

static volatile uint32_t g_mac_tx_buffer_used = 1u;



/*------------------------------------------------------------------------------
 * MAIN
 */
int main(){
	init_periph();

	for(;;){
		switch (port_check)
		{
		case 1:
			load_fft_samples();
			port_check = 0;
			break;
		case 2:
			read_fft_samples();
			port_check = 0;
			break;
		case 3:
			fft_read_done(&fft_fab);
			port_check = 0;
			break;
		case 4:
			report_fft_status();
			port_check = 0;
			break;
		default:
			break;
		}
	}
}


void init_periph(void){
	/*-------------------------------------------------------------------------*//**
	* MSS_UART
	*/
	MSS_UART_init(
			&g_mss_uart0,
			MSS_UART_921600_BAUD,//MSS_UART_115200_BAUD
			MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT
		);
	MSS_UART_enable_irq(
			&g_mss_uart0,
			MSS_UART_RBF_IRQ
		);
	MSS_UART_set_rx_handler(
			&g_mss_uart0,
			uart0_rx_int_handler,
			MSS_UART_FIFO_SINGLE_BYTE
		);
	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"uart initialized!\n\r");


	/*-------------------------------------------------------------------------*//**
	* Fabric FFT
	*/

	fft_init(&fft_fab, FFT_APB_WRAPPER_0);

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"fft initialized!\n\r");

	/*-------------------------------------------------------------------------*//**
	* MSS_MAC, VSC8541 PHY, Ethernet stuff
	*/
	MSS_MAC_cfg_struct_def_init(&mac_config);
	mac_config.mac_addr[0] = mac_address[0];
	mac_config.mac_addr[1] = mac_address[1];
	mac_config.mac_addr[2] = mac_address[2];
	mac_config.mac_addr[3] = mac_address[3];
	mac_config.mac_addr[4] = mac_address[4];
	mac_config.mac_addr[5] = mac_address[5];
	mac_config.speed_duplex_select = MSS_MAC_ANEG_100M_FD;
	mac_config.phy_addr = 0x00;


	MSS_MAC_init(&mac_config);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_0, (void *)g_mac_rx_buffer_0);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_1, (void *)g_mac_rx_buffer_1);
	MSS_MAC_set_tx_callback(eth_tx_callback);
	MSS_MAC_set_rx_callback(eth_rx_callback);

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"mac initialized!\n\r");


	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"== everything is set up! ==\n\r");

}


void report_eth_stat_over_uart(void){
	uint8_t link_status;
    mss_mac_speed_t speed;
    uint8_t fullduplex;

	link_status = MSS_MAC_phy_get_link_status(&speed, &fullduplex);
	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"Link is: ");
	if(link_status == MSS_MAC_LINK_UP){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"UP!\r\n");
		switch(speed)
		{
			case MSS_MAC_10MBPS:
				MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"    10Mbps ");
			break;

			case MSS_MAC_100MBPS:
				MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"    100Mbps ");
			break;
			case MSS_MAC_1000MBPS:
				MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"    1000Mbps ");
			break;
			default:
				MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"    nope ");
			break;
		}
		if(1u == fullduplex)
		{
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"Full Duplex\r\n");
		}
		else
		{
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t*)"Half Duplex\r\n");
		}
	}
	else{
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"DOWN!\r\n");
	}


}

void uart0_rx_int_handler(mss_uart_instance_t * this_uart){
	uint8_t rx_buff[RX_BUFF_SIZE];
	uint32_t rx_idx  = 0;
	size_t rx_size;
	rx_size = MSS_UART_get_rx(this_uart, rx_buff, sizeof(rx_buff));
	//uart_rx_to_nokia_raw(rx_buff, rx_size);
	//uart_rx_to_nokia_char(rx_buff, rx_size);
	//uart_rx_to_spi_mem(rx_buff, rx_size);
}

void eth_tx_callback(void * caller_info){
	*((uint32_t *)caller_info) = 0;
	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"Ethernet Response Sent\n\r");
}

void eth_rx_callback(
	uint8_t * p_rx_packet,
	uint32_t pckt_length,
	void * p_user_data
)
{
	port_check = eth_check_address(p_rx_packet);
	char buffer[128];
	static uint8_t * dest_array = input_smpls2;

	if(1u == port_check){

		snprintf(buffer, sizeof(buffer), "\n\rRX pkt size = %d\r\n", (int)pckt_length);
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"========================\n\r");
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"Ethernet packet received\n\r");
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);


		//MSS_MAC_send_pkt(g_mac_tx_buffer, 64u, (void *)&g_mac_tx_buffer_used);
		/*
		for(int i = 0; i < pckt_length; i++){
			snprintf(buffer, sizeof(buffer), "%i", p_rx_packet[i]);
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
		}
		*/

		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"\n\rDATA DONE\n\r");
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"========================\n\r");

		if(dest_array == (uint8_t *)&input_smpls){
			dest_array = input_smpls2;
		}
		else{
			dest_array = input_smpls;
		}

		for(int i = 0; i < 1024; i++){
			dest_array[i] = p_rx_packet[i + 42];
			//snprintf(buffer, sizeof(buffer), "datum %d = %d\r\n", (int)i, (int)p_rx_packet[i + 42]);
			//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
		}
	}
	else if(2 == port_check){
		
	}
	else if(3 == port_check){
		
	}

	MSS_MAC_receive_pkt((uint8_t *)p_user_data, p_user_data);
	

}

char eth_check_address(uint8_t * packet_data){
	/* Check Destination address */
	if(packet_data[30] == 169 && packet_data[31] == 254 && packet_data[32] == 255 && packet_data[33] == 255){
		/* Check Destination port */
		if(packet_data[36] == 0xDE && packet_data[37] == 0xAD){
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"DEAD received, reading data\n\r");
			return 1u;
		}
		else if(packet_data[36] == 0xBE && packet_data[37] == 0xEF){
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"BEEF received, returning data\n\r");
			return 2u;
		}
		else if(packet_data[36] == 0xb0 && packet_data[37] == 0x0b){
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"B00B received, done reading data\n\r");
			return 3u;
		}
		else if(packet_data[36] == 0xd0 && packet_data[37] == 0x0f){
			MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"D00F received, sending FFT status\n\r");
			return 4u;
		}
	}
	return 0u;
}

void load_fft_samples(void){
	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"load started\n\r");

	char buffer[128];
	int16_t sample;

	for(int i = 0; i < 1024; i+=2){
		sample = input_smpls[i];
		sample = (sample << 8) | (input_smpls[i+1] & 0xff);
		fft_load_smpl(&fft_fab, sample, 0u);
		snprintf(buffer, sizeof(buffer), "datum %d = %d\r\n", (int)i, (int)sample);
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
	}
	for(int i = 0; i < 1024; i+=2){
		sample = input_smpls2[i];
		sample = (sample << 8) | input_smpls2[i+1];
		fft_load_smpl(&fft_fab, sample, 0u);
		snprintf(buffer, sizeof(buffer), "datum %d = %d\r\n", (int)i, (int)sample);
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
	}

	fft_load_done(&fft_fab);

	
	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"load finished\r\n");
}


void read_fft_samples(void){
	char buffer[128];
	int16_t fft_result_real[513];
	int16_t fft_result_imag[513];
	uint16_t fft_result_abs;
	int byte_cnt = ETH_PACKET_DATA_START;

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"return started\r\n");

	for(int i = 0; i < 513; i++){
		byte_cnt++;
		//fft_read_smpl(&fft_fab, (uint16_t)i, fft_result_real[i], fft_result_imag[i], fft_result_abs);
		fft_set_output_smpl(&fft_fab, (uint16_t)i);
		fft_result_real[i] = fft_get_real_out(&fft_fab);
		fft_result_imag[i] = fft_get_imag_out(&fft_fab);
		fft_result_abs = fft_get_abs_val_out(&fft_fab);
		g_mac_tx_buffer[i + ETH_PACKET_DATA_START] = (uint8_t)fft_result_abs;

		snprintf(buffer, sizeof(buffer), "return %d = %d + i%d\r\n", (int)i, (int)fft_result_real[i], (int)fft_result_imag[i]);
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
	}

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"return finished\r\n");

	MSS_MAC_send_pkt(g_mac_tx_buffer, byte_cnt, (void *)&g_mac_tx_buffer_used);
}

void report_fft_status(void){
	//char buffer[128];
	uint8_t fft_status;
	uint8_t status_test;

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"==========\r\nstatus started\r\n");
	fft_status = fft_get_status(&fft_fab);
	status_test = fft_status & STAT_W_READY;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"INPUT READY\r\n");
	}
	status_test = fft_status & STAT_W_FULL;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"INPUT FULL\r\n");
	}
	status_test = fft_status & STAT_R_READY;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"OUTPUT READY\r\n");
	}
	status_test = fft_status & STAT_R_VALID;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"OUTPUT VALID\r\n");
	}
	status_test = fft_status & STAT_ABS_VALID;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"ABS VALUE VALID\r\n");
	}

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"==========\r\ncontrol register\r\n");

	fft_status = fft_get_ctrl(&fft_fab);
	status_test = fft_status & CTRL_WRITE_EN;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"WRITE ENABLED\r\n");
	}
	status_test = fft_status & CTRL_LOAD_DONE;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"WRITE DONE\r\n");
	}
	status_test = fft_status & CTRL_READ_DONE;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"READ DONE\r\n");
	}

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"status finished\r\n==========\r\n");
}
