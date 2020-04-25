

#include "ICMP_protocol.h"


ICMP_instance_t ICMP_stuff;

uint8_t icmp_buffer[ICMP_BUF_LEN] = \
        {
            0xff,0xff,0xff,0xff,0xff,0xff,      // target MAC
            0x00,0x00,0x00,0x00,0x00,0x00,      // my MAC (set with init)
            0x08,0x06,                          // Type: ARP
            0x00,0x01,                          // HW type: Ethernet
            0x08,0x00,                          // protocol type: IPv4
            0x06,                               // HW size: 6 (MAC addr is 6 bytes)
            0x04,                               // protocol size: 4 (IPv4 IP addr is 4 bytes)
            0x00,0x01,                          // ARP opcode: 1 = request, 2 = response
            0x00,0x00,0x00,0x00,0x00,0x00,      // my MAC (set with init)
            0x00,0x00,0x00,0x00,                // my IP (set with init, no routers allowed)
            0x00,0x00,0x00,0x00,0x00,0x00,      // target MAC (depends on what's happening)
            0x00,0x00,0x00,0x00                 // target IP (depends on what's happening)
        };



void ICMP_init
(
    //ARP_instance_t my_ARP,
    uint8_t * my_mac,
    const uint8_t * my_ip
)
{
    ICMP_stuff.my_mac_addr[0] = my_mac[0];
    ICMP_stuff.my_mac_addr[1] = my_mac[1];
    ICMP_stuff.my_mac_addr[2] = my_mac[2];
    ICMP_stuff.my_mac_addr[3] = my_mac[3];
    ICMP_stuff.my_mac_addr[4] = my_mac[4];
    ICMP_stuff.my_mac_addr[5] = my_mac[5];

    ICMP_stuff.my_ip_addr[0] = my_ip[0];
    ICMP_stuff.my_ip_addr[1] = my_ip[1];
    ICMP_stuff.my_ip_addr[2] = my_ip[2];
    ICMP_stuff.my_ip_addr[3] = my_ip[3];

    /* set source MAC to init value */
    icmp_buffer[6] = ICMP_stuff.my_mac_addr[0];
    icmp_buffer[7] = ICMP_stuff.my_mac_addr[1];
    icmp_buffer[8] = ICMP_stuff.my_mac_addr[2];
    icmp_buffer[9] = ICMP_stuff.my_mac_addr[3];
    icmp_buffer[10] = ICMP_stuff.my_mac_addr[4];
    icmp_buffer[11] = ICMP_stuff.my_mac_addr[5];

    /* set sender MAC to init value */
    icmp_buffer[22] = ICMP_stuff.my_mac_addr[0];
    icmp_buffer[23] = ICMP_stuff.my_mac_addr[1];
    icmp_buffer[24] = ICMP_stuff.my_mac_addr[2];
    icmp_buffer[25] = ICMP_stuff.my_mac_addr[3];
    icmp_buffer[26] = ICMP_stuff.my_mac_addr[4];
    icmp_buffer[27] = ICMP_stuff.my_mac_addr[5];

    /* set sender IP to init value */
    icmp_buffer[28] = ICMP_stuff.my_ip_addr[0];
    icmp_buffer[29] = ICMP_stuff.my_ip_addr[1];
    icmp_buffer[30] = ICMP_stuff.my_ip_addr[2];
    icmp_buffer[31] = ICMP_stuff.my_ip_addr[3];
}


int ICMP_get_response
(
    uint8_t * icmp_buf_return,
    uint8_t * inc_ICMP_pkt
)
{
    /* set destination MAC to sender of request */
    icmp_buffer[0] = inc_ICMP_pkt[22];
    icmp_buffer[1] = inc_ICMP_pkt[23];
    icmp_buffer[2] = inc_ICMP_pkt[24];
    icmp_buffer[3] = inc_ICMP_pkt[25];
    icmp_buffer[4] = inc_ICMP_pkt[26];
    icmp_buffer[5] = inc_ICMP_pkt[27];

    /* set ARP opcode to Replay (2) */
    icmp_buffer[20] = 0x00;
    icmp_buffer[21] = 0x02;

    /* set target MAC to sender of request */
    icmp_buffer[32] = inc_ICMP_pkt[22];
    icmp_buffer[33] = inc_ICMP_pkt[23];
    icmp_buffer[34] = inc_ICMP_pkt[24];
    icmp_buffer[35] = inc_ICMP_pkt[25];
    icmp_buffer[36] = inc_ICMP_pkt[26];
    icmp_buffer[37] = inc_ICMP_pkt[27];

    /* set target IP to sender of request */
    icmp_buffer[38] = inc_ICMP_pkt[28];
    icmp_buffer[39] = inc_ICMP_pkt[29];
    icmp_buffer[40] = inc_ICMP_pkt[30];
    icmp_buffer[41] = inc_ICMP_pkt[31];

    icmp_buf_return = icmp_buffer;
    return ICMP_BUF_LEN;
}