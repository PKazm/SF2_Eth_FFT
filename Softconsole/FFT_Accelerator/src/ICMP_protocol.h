

#include "../firmware/hal/CortexM3/GNU/cpu_types.h"



#define ICMP_PROT_NUM   0x01u


#define ICMP_BUF_LEN    74



typedef struct ICMP_instance
{
    uint8_t my_mac_addr[6];
    uint8_t my_ip_addr[4];

} ICMP_instance_t;


extern uint8_t icmp_buffer[ICMP_BUF_LEN];



void ICMP_init
(
    //ARP_instance_t my_ARP,
    uint8_t * my_mac,
    const uint8_t * my_ip
);


int ICMP_get_echo_reply
(
    uint8_t * icmp_buf_return,
    uint8_t * inc_ICMP_pkt
);