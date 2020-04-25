

#include "../firmware/hal/CortexM3/GNU/cpu_types.h"



#define ARP_TYPE    0x0806u
#define ARP_TYPE_MSB  ((ARP_TYPE >> 8) & 0xff)
#define ARP_TYPE_LSB  (ARP_TYPE & 0xff)

#define ARP_REQST   0x01u
#define ARP_REPLY   0x02u


#define ARP_BUF_LEN     42


typedef struct ARP_instance
{
    uint8_t my_mac_addr[6];
    uint8_t my_ip_addr[4];

} ARP_instance_t;


extern uint8_t arp_buffer[ARP_BUF_LEN];


void ARP_init
(
    //ARP_instance_t my_ARP,
    uint8_t * my_mac,
    const uint8_t * my_ip
);


int ARP_get_request
(
    uint8_t * arp_buf_return
);


int ARP_get_response
(
    uint8_t * arp_buf_return,
    uint8_t * inc_ARP_pkt
);

int ARP_get_gratuitous
(
    uint8_t * arp_buf_return
);

int ARP_get_probe
(
    uint8_t * arp_buf_return
);

int ARP_get_announce
(
    uint8_t * arp_buf_return
);