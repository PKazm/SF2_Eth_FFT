
#include "MAC_Filter.h"
#include "../firmware/hal/hal.h"
#include "../firmware/hal/hal_assert.h"


void mac_filt_init
(
    mac_filt_instance_t * macf_inst,
    addr_t base_addr
)
{
    macf_inst->address = base_addr;
}