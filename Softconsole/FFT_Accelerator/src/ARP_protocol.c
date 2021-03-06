

#include "ARP_protocol.h"



ARP_instance_t ARP_stuff;

uint8_t arp_buffer[ARP_BUF_LEN] = \
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



void ARP_init
(
    //ARP_instance_t my_ARP,
    uint8_t * my_mac,
    const uint8_t * my_ip
)
{
    ARP_stuff.my_mac_addr[0] = my_mac[0];
    ARP_stuff.my_mac_addr[1] = my_mac[1];
    ARP_stuff.my_mac_addr[2] = my_mac[2];
    ARP_stuff.my_mac_addr[3] = my_mac[3];
    ARP_stuff.my_mac_addr[4] = my_mac[4];
    ARP_stuff.my_mac_addr[5] = my_mac[5];

    ARP_stuff.my_ip_addr[0] = my_ip[0];
    ARP_stuff.my_ip_addr[1] = my_ip[1];
    ARP_stuff.my_ip_addr[2] = my_ip[2];
    ARP_stuff.my_ip_addr[3] = my_ip[3];

    /* set source MAC to init value */
    arp_buffer[6] = ARP_stuff.my_mac_addr[0];
    arp_buffer[7] = ARP_stuff.my_mac_addr[1];
    arp_buffer[8] = ARP_stuff.my_mac_addr[2];
    arp_buffer[9] = ARP_stuff.my_mac_addr[3];
    arp_buffer[10] = ARP_stuff.my_mac_addr[4];
    arp_buffer[11] = ARP_stuff.my_mac_addr[5];

    /* set sender MAC to init value */
    arp_buffer[22] = ARP_stuff.my_mac_addr[0];
    arp_buffer[23] = ARP_stuff.my_mac_addr[1];
    arp_buffer[24] = ARP_stuff.my_mac_addr[2];
    arp_buffer[25] = ARP_stuff.my_mac_addr[3];
    arp_buffer[26] = ARP_stuff.my_mac_addr[4];
    arp_buffer[27] = ARP_stuff.my_mac_addr[5];

    /* set sender IP to init value */
    arp_buffer[28] = ARP_stuff.my_ip_addr[0];
    arp_buffer[29] = ARP_stuff.my_ip_addr[1];
    arp_buffer[30] = ARP_stuff.my_ip_addr[2];
    arp_buffer[31] = ARP_stuff.my_ip_addr[3];
}


int ARP_get_request
(
    uint8_t * arp_buf_return
)
{
    /* set destination MAC to broadcast */
    arp_buffer[0] = 0xff;
    arp_buffer[1] = 0xff;
    arp_buffer[2] = 0xff;
    arp_buffer[3] = 0xff;
    arp_buffer[4] = 0xff;
    arp_buffer[5] = 0xff;

    /* set ARP opcode to Request (1) */
    arp_buffer[20] = 0x00;
    arp_buffer[21] = 0x01;

    /* set target MAC to unknown */
    arp_buffer[32] = 0x00;
    arp_buffer[33] = 0x00;
    arp_buffer[34] = 0x00;
    arp_buffer[35] = 0x00;
    arp_buffer[36] = 0x00;
    arp_buffer[37] = 0x00;

    /* set target IP to desired IP */
    arp_buffer[38] = ARP_stuff.my_ip_addr[0];
    arp_buffer[39] = ARP_stuff.my_ip_addr[1];
    arp_buffer[40] = ARP_stuff.my_ip_addr[2];
    arp_buffer[41] = ARP_stuff.my_ip_addr[3];

    arp_buf_return = arp_buffer;
    return ARP_BUF_LEN;
}


int ARP_get_response
(
    uint8_t * arp_buf_return,
    uint8_t * inc_ARP_pkt
)
{
    /* set destination MAC to sender of request */
    arp_buffer[0] = inc_ARP_pkt[22];
    arp_buffer[1] = inc_ARP_pkt[23];
    arp_buffer[2] = inc_ARP_pkt[24];
    arp_buffer[3] = inc_ARP_pkt[25];
    arp_buffer[4] = inc_ARP_pkt[26];
    arp_buffer[5] = inc_ARP_pkt[27];

    /* set ARP opcode to Replay (2) */
    arp_buffer[20] = 0x00;
    arp_buffer[21] = 0x02;

    /* set target MAC to sender of request */
    arp_buffer[32] = inc_ARP_pkt[22];
    arp_buffer[33] = inc_ARP_pkt[23];
    arp_buffer[34] = inc_ARP_pkt[24];
    arp_buffer[35] = inc_ARP_pkt[25];
    arp_buffer[36] = inc_ARP_pkt[26];
    arp_buffer[37] = inc_ARP_pkt[27];

    /* set target IP to sender of request */
    arp_buffer[38] = inc_ARP_pkt[28];
    arp_buffer[39] = inc_ARP_pkt[29];
    arp_buffer[40] = inc_ARP_pkt[30];
    arp_buffer[41] = inc_ARP_pkt[31];

    arp_buf_return = arp_buffer;
    return ARP_BUF_LEN;
}


int ARP_get_gratuitous
(
    uint8_t * arp_buf_return
)
{
    /* set destination MAC to broadcast */
    arp_buffer[0] = 0xff;
    arp_buffer[1] = 0xff;
    arp_buffer[2] = 0xff;
    arp_buffer[3] = 0xff;
    arp_buffer[4] = 0xff;
    arp_buffer[5] = 0xff;

    /* set ARP opcode to Replay (2) */
    arp_buffer[20] = 0x00;
    arp_buffer[21] = 0x02;

    /* set target MAC to broadcast */
    arp_buffer[32] = 0xff;
    arp_buffer[33] = 0xff;
    arp_buffer[34] = 0xff;
    arp_buffer[35] = 0xff;
    arp_buffer[36] = 0xff;
    arp_buffer[37] = 0xff;

    /* set target IP to IP I'm claiming */
    arp_buffer[38] = ARP_stuff.my_ip_addr[0];
    arp_buffer[39] = ARP_stuff.my_ip_addr[1];
    arp_buffer[40] = ARP_stuff.my_ip_addr[2];
    arp_buffer[41] = ARP_stuff.my_ip_addr[3];

    arp_buf_return = arp_buffer;
    return ARP_BUF_LEN;
}


int ARP_get_probe
(
    uint8_t * arp_buf_return
)
{
    /* set destination MAC to broadcast */
    arp_buffer[0] = 0xff;
    arp_buffer[1] = 0xff;
    arp_buffer[2] = 0xff;
    arp_buffer[3] = 0xff;
    arp_buffer[4] = 0xff;
    arp_buffer[5] = 0xff;

    /* set ARP opcode to Request (1) */
    arp_buffer[20] = 0x00;
    arp_buffer[21] = 0x01;

    /* set sender IP to blank */
    arp_buffer[28] = 0x00;
    arp_buffer[29] = 0x00;
    arp_buffer[30] = 0x00;
    arp_buffer[31] = 0x00;

    /* set target MAC to broadcast */
    arp_buffer[32] = 0x00;
    arp_buffer[33] = 0x00;
    arp_buffer[34] = 0x00;
    arp_buffer[35] = 0x00;
    arp_buffer[36] = 0x00;
    arp_buffer[37] = 0x00;

    /* set target IP to IP I'm probing */
    arp_buffer[38] = ARP_stuff.my_ip_addr[0];
    arp_buffer[39] = ARP_stuff.my_ip_addr[1];
    arp_buffer[40] = ARP_stuff.my_ip_addr[2];
    arp_buffer[41] = ARP_stuff.my_ip_addr[3];

    arp_buf_return = arp_buffer;
    return ARP_BUF_LEN;
}

int ARP_get_announce
(
    uint8_t * arp_buf_return
)
{
    /* set destination MAC to broadcast */
    arp_buffer[0] = 0xff;
    arp_buffer[1] = 0xff;
    arp_buffer[2] = 0xff;
    arp_buffer[3] = 0xff;
    arp_buffer[4] = 0xff;
    arp_buffer[5] = 0xff;

    /* set ARP opcode to Request (1) */
    arp_buffer[20] = 0x00;
    arp_buffer[21] = 0x01;

    /* set sender IP to IP I'm claiming */
    arp_buffer[29] = ARP_stuff.my_ip_addr[0];
    arp_buffer[28] = ARP_stuff.my_ip_addr[1];
    arp_buffer[30] = ARP_stuff.my_ip_addr[2];
    arp_buffer[31] = ARP_stuff.my_ip_addr[3];

    /* set target MAC to broadcast */
    arp_buffer[32] = 0xff;
    arp_buffer[33] = 0xff;
    arp_buffer[34] = 0xff;
    arp_buffer[35] = 0xff;
    arp_buffer[36] = 0xff;
    arp_buffer[37] = 0xff;

    /* set target IP to IP I'm claiming */
    arp_buffer[38] = ARP_stuff.my_ip_addr[0];
    arp_buffer[39] = ARP_stuff.my_ip_addr[1];
    arp_buffer[40] = ARP_stuff.my_ip_addr[2];
    arp_buffer[41] = ARP_stuff.my_ip_addr[3];

    arp_buf_return = arp_buffer;
    return ARP_BUF_LEN;
}