/*
 * main.cpp
 *
 *  Created on: Apr 9, 2020
 *      Author: Phoenix136
 */


#include <stdio.h>

#include "../firmware/drivers/mss_uart/mss_uart.h"
#include "../firmware/drivers/mss_gpio/mss_gpio.h"

#include "../firmware/drivers/mss_ethernet_mac/mss_ethernet_mac_types.h"
#include "../firmware/drivers/mss_ethernet_mac/mss_ethernet_mac.h"
#include "../firmware/drivers/mss_ethernet_mac/phy.h"

#include "FFT_apb.h"
#include "GMII_Filter_Trap.h"

#include "ARP_protocol.h"

#include "../firmware/CMSIS/system_m2sxxx.h"


#include "../firmware/FFT_Accel_system_hw_platform.h"

/*-------------------------------------------------------------------------*//**
 * main definitions
 */
void init_periph(void);

void do_eth_cmd_code(void);

void report_eth_stat_over_uart(void);


void uart0_rx_int_handler(mss_uart_instance_t *);

void eth_tx_callback(void * caller_info);
void eth_rx_callback(uint8_t * p_rx_packet, uint32_t pckt_length, void * p_user_data);
char eth_check_address(uint8_t *);
uint32_t eth_get_code(uint8_t * packet_data);
void report_eth_status(void);
void report_mac_phy_reg(void);
void load_fft_samples(void);
void read_fft_samples(void);
void report_fft_status(void);

uint16_t eth_gen_checksum(uint8_t * buffer, uint32_t length);
void eth_arp_announce(void);
void eth_send_big_data(void);

uint32_t test_GPIO_high(uint32_t GPIO_MASK);

/*-------------------------------------------------------------------------*//**
 * main defines
 */

#define RX_BUFF_SIZE    64

#define ETH_PACKET_SIZE                  1514u
#define ETH_PACKET_DATA_START			42

#define ETH_P_NOP			0u
#define ETH_P_C0DE			1u
#define ETH_P_DA7A			2u
#define ETH_P_ARP_PROBE 	3u
#define ETH_P_ARP_RESPONSE	4u

#define ETH_TX_DAT_LEN		513
#define ETH_TX_IPV4_LEN_MSB	(uint8_t)((28u + ETH_TX_DAT_LEN) >> 8) & 0xff
#define ETH_TX_IPV4_LEN_LSB (uint8_t)((28u + ETH_TX_DAT_LEN)) & 0xff

#define ETHTX_UDP_LEN_MSB (uint8_t)((8u + ETH_TX_DAT_LEN) >> 8) & 0xff
#define ETHTX_UDP_LEN_LSB (uint8_t)((8u + ETH_TX_DAT_LEN)) & 0xff

/*-------------------------------------------------------------------------*//**
 * main globals
 */

char port_check = 0;
int eth_cmd_code = 0;
char do_big_data = 0;
char data_rx_cnt = 0;
uint8_t * smpl_pkt_0;
uint8_t * smpl_pkt_1;
char fft_auto_done = 0;


fft_instance_t fft_fab;
gmii_trap_instance_t gmii_trap_fab;

/*------------------------------------------------------------------------------
 * MSS MAC, Ethernet
 */
mss_mac_cfg_t mac_config;
const static uint8_t mac_address[6] = {0x22, 0x22, 0x22, 0x22, 0x22, 0x22};
//const static uint8_t mac_address[6] = {0x00, 0xA0, 0x87, 0x22, 0x22, 0x22};
const static uint8_t tx_mac[6] = {0xff,0xff,0xff,0xff,0xff,0xff};	//broadcast
//const static uint8_t tx_mac[6] = {0x00,0xe0,0x4c,0x68,0x01,0x2f};	//desktop
//const static uint8_t tx_mac[6] = {0x08,0x00,0x27,0xbd,0x10,0x77};	//VM GNURadio
const static uint8_t tx_ip[4] = {100, 100, 100, 255};	//broadcast
//const static uint8_t tx_ip[4] = {100, 100, 100, 100};	//desktop
//const static uint8_t tx_ip[4] = {100, 100, 100, 101};	//VM GNURadio
const static uint8_t my_ip[4] = {100, 100, 100, 200};
const static uint8_t chksm_ip[2] = {0xa6, 0x40};// broadcast
//const static uint8_t chksm_ip[2] = {0xa6, 0x40};// desktop (checksum tbd)
//const static uint8_t chksm_ip[2] = {0xa6, 0xda};// VM GNURadio
volatile uint32_t g_pckt_rcvd_len = 0;

uint16_t eth_tx_id = 0x0000u;
static uint8_t g_mac_tx_buffer[ETH_PACKET_SIZE] = \
      {tx_mac[0],tx_mac[1],tx_mac[2],tx_mac[3],tx_mac[4],tx_mac[5], mac_address[0],mac_address[1],mac_address[2],mac_address[3],mac_address[4],mac_address[5], 0x08,0x00,
	  0x45, 0x00, ETH_TX_IPV4_LEN_MSB,ETH_TX_IPV4_LEN_LSB, 0xFF,0xFF, 0x00,0x00, 0x80, 0x11, chksm_ip[0],chksm_ip[1], my_ip[0],my_ip[1],my_ip[2],my_ip[3], tx_ip[0],tx_ip[1],tx_ip[2],tx_ip[3],
	  0xDA,0x7A, 0xDA,0x7A, ETHTX_UDP_LEN_MSB,ETHTX_UDP_LEN_LSB, 0x00,0x00};
static uint8_t g_mac_rx_buffer_0[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_1[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_2[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_3[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_4[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_5[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_6[ETH_PACKET_SIZE];
static uint8_t g_mac_rx_buffer_7[ETH_PACKET_SIZE];

static volatile uint32_t g_mac_tx_buffer_used = 1u;


static uint8_t test_buffer[] = \
		{0x00,0xe0,0x4c,0x68,0x01,0x2f, mac_address[0],mac_address[1],mac_address[2],mac_address[3],mac_address[4],mac_address[5], 0x08,0x00,
		0x45, 0x00, 0x00,0x20, 0x00,0x00, 0x00,0x00, 0x80, 0x11, 0xa8,0xd8, my_ip[0],my_ip[1],my_ip[2],my_ip[3], tx_ip[0],tx_ip[1],tx_ip[2],tx_ip[3],
		0xDA,0x7A, 0xDA,0x7A, 0x00,0x0c, 0x00,0x00, 0xde,0xdd,0xbe,0xef};

static volatile uint32_t g_mac_tx_arp_used = 2u;



/*------------------------------------------------------------------------------
 * MAIN
 */
int main(){
	init_periph();

	for(;;){
		/*
		if(do_big_data != 0){
			eth_send_big_data();
			//do_big_data = 0;
		}
		*/
		switch (port_check)
		{
			case ETH_P_C0DE:
				do_eth_cmd_code();
				port_check = 0;
				break;
			case ETH_P_DA7A:
				if(data_rx_cnt >= 2){
					data_rx_cnt = 0;
					load_fft_samples();
				}
				port_check = 0;
				break;
			case ETH_P_ARP_PROBE:
				eth_arp_announce();
				port_check = 0;
				break;
			default:
				break;
		}
	}
}


void init_periph(void){

	uint32_t reg_val = 0;

	gmii_trap_init(&gmii_trap_fab, GMII_MAC_FILTER_SNIFFER_0);
	gmii_trap_enable(&gmii_trap_fab, 1);
	reg_val = gmii_trap_get_mac0(&gmii_trap_fab);
	reg_val = gmii_trap_get_ctrl(&gmii_trap_fab);
	reg_val = gmii_trap_get_stat(&gmii_trap_fab);

	if(0 == reg_val)
	{
		NULL;
	}
	else{
		NULL;
	}

	/*-------------------------------------------------------------------------*//**
	* MSS_UART
	*/
	MSS_UART_init(
			&g_mss_uart0,
			/*MSS_UART_921600_BAUD,*/MSS_UART_115200_BAUD,
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
	* MSS_GPIO
	*/

	MSS_GPIO_init();

	MSS_GPIO_config(MSS_GPIO_8, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);
	MSS_GPIO_config(MSS_GPIO_9, MSS_GPIO_INPUT_MODE | MSS_GPIO_IRQ_EDGE_POSITIVE);
	MSS_GPIO_enable_irq(MSS_GPIO_8);
	MSS_GPIO_enable_irq(MSS_GPIO_9);

	/*-------------------------------------------------------------------------*//**
	* Fabric FFT
	*/

	fft_init(&fft_fab, FFT_AHB_WRAPPER_0);
	fft_set_DMA(&fft_fab, 1);

	NVIC_EnableIRQ(FabricIrq1_IRQn);

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"fft initialized!\n\r");

	/*-------------------------------------------------------------------------*//**
	* MSS_MAC, VSC8541 PHY, Ethernet stuff
	*/


	NVIC_DisableIRQ(FabricIrq0_IRQn);

	MSS_MAC_cfg_struct_def_init(&mac_config);
	mac_config.mac_addr[0] = mac_address[0];
	mac_config.mac_addr[1] = mac_address[1];
	mac_config.mac_addr[2] = mac_address[2];
	mac_config.mac_addr[3] = mac_address[3];
	mac_config.mac_addr[4] = mac_address[4];
	mac_config.mac_addr[5] = mac_address[5];
	//mac_config.speed_duplex_select = MSS_MAC_ANEG_100M_FD;
	mac_config.speed_duplex_select = MSS_MAC_ANEG_ALL_SPEEDS;
	mac_config.phy_addr = 0x00;
	mac_config.pad_n_CRC = MSS_MAC_PAD_N_CRC_DISABLE;

	ARP_init(mac_config.mac_addr, my_ip);


	MSS_MAC_init(&mac_config);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_0, (void *)g_mac_rx_buffer_0);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_1, (void *)g_mac_rx_buffer_1);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_2, (void *)g_mac_rx_buffer_2);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_3, (void *)g_mac_rx_buffer_3);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_4, (void *)g_mac_rx_buffer_4);
	MSS_MAC_receive_pkt(g_mac_rx_buffer_5, (void *)g_mac_rx_buffer_5);
	smpl_pkt_0 = g_mac_rx_buffer_6;
	smpl_pkt_1 = g_mac_rx_buffer_7;
	MSS_MAC_set_tx_callback(eth_tx_callback);
	MSS_MAC_set_rx_callback(eth_rx_callback);


	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"mac initialized!\n\r");

	eth_arp_announce();

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"ARP Sent!\n\r");

	/*-------------------------------------------------------------------------*//**
	* Fabric MAC filter trap
	*/


	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"== everything is set up! ==\n\r");

}

void do_eth_cmd_code(void){
	switch (eth_cmd_code) {
		case 1:
			read_fft_samples();
			break;
		case 2:
			fft_read_done(&fft_fab);
			break;
		case 3:
			report_fft_status();
			break;
		case 4:
			report_eth_status();
			break;
		case 5:
			report_mac_phy_reg();
			break;
		default:
			break;
	}
	eth_cmd_code = 0;
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
	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"Ethernet Transmit Sent\n\r");
}

void eth_rx_callback(
	uint8_t * p_rx_packet,
	uint32_t pckt_length,
	void * p_user_data
)
{
	port_check = eth_check_address(p_rx_packet);
	char buffer[128];
	uint8_t * dest_array;
	uint8_t * pkt_buf_array;


	pkt_buf_array = p_user_data;

	if(ETH_P_DA7A == port_check){
		if(data_rx_cnt == 0){
			pkt_buf_array = smpl_pkt_0;
			smpl_pkt_0 = p_user_data;
		}
		else if(data_rx_cnt == 1){
			pkt_buf_array = smpl_pkt_1;
			smpl_pkt_1 = p_user_data;
		}
		data_rx_cnt++;
	}
	else if(ETH_P_C0DE == port_check){
		eth_cmd_code = eth_get_code(p_rx_packet);
	}
	else if(ETH_P_ARP_RESPONSE == port_check){
		uint8_t * tx_buffer;
		int buf_len = 0;

		buf_len = ARP_get_response(tx_buffer, p_rx_packet);
		MSS_MAC_send_pkt(arp_buffer, buf_len, (void *)&g_mac_tx_buffer_used);

		
		port_check = 0;
	}
	
	//eth_arp_announce();


	MSS_MAC_receive_pkt((uint8_t *)pkt_buf_array, pkt_buf_array);
	

}

char eth_check_address(uint8_t * packet_data){
	/* Check Destination address */
	if(packet_data[30] == my_ip[0] && packet_data[31] == my_ip[1] && packet_data[32] == my_ip[2] && (packet_data[33] == my_ip[3] || packet_data[33] == 255)){
		/* Check Destination port */
		if(packet_data[36] == 0xC0 && packet_data[37] == 0xDE){
			/* 0xC0DE
			 * data on the 0xC0DE port contains control codes, e.g. start/stop or set flags on peripherals
			 * probably a 4 byte unsigned integer that triggers a function on this here ARM core
			 */
			//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"C0DE received, Applying Code\n\r");
			return ETH_P_C0DE;
		}
		else if(packet_data[36] == 0xDA && packet_data[37] == 0x7A){
			/* 0xDA7A
			 * data on the 0xDA7A port contains actual data.
			 * Where this data goes depends on flags set with 0xC0DE
			 */
			//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"DA7A received, Receiving Data\n\r");
			return ETH_P_DA7A;
		}
	}
	else if(packet_data[0] == 0xff && packet_data[1] == 0xff && packet_data[2] == 0xff && packet_data[3] == 0xff && packet_data[4] == 0xff && packet_data[5] == 0xff){
		/* MAC address broadast */
		/* Check if ARP probe */
		if(packet_data[12] == ARP_TYPE_MSB && packet_data[13] == ARP_TYPE_LSB){
			if(packet_data[38] == my_ip[0] && packet_data[39] == my_ip[1] && packet_data[40] == my_ip[2] && packet_data[41] == my_ip[3]){
				return ETH_P_ARP_RESPONSE;
			}
			else{
				return ETH_P_ARP_PROBE;
			}
		}
	}
	return ETH_P_NOP;
}

uint32_t eth_get_code(uint8_t * packet_data){
	uint32_t the_code = 0;
	
	for(int i = 0; i < 4; i++){
		the_code = (the_code << 8) | (packet_data[i + 42] & 0xff);
	}

	return the_code;
}

void report_eth_status(void){
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

void report_mac_phy_reg(void){
	char buffer[128];
	uint16_t phy_reg;

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"============\r\nPHY REGISTERS\r\n");

	for(uint8_t i = 0; i < 32; i++){
		phy_reg = MSS_MAC_read_phy_reg(mac_config.phy_addr, i);
		snprintf(buffer, sizeof(buffer), "phy reg %d : %x\r\n", (int)i, (int)phy_reg);
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
	}

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"============\r\n");
}

void load_fft_samples(void){
	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"load started\n\r");

	//char buffer[128];
	int16_t sample;
	uint16_t smpl_0_id, smpl_1_id;
	uint8_t * smpls_first;
	uint8_t * smpls_sec;
	//uint16_t data_cnt = 0;

	smpl_0_id = (smpl_pkt_0[18] << 8) | (smpl_pkt_0[19] & 0xff);
	smpl_1_id = (smpl_pkt_1[18] << 8) | (smpl_pkt_1[19] & 0xff);


	if(smpl_0_id < smpl_1_id){
		smpls_first = smpl_pkt_0;
		smpls_sec = smpl_pkt_1;
	}
	else{
		smpls_first = smpl_pkt_1;
		smpls_sec = smpl_pkt_0;
	}

	for(int i = ETH_PACKET_DATA_START; i < ETH_PACKET_DATA_START + 1024; i+=2){
		sample = smpls_first[i];
		sample = (sample << 8) | (smpls_first[i+1] & 0xff);
		fft_load_smpl(&fft_fab, sample, 0u);
	}
	for(int i = ETH_PACKET_DATA_START; i < ETH_PACKET_DATA_START + 1024; i+=2){
		sample = smpls_sec[i];
		sample = (sample << 8) | (smpls_sec[i+1] & 0xff);
		fft_load_smpl(&fft_fab, sample, 0u);
	}

	fft_load_done(&fft_fab);	// sets write done in FFT core

	
	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"load finished\r\n");
}


void read_fft_samples(void){
	//char buffer[128];
	//int16_t fft_result_real[513];
	//int16_t fft_result_imag[513];
	uint16_t fft_result_abs;
	int byte_cnt = ETH_PACKET_DATA_START;

	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"return started\r\n");

	/* ipv4 packet id */
	g_mac_tx_buffer[18] = (uint8_t)((eth_tx_id >> 8) & 0xff);
	g_mac_tx_buffer[19] = (uint8_t)(eth_tx_id & 0xff);
	//eth_tx_id++;


	for(int i = 0; i < 513; i++){
		byte_cnt++;
		//fft_read_smpl(&fft_fab, (uint16_t)i, fft_result_real[i], fft_result_imag[i], fft_result_abs);
		fft_set_output_smpl(&fft_fab, (uint16_t)i);
		//fft_result_real[i] = fft_get_real_out(&fft_fab);
		//fft_result_imag[i] = fft_get_imag_out(&fft_fab);
		fft_result_abs = fft_get_abs_val_out(&fft_fab);
		g_mac_tx_buffer[i + ETH_PACKET_DATA_START] = (uint8_t)fft_result_abs;

		//snprintf(buffer, sizeof(buffer), "return %d = %d + i%d\r\n", (int)i, (int)fft_result_real[i], (int)fft_result_imag[i]);
		//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)buffer);
	}

	MSS_MAC_send_pkt(g_mac_tx_buffer, byte_cnt, (void *)&g_mac_tx_buffer_used);
	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"return finished\r\n");

	if(fft_auto_done != 0){
		fft_read_done(&fft_fab);
	}
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
	status_test = fft_status & STAT_INT_ACTIVE;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"INTERRUPT ACTIVE\r\n");
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
	status_test = fft_status & CTRL_DMA;
	if(status_test != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"DMA ENABLED\r\n");
	}
	if(fft_auto_done != 0){
		MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"AUTO READ DONE\r\n");
	}

	MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"status finished\r\n==========\r\n");
}

uint16_t eth_gen_checksum(uint8_t * buffer, uint32_t length){
	uint32_t running_checksum = 0;
	uint16_t checksum;

	for(int i = 0; i < length; i++){
		running_checksum += buffer[i];
	}

	while((running_checksum & 0xffff0000) != 0){
		checksum = (running_checksum >> 16) & 0xffff;
		running_checksum &= 0xffff;
		running_checksum += checksum;
	}

	checksum = running_checksum & 0xffff;
	return checksum;
}

void eth_arp_announce(void){

	static uint8_t * tx_buffer;
	int buf_len = 0;

	//buf_len = ARP_get_gratuitous(tx_buffer);
	buf_len = ARP_get_announce(tx_buffer);
	//arp_buffer
	MSS_MAC_send_pkt(arp_buffer, buf_len, (void *)&g_mac_tx_buffer_used);
	//MSS_MAC_send_pkt(test_buffer, sizeof(test_buffer), (void *)&g_mac_tx_buffer_used);
}

void eth_send_big_data(void){
	MSS_MAC_send_pkt(g_mac_tx_buffer, sizeof(g_mac_tx_buffer), (void *)&g_mac_tx_buffer_used);
}

uint32_t test_GPIO_high(uint32_t GPIO_MASK){
	uint32_t gpio_inputs;
	gpio_inputs = MSS_GPIO_get_inputs();
	gpio_inputs &= GPIO_MASK;

	return gpio_inputs;
}

/*-------------------------------------------------------------------------*//**
 * GPIO8_IRQHandler() reads Board_Button[0]; SW1
 * big data out
 */
void GPIO8_IRQHandler(void){

	if(0 != test_GPIO_high(MSS_GPIO_8_MASK)){
		//do_big_data ^= 1;
		fft_auto_done ^= 1u;
	}

	/*
	if(do_big_data != 0){
		// build output buffer?
	}
	*/

	MSS_GPIO_clear_irq(MSS_GPIO_8);
}

/*-------------------------------------------------------------------------*//**
 * GPIO9_IRQHandler()  reads Board_Button[1]; SW2
 * dump PHY and MAC registers
 */
void GPIO9_IRQHandler(void){

	if(0 != test_GPIO_high(MSS_GPIO_9_MASK)){
		//eth_arp_announce();
		report_eth_status();
		report_mac_phy_reg();
	}

	MSS_GPIO_clear_irq(MSS_GPIO_9);
}

/*-------------------------------------------------------------------------*//**
 * FabricIrq0_IRQHandler() triggers on MDINT from the Ethernet PHY
 * TODO
 */
void FabricIrq0_IRQHandler(void){

}

/*-------------------------------------------------------------------------*//**
 * FabricIrq1_IRQHandler() triggers on the FFT completion
 * exports data as an ethernet frame and clears the interrupt
 */
void FabricIrq1_IRQHandler(void){
	//MSS_UART_polled_tx_string(&g_mss_uart0, (const uint8_t *)"FFT Interrupt Triggered\r\n");
	read_fft_samples();
	NVIC_ClearPendingIRQ(FabricIrq1_IRQn);
	fft_int_clr(&fft_fab);
}
