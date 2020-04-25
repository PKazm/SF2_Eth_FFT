


#include "../firmware/hal/CortexM3/GNU/cpu_types.h"

#define BIT0        0x01u
#define BIT1        0x02u
#define BIT2        0x04u
#define BIT3        0x08u
#define BIT4        0x10u
#define BIT5        0x20u
#define BIT6        0x40u
#define BIT7        0x80u

#define FRAME_PASS_CTRL     0x40u
#define HASH_TBL_REG0       0x44u
#define HASH_TBL_REG1       0x48u
#define HASH_TBL_REG2       0x4Cu
#define HASH_TBL_REG3       0x50u
#define MISC_CTRL_REG       0x54u
#define FRAME_DROP_CNT      0x58u
#define STAT_ADDR_LO        0x5Cu
#define STAT_ADDR_HI        0x60u


#define FPC_P_BCAST         BIT0
#define FPC_P_MCAST         BIT1
#define FPC_P_UCAST         BIT2
#define FPC_SLUTTY          BIT3
#define FPC_HASH_UCAST      BIT4
#define FPC_HASH_MCAST      BIT5


typedef struct mac_filt_instance
{
    addr_t address;
} mac_filt_instance_t;



void mac_filt_init
(
    mac_filt_instance_t * macf_inst,
    addr_t base_addr
);